onScrobble =
  inject: ->
    wrap = "onScrobble = undefined; " +
           "function main(){ " +
             "var temp = undefined; onScrobble = #{arguments[0].toString()}();\n"
    wrap += "temp = #{funk.toString()}(); jQuery.extend(onScrobble, temp);\n" for funk in arguments

    # adding scrobbling Port element to share events with the extension
    wrap += " $('body').append('<span id=\"scrobblingPort\"></span>'); "

    # adding Submit and SubmitNowPlaying events 
    wrap += "var submitEvent   = document.createEvent('Event'); submitEvent.initEvent('Submit', true, true); "
    wrap += "var submitNPEvent = document.createEvent('Event'); submitNPEvent.initEvent('SubmitNowPlaying', true, true); "

    # load everything
    wrap += "onScrobble.load();\n }"

    scriptNode = document.createElement("script")
    scriptNode.textContent = "#{wrap};\nmain();"
    document.head.appendChild(scriptNode)

    $('span#scrobblingPort').bind 'Submit', (data) ->
      track = data.target.attributes[1].nodeValue
      chrome.extension.sendRequest { type: data.type, track: $.parseJSON(track) }

    $('span#scrobblingPort').bind 'SubmitNowPlaying', (data) ->
      track = data.target.attributes[1].nodeValue
      chrome.extension.sendRequest { type: data.type, track: $.parseJSON(track) }

  # for un-injected content scripts
  # data.type 'Submit' | 'SubmitNowPlaying'
  # data.track
  #   artist
  #   track
  #   timestamp
  submit: (data) ->
    chrome.extension.sendRequest data

  timestamp: ->
    @scrobbler().secondify new Date().getTime()

  scrobbler: ->
    # duration must be in seconds
    canSubmit: (timePlayed, duration) ->
      timePlayed >= 30 and (timePlayed >= duration/2 or timePlayed >= 60*4)

    secondify: (ts) ->
      Math.round Number(ts/1000)

    decodeHTML: (string) ->
      $("<textarea />").html(string).val()

    submit: (track) ->
      $('span#scrobblingPort').attr('track', onScrobble.decodeHTML(JSON.stringify(track)))
      document.getElementById('scrobblingPort').dispatchEvent submitEvent

    submitNowPlaying: (track) ->
      $('span#scrobblingPort').attr('track', onScrobble.decodeHTML(JSON.stringify(track)))
      document.getElementById('scrobblingPort').dispatchEvent submitNPEvent

(exports ? this).onScrobble = onScrobble
