timestamp = () -> Math.round Number(new Date()) / 1000

onScrobble =
  events:
    play: "onPlay"
    pause: "onPause"

  selectors:
    player: 'div.player'
    user:  'div.info-header span.user a'
    track:  'div.info-header h3 a'

  artist: (username, track) ->
    trackInfo = track

    if not track.match(' (-|–) ') and not track.match(new RegExp("^#{username}"))
      trackInfo = "#{username} - #{track}"
    trackInfo

  load: () ->
    start_play = undefined
    idle_start = undefined
    idle_time  = 0
    current_track = undefined

    console.log "onScrobble loaded"
    console.log $(onScrobble.selectors.played).size()

    $(onScrobble.selectors.player).each (index, el) ->
      song = onScrobble.artist($(onScrobble.selectors.user, $(el)).text(), $(onScrobble.selectors.track, $(el)).text())

      $(el).bind onScrobble.events.play, () ->
        console.log "event play: #{song}"
        current = timestamp()

        if idle_start
          idle_time += current - idle_start
          idle_start = undefined

        if not current_track or current_track != song
          time_played = 0

          if start_play
            time_played = current - stat_play
            time_played -= idle_time
            console.log "Song played: #{time_played} seconds"
            console.log "Idle time was: #{idle_time} seconds"

        start_play = current
        idle_time  = 0
        current_track = song

      $(el).bind onScrobble.events.pause, () ->
        console.log "event.pause: #{song}"
        idle_start = current

(exports ? this).onScrobble = onScrobble

# todo: proper loading
$(() ->
  onScrobble.load()
  console.log "load test"
);
