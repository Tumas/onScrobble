onScrobble =
  pre: (code, object) ->
    "var onScrobble = #{code}();\n onScrobble.load();"

  inject: (code)->
    # no main, call directly
    wrap = "function main(){\n#{this.pre(code)}\n}"
    scriptNode = document.createElement("script")
    scriptNode.textContent = "#{wrap};\nmain();"
    document.head.appendChild(scriptNode)

  soundcloud: ->
    events:
      play: "onAudioPlay"
      pause: "onAudioPause"

    timestamp: -> Math.round Number(new Date()) / 1000

    artist: (username, track) ->
      trackInfo = track

      if not track.match(' (-|–) ') and not track.match(new RegExp("^#{username}"))
        trackInfo = "#{username} - #{track}"
      trackInfo

    #canSubmit: (timePlayed, duration) ->
    #  timePlayed >= duration / 2 or timePlayed >= 4 * 60 

    load: ->
      idle_time  = 0
      start_play = undefined
      idle_start = undefined
      current_track = undefined

      $(document).bind onScrobble.events.play, (info) ->
        trackName = onScrobble.artist(info.track.user.username, info.track.title)
        console.log("audio played: #{trackName}")

      $(document).bind onScrobble.events.pause, (info) ->
        trackName = onScrobble.artist(info.track.user.username, info.track.title)
        console.log("audio paused: #{trackName}")

(exports ? this).onScrobble = onScrobble

jQuery ($) ->
  injected = onScrobble.soundcloud.toString()
  onScrobble.inject injected
