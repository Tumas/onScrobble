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

(exports ? this).onScrobble = onScrobble

  #load: () ->
  # jquerY + coffeescript 
  # vim snippets 
