lastFM =
  base_url: "http://ws.audioscrobbler.com/2.0/?"
  api_key: "86afa310841f8a1d440b2310b1845b77"
  secret: "a98e0e7d1d10805e9898b483ba396a38"

  auth:
    sessionID: ->
      localStorage['onScrobble.sessionID']

    authToken: ->
      localStorage['onScrobble.authToken']
    
    sign: ->
      sId = @sessionID()

      unless sId
        @requestToken(lastFM.api_key)

        # request session Id for new token
        @requestSession lastFM.api_key, @authToken()
        sId = @sessionID()

      if sId
        console.log "Scrobble!: #{sId}"
      else
        console.log "could not get sessionID"
      console.log "SEssion id: #{sId}"

    requestAuth: (key, token) ->
      window.open("http://last.fm/api/auth?#{$.param({api_key: key, token: token})}")
      
    getSignature: (params) ->
      val = ("#{key}#{value}" for own key, value of params).join("")
      console.log "#{val}#{lastFM.secret}"
      $.md5("#{val}#{lastFM.secret}")

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
            console.log "Session key: #{key}"
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
    console.log "got message!: #{request.type} #{request.track}"
    console.log lastFM.auth.sign()
    console.log lastFM
