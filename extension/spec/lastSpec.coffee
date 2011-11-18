describe "lastFM", ->
  # todo: signature testing
  # todo: fallback scrobbles + mass scrobling support
  
  ts = 'testScrobble'
  auth = lastFM.auth
  
  beforeEach ->
    lastFM.storage.token = ts
    lastFM.storage.fallback = ts

  afterEach ->
    localStorage.removeItem ts
  
  tracks =
    track1:
      artist: "Nomad Soul Collective"
      duration: 235
      timestamp: 1321566320
      track: "Murmuration"

    track2:
      artist: "SL1"
      duration: 126
      timestamp: 1321567351
      track: "Eclipse [cut from mix]"


  describe "auth", ->
    token =
      token: "abc"
      timestamp: new Date().getTime()

    describe "authToken", ->
      it "should restore token object", ->
        localStorage[ts] = JSON.stringify token
        expect(auth.authToken()).toEqual(token)

    describe "validToken", ->
      it "should be valid for one hour", ->
        expect(auth.validToken({timestamp: new Date().getTime(), token: "abc"})).toBeTruthy()
        expect(auth.validToken({timestamp: new Date().getTime() - 59 * 60 * 1000, token: "abc"})).toBeTruthy()

      it "should not be valid after one hour", ->
        expect(auth.validToken({timestamp: new Date().getTime() - 60 * 60 * 1000, token: "abc"})).toBeFalsy()
        expect(auth.validToken({timestamp: new Date().getTime() - 61 * 60 * 1000, token: "abc"})).toBeFalsy()

      it "should not be valid", ->
        expect(auth.validToken({timestamp: new Date().getTime()})).toBeFalsy()
        expect(auth.validToken({})).toBeFalsy()
        expect(auth.validToken()).toBeFalsy()
        expect(auth.validToken({token: "abc"})).toBeFalsy()

      it "should be valid from taken from storage", ->
        localStorage[ts] = JSON.stringify token
        expect(auth.validToken(auth.authToken())).toBeTruthy()


  describe "Scrobbler", ->
    sc = lastFM.scrobbler

    describe "handleScrobbleFailure", ->
      it "should store given track", ->
        sc.handleScrobbleFailure(tracks.track1)
        sc.handleScrobbleFailure(tracks.track2)
        expect($.parseJSON(localStorage[ts])).toEqual([tracks.track1, tracks.track2])

   
    describe "scrobble", ->
      request = undefined

      # mock response
      responses =
        serviceOffline200:
          status: 200,
          responseText: '{"error":"11", "message": "This service is temporarily offline. Try again later."}'

      beforeEach  ->
        spyOn(auth, 'sessionID').andReturn("fakeSessionID")
        spyOn(sc, 'handleScrobbleFailure')
        jasmine.Ajax.useMock()
    
      describe "on failure with code 200 ", ->
        it "should do something", ->
          lastFM.scrobbler.submit tracks.track1
          request = mostRecentAjaxRequest()
          request.response responses.serviceOffline200
          expect(sc.handleScrobbleFailure).toHaveBeenCalledWith(tracks.track1)

        it "shouldn't handle failed scrobbles for updateNowPlaying requests", ->
          lastFM.scrobbler.submit tracks.track1, 'track.UpdateNowPlaying'
          request = mostRecentAjaxRequest()
          request.response responses.serviceOffline200
          expect(sc.handleScrobbleFailure).not.toHaveBeenCalledWith(tracks.track1)
