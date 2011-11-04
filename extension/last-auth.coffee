# authentication for last.fm
#   this should be tested and modular

lastFMAuth: ->
  base_url: "http://ws.audioscrobbler.com/2.0/?"
  api_key: "86afa310841f8a1d440b2310b1845b77"
  secret: "a98e0e7d1d10805e9898b483ba396a38"

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
    localStorage.getItem 'sessionID'
  
  sign: ->
    # if session id is present -> sign
    # otherwise fetch it
    #todo
    
  requestToken: (key) ->
    $.ajax(
        url: "#{onScrobble.scrobbler.base_url}" +
             "#{$.param({method: "auth.gettoken", api_key: key})}",
        success: (data)->
          token = $('token', data).text()
          @token = token
          @requestAuth key, token
          @requestSession key, token
        error: (data) ->
          console.log "could not get token. Reason: #{$('error', data.responseText).text()}"
    )
  
  requestAuth: (key, token) ->
    window.open("http://last.fm/api/auth?#{$.param({api_key: key, token: token})}")

  requestSession: (key, token) ->
    $.ajax(
        url: "#{onScrobble.scrobbler.base_url}" +
             "#{$.param({method: "auth.getsession", api_key: key, token: token})}",
        success: (data)->
          key = $('key', data).text()
          console.log "Session key: #{key}"
        error: (data) ->
          console.log "could not get token. Reason: #{$('error', data.responseText).text()}"
    )
