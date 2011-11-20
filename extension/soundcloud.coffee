onScrobble.soundcloud =
  ->
    events:
      play: "onAudioPlay"
      pause: "onAudioPause"
      finish: "onAudioFinish"
      playStart: "onAudioPlayStart"

    trackInfo: (trackData, timeStamp) ->
      data = onScrobble.decodeHTML(trackData.title)

      # skip preceeding track number if it's not an artist
      sMatch = data.match(/ *(-|–) */)
      data.replace(/^\d{0,2} *(-|–) */, "") if sMatch and sMatch[1]

      info =
        timestamp: timeStamp,
        duration : onScrobble.secondify(trackData.duration),
        artist   : onScrobble.decodeHTML(trackData.user.username),
        track    : data

      mData = data.match new RegExp("^#{info.artist}", "i")
      if mData
        info.artist = $.trim mData[0]
        info.track = data.replace(new RegExp("^#{info.artist} *(-|–) *", "i"), "")
      else
        mData = data.split(/\s-|–\s/)
        if mData.length > 1
          info.artist = $.trim(mData[0])
          info.track = $.trim(mData[1])
      info

    load: ->
      # State 
      idle_time  = 0
      idle_start = undefined
      start_time = undefined
      track = undefined
      finish_submit = no

      $(document).bind onScrobble.events.play, (info) ->
        # stop idle time counting if was idle
        if idle_start
          idle_time += info.timeStamp - idle_start
          idle_start = undefined

      $(document).bind onScrobble.events.pause, (info) ->
        idle_start = info.timeStamp

      $(document).bind onScrobble.events.finish, (info) ->
        play_time = onScrobble.secondify(info.timeStamp - idle_time - start_time)

        if track and onScrobble.canSubmit(play_time, track.duration)
          onScrobble.submit track
          finish_submit = yes
        
      $(document).bind onScrobble.events.playStart, (info) ->
        # track changes here
        newTrack = onScrobble.trackInfo(info.track, onScrobble.secondify(info.timeStamp))
        idle_time += info.timeStamp - idle_start if idle_start
        play_time = onScrobble.secondify(info.timeStamp - idle_time - start_time)

        if track and not finish_submit and onScrobble.canSubmit(play_time, track.duration)
          onScrobble.submit track

        # submit now playing for new track
        onScrobble.submitNowPlaying newTrack
        
        # reset
        idle_time = 0
        idle_start = undefined
        start_time = info.timeStamp
        finish_submit = no
        track = newTrack

jQuery ($) ->
  onScrobble.inject onScrobble.scrobbler, onScrobble.soundcloud
