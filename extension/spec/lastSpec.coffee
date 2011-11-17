describe "lastFM", ->
  # todo: signature testing
  # todo: fallback scrobbles + mass scrobling support
  # todo: proper authentication strategy
  
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

  describe "handleScrobbleFailure", ->
    beforeEach ->
      lastFM.storage.fallback = 'testScrobble'

    afterEach ->
      localStorage.removeItem('testScrobble')

    it "should store given track", ->
      lastFM.scrobbler.handleScrobbleFailure(tracks.track1)
      lastFM.scrobbler.handleScrobbleFailure(tracks.track2)
      expect($.parseJSON(localStorage["testScrobble"])).toEqual([tracks.track1, tracks.track2])
 
  describe "subscribe", ->
    request = undefined

    # mock response
    responses =
      serviceOffline200:
        status: 200,
        responseText: '{"error":"11", "message": "This service is temporarily offline. Try again later."}'

    beforeEach  ->
      spyOn(lastFM.auth, 'sessionID').andReturn("fakeSessionID")
      spyOn(lastFM.scrobbler, 'handleScrobbleFailure')
      jasmine.Ajax.useMock()
  
    describe "on failure with code 200 ", ->
      it "should do something", ->
        lastFM.scrobbler.submit tracks.track1
        request = mostRecentAjaxRequest()
        request.response responses.serviceOffline200
        expect(lastFM.scrobbler.handleScrobbleFailure).toHaveBeenCalledWith(tracks.track1)

      it "shouldn't handle failed scrobbles for updateNowPlaying requests", ->
        lastFM.scrobbler.submit tracks.track1, 'track.UpdateNowPlaying'
        request = mostRecentAjaxRequest()
        request.response responses.serviceOffline200
        expect(lastFM.scrobbler.handleScrobbleFailure).not.toHaveBeenCalledWith(tracks.track1)
