onScrobble =
  inject: ->
    wrap = "onScrobble = undefined; " +
           "function main(){ " +
             "var temp = undefined; onScrobble = #{arguments[0].toString()}();\n"
    wrap += "temp = #{funk.toString()}(); jQuery.extend(onScrobble, temp);\n" for funk in arguments
    wrap += "onScrobble.load();\n}"

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

(exports ? this).onScrobble = onScrobble
