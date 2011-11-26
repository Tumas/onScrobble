onScrobble.bandcamp =
  scope: '#trackInfo .inline_player'

  currentTrack: ->
    obj =
      artist: $('span[itemprop="byArtist"] a', @info).text()
      album: $('h2[itemprop="name"]', @info).text() 

  duration: ->
    time = $('span.time', @player).text()
    if time
      duration = time.split('/')[1].split(':')
      parseInt(duration[0]) * 60 + parseInt(duration[1])

  load: ->
    pageType = $('meta[property="og:type"]').attr('content')

    # fetch info + getCurrent timestamp 
    current = undefined

    if pageType == 'song' or pageType == 'song'
      @player    = $(@scope)
      @trackInfo = $(".track_info span.title", @player)
      @button    = $("#{@scope} .playbutton", @player)
      @info      = $('#name-section')

      @trackInfo.bind "DOMSubtreeModified", (data) ->
        if current
          time_played = onScrobble.timestamp() - current.timestamp - current.idleTime
          console.log "TIME PLAYED"
          console.log time_played

          #if onScrobble.scrobbler().canSubmit(time_played, current.duration)
          #  onScrobble.submit { type: 'Submit', track: current }
        
        current =
          timestamp: onScrobble.timestamp()
          track:     this.innerHTML
          idleTime: 0
          idleStart: undefined
          duration: onScrobble.bandcamp.duration()
        $.extend current, onScrobble.bandcamp.currentTrack()

        onScrobble.submit { type: 'test', track: current }
        
      # button click is needed for counting time
      @button.click () ->
        time = onScrobble.timestamp()
        if not $(this).hasClass('playing')
          console.log "started playing"
          current.idleTime = time - current.idleStart
          current.idleStart = undefined
        else
          console.log "pause"
          current.idleStart = time

    # grab album info if present
    # intelligent gues fo VA

jQuery ($) ->
    onScrobble.bandcamp.load()
