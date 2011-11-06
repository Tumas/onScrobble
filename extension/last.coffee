lastFM =
  base_url: "http://ws.audioscrobbler.com/2.0/?"
  api_key: "86afa310841f8a1d440b2310b1845b77"
  secret: "a98e0e7d1d10805e9898b483ba396a38"

  auth:
    # authentication flow
    # todo authentication flow
    #   localStorage to store sessionID
    #   localStorage to cache failed scrobbles
    #
    #   authentication flow:
    #     
    #     1. fetch a request token (valid for 60 minutes)
    #     2. with request token, request authorization from the user (api_key, authorization_token)
    #       user grant application permission
    #
    #     3. get a session key (infite lifetime, store it securely. Users are able to revoke privileges 
    #         for your application on Last.fm, redering session key invalid)
    #
    #     4. sign requests with session key + trickery

    sessionID: ->
      localStorage['onScrobble.sessionID']
    
    sign: ->
      sId = @sessionID
      if not sId
        sId = authorize

    authorize: ->
      requestToken lastFM.api_key
      # sessionID
    
    requestAuth: (key, token) ->
      window.open("http://last.fm/api/auth?#{$.param({api_key: key, token: token})}")

    requestSession: (key, token) ->
      $.ajax(
          url: "#{lastFM.base_url}" +
               "#{$.param({method: "auth.getsession", api_key: key, token: token})}",
          success: (data)->
            key = $('key', data).text()
            console.log "Session key: #{key}"
            # save session key for further storage
            
          error: (data) ->
            console.log "could not get token. Reason: #{$('error', data.responseText).text()}"
      )

    requestToken: (key) ->
      $.ajax(
          url: "#{lastFM.base_url}" +
               "#{$.param({method: "auth.gettoken", api_key: key})}",
          success: (data)->
            token = $('token', data).text()
            requestAuth key, token
            requestSession key, token
          error: (data) ->
            console.log "could not get token. Reason: #{$('error', data.responseText).text()}"
      )

jQuery ($) ->
  chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
    console.log "got message!: #{request.type} #{request.track}"
