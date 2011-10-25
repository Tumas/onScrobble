onScrobble =
  pre: (code) ->
    "var onScrobble = #{code}();"

  inject: (code, generic)->
    # no main, call directly
    wrap = "function main(){\n#{this.pre(code)}\n onScrobble.scrobbler = #{generic}();\nonScrobble.load();\n}"
    scriptNode = document.createElement("script")
    scriptNode.textContent = "#{wrap};\nmain();"
    document.head.appendChild(scriptNode)

  scrobbler: ->
    # duration must be in seconds
    canSubmit: (timePlayed, duration) ->
      timePlayed >= 30 and (timePlayed >= duration/2 or timePlayed >= 60*4)

    secondify: (ts) -> Math.round Number(ts/1000)

    submit: (track) ->
      # todo

  soundcloud: ->
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
        # set idle time timestamp
        idle_start = info.timeStamp

      $(document).bind onScrobble.events.finish, (info) ->
        play_time = onScrobble.scrobbler.secondify(info.timeStamp - idle_time - start_time)

        if onScrobble.scrobbler.canSubmit(play_time, duration)
          console.log "Submitting: #{track}"
          finish_submit = yes
        
      $(document).bind onScrobble.events.playStart, (info) ->
        # track changes here
        trackName = onScrobble.artist(info.track.user.username, info.track.title)

        idle_time += info.timeStamp - idle_start if idle_start
        play_time = onScrobble.scrobbler.secondify(info.timeStamp - idle_time - start_time)

        # submit(track) if not finish_submit and canSubmit() 
        if not finish_submit and onScrobble.scrobbler.canSubmit(play_time, duration)
          console.log "Submitting: #{track}"

        # submit now playing for new track
        console.log "Now playing: #{trackName}"
        
        # reset
        idle_time = 0
        idle_start = undefined
        start_time = info.timeStamp
        finish_submit = false
        track = trackName
        duration = onScrobble.scrobbler.secondify(info.track.duration)

(exports ? this).onScrobble = onScrobble

jQuery ($) ->
  injected = onScrobble.soundcloud.toString()
  generic = onScrobble.scrobbler.toString()
  onScrobble.inject injected, generic
