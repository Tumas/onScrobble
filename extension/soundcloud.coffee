onScrobble.soundcloud =
  ->
    events:
      play: "onAudioPlay"
      pause: "onAudioPause"
      finish: "onAudioFinish"
      playStart: "onAudioPlayStart"

    trackInfo: (trackData, timeStamp) ->
      title = onScrobble.decodeHTML trackData.title
      artist = onScrobble.decodeHTML trackData.user.username 
      temp = title.split(/\s-|–\s/)

      if temp.length > 1
        artist = $.trim(temp[0])
        title = $.trim(temp[1])

      {
        track:  title,
        artist: artist,
        duration: onScrobble.secondify(trackData.duration),
        timestamp: timeStamp
      }


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
