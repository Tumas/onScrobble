lastFM =
  base_url: "http://ws.audioscrobbler.com/2.0/?"
  api_key: "86afa310841f8a1d440b2310b1845b77"
  secret: "a98e0e7d1d10805e9898b483ba396a38"

  storage:
    fallback: 'onScrobble.fallback'
    token:  'onScrobble.authToken'
    session: 'onScrobble.sessionID'

  scrobbler:
    handleScrobbleFailure: (track) ->
      fallback = $.parseJSON localStorage[lastFM.storage.fallback]
      fallback = [] unless fallback
      fallback.push(track)
      localStorage[lastFM.storage.fallback] = JSON.stringify(fallback)
      console.log "failed scrobble: #{track.track}"

    submit: (track, method = 'track.scrobble') ->
      params = $.extend(track, { api_key: lastFM.api_key, method: method })
      params = lastFM.auth.sign(params)

      if params
        ajaxParams =
          url: "#{lastFM.base_url}#{$.param($.extend(params, {'format': 'json'}))}",
          type: 'POST',
          context: this,
          success: (data)->
            console.log 'scrobbled'
            console.log track
            console.log method

            if data.error and method == 'track.scrobble'
              @handleScrobbleFailure(track)

        $.ajax(ajaxParams)
       else if method == 'track.scrobble'
          @handleScrobbleFailure(track)

  auth:
    sessionID: ->
      localStorage[lastFM.storage.session]

    authToken: ->
      $.parseJSON localStorage[lastFM.storage.token]

    validToken: (token) ->
      if token and token.token
        new Date().getTime() - token.timestamp < 3600 * 1000

    authenticate: () ->
      sId = @sessionID()

      unless sId
        token = @authToken()

        if @validToken(token)
          @requestSession(lastFM.api_key, token.token, false)
        else
          @requestToken(lastFM.api_key)
      sId
    
    sign: (params)->
      sId = @authenticate()

      unless sId
        token = @authToken()
        if @validToken(token)
          @requestSession lastFM.api_key, token.token, false
          sId = @sessionID()

      if sId
        params["sk"] = sId
        params["api_sig"] = @getSignature(params)
        params
      else
        no

    getSignature: (params) ->
      keys = (key for own key, value of params).sort()
      val = ("#{key}#{params[key]}" for key in keys).join("")
      $.md5 "#{val}#{lastFM.secret}"

    requestAuth: (key, token) ->
      window.open("http://last.fm/api/auth?#{$.param({api_key: key, token: token})}")

    requestSession: (key, token, async = true) ->
      return false if not token
      signature = @getSignature({api_key: key, method: 'auth.getSession', token: token})

      ajaxParams =
        url: "#{lastFM.base_url}" +
             "#{$.param({method: "auth.getSession", api_key: key, token: token, api_sig: signature, format: 'json' })}",
        contentType: 'application/xml',
        async: async,
        success: (data)->
          if data.error
            switch data.error.toString()
              when '14'
                localStorage.removeItem lastFM.storage.token
              else
                console.log "Unknow error when fetching session key:"
                console.log data
          else
            localStorage[lastFM.storage.session] = data.session.key
        error: (data) ->
          console.log "could not get session id."
          console.log data

      $.ajax(ajaxParams)

    requestToken: (key) ->
      ajaxParams =
        url: "#{lastFM.base_url}" +
             "#{$.param({method: "auth.getToken", api_key: key, format: 'json' })}",
        context: this,
        success: (data)->
          token =
            token: data.token
            timestamp: new Date().getTime()

          localStorage['onScrobble.authToken'] = JSON.stringify(token)
          @requestAuth key, token.token
        error: (data) ->
          console.log "could not get token."
          console.log data

      $.ajax(ajaxParams)

(exports ? this).lastFM = lastFM

jQuery ($) ->
  unless document.testingOnScrobble
    lastFM.auth.authenticate()

    chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
      console.log request

      switch request.type
        when 'SubmitNowPlaying'
          lastFM.scrobbler.submit request.track, 'track.UpdateNowPlaying'
        when 'Submit'
          lastFM.scrobbler.submit request.track
        else console.log "Unknown message: #{request.type}"
