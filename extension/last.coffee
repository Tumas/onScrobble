lastFM =
  base_url: "http://ws.audioscrobbler.com/2.0/?"
  api_key: "86afa310841f8a1d440b2310b1845b77"
  secret: "a98e0e7d1d10805e9898b483ba396a38"

  scrobbler:
    # TODO: one method + fallback for failed scrobbles
    submitNowPlaying: (track) ->
      # some filtering?
      params = $.extend(track, { api_key: lastFM.api_key, method: "track.updateNowPlaying" })
      params = lastFM.auth.sign(params)

      if params
        $.ajax(
          url: "#{lastFM.base_url}#{$.param(params)}",
          type: 'POST',
          success: (data)->
            console.log "OK now playing"
          error: (data) ->
            console.log "could not. Reason: #{$('error', data.responseText).text()}"
        )

    submit: (track) ->
      params = $.extend(track, { api_key: lastFM.api_key, method: "track.scrobble" })
      params = lastFM.auth.sign(params)

      if params
        $.ajax(
          url: "#{lastFM.base_url}#{$.param(params)}",
          type: 'POST',
          success: (data)->
            console.log "OK submitl playing"
          error: (data) ->
            console.log "could not. Reason: #{$('error', data.responseText).text()}"
        )

  auth:
    sessionID: ->
      localStorage['onScrobble.sessionID']

    authToken: ->
      localStorage['onScrobble.authToken']
    
    sign: (params)->
      sId = @sessionID()

      unless sId
        @requestToken(lastFM.api_key)

        # request session Id for new token
        @requestSession lastFM.api_key, @authToken()
        sId = @sessionID()

      if sId
        params["sk"] = sId
        params["api_sig"] = @getSignature(params)
        params
      else
        no

    requestAuth: (key, token) ->
      window.open("http://last.fm/api/auth?#{$.param({api_key: key, token: token})}")
      
    getSignature: (params) ->
      keys = (key for own key, value of params).sort()
      val = ("#{key}#{params[key]}" for key in keys).join("")
      console.log val
      $.md5 "#{val}#{lastFM.secret}"

    requestSession: (key, token) ->
      return false if not token
      signature = @getSignature({api_key: key, method: 'auth.getSession', token: token})

      $.ajax(
          url: "#{lastFM.base_url}" +
               "#{$.param({method: "auth.getSession", api_key: key, token: token, api_sig: signature})}",
          contentType: 'application/xml',
          success: (data)->
            key = $('key', data).text()
            localStorage['onScrobble.sessionID'] = key
          error: (data) ->
            console.log "could not get token. Reason: #{$('error', data.responseText).text()}"
      )

    requestToken: (key) ->
      $.ajax(
          url: "#{lastFM.base_url}" +
               "#{$.param({method: "auth.getToken", api_key: key})}",
          context: this,
          success: (data)->
            token = $('token', data).text()
            localStorage['onScrobble.authToken'] = token
            @requestAuth key, token
          error: (data) ->
            console.log "could not get token. Reason: #{$('error', data.responseText).text()}"
      )

jQuery ($) ->
  lastFM.auth.requestToken(lastFM.api_key) unless lastFM.auth.sessionID()

  chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
    switch request.type
      when 'SubmitNowPlaying'
        lastFM.scrobbler.submitNowPlaying request.track
      when 'Submit'
        lastFM.scrobbler.submit request.track
      else console.log "Unknown message: #{request.type}"
