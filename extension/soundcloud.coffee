onScrobble.soundcloud =
  ->
    events:
      play: "onAudioPlay"
      pause: "onAudioPause"
      finish: "onAudioFinish"
      playStart: "onAudioPlayStart"

    artist: (username, track) ->
      trackInfo = track

      if not track.match(' (-|–) ') and not track.match(new RegExp("^#{username}"))
        trackInfo = "#{username} - #{track}"
      trackInfo

    load: ->
      console.log this
      # State 
      idle_time  = 0
      idle_start = undefined
      start_time = undefined
      track = undefined
      duration = 0
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

        if onScrobble.canSubmit(play_time, duration)
          console.log "Submitting: #{track}"
          finish_submit = yes
        
      $(document).bind onScrobble.events.playStart, (info) ->
        # track changes here
        trackName = onScrobble.artist(info.track.user.username, info.track.title)

        idle_time += info.timeStamp - idle_start if idle_start
        play_time = onScrobble.secondify(info.timeStamp - idle_time - start_time)

        # submit(track) if not finish_submit and canSubmit() 
        if not finish_submit and onScrobble.canSubmit(play_time, duration)
          console.log "Submitting: #{track}"

        # submit now playing for new track
        console.log "Now playing: #{trackName}"
        
        # reset
        idle_time = 0
        idle_start = undefined
        start_time = info.timeStamp
        finish_submit = no
        track = trackName
        duration = onScrobble.secondify(info.track.duration)

jQuery ($) ->
  onScrobble.inject onScrobble.scrobbler, onScrobble.soundcloud
