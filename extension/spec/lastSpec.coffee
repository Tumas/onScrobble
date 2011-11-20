describe "lastFM", ->
  # todo: signature testing
  
  ts = 'testScrobble'
  tsf = 'testScrobbleFallback'

  auth = lastFM.auth
  
  beforeEach ->
    lastFM.storage.token = ts
    lastFM.storage.fallback = tsf

  afterEach ->
    localStorage.removeItem ts
    localStorage.removeItem tsf

  # mock response
  responses =
    serviceOffline200:
      error:"11",
      message: "This service is temporarily offline. Try again later."

    serviceOK:
      status: "ok"
  
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

    track3:
        artist: "Mark E"
        duration: 512
        timestamp: 1321711853
        track: "Oranges (Jacques Renault Edit)"


  describe "Scrobbler", ->
    sc = lastFM.scrobbler

    beforeEach ->
      spyOn(auth, 'sessionID').andReturn("fakeSessionID")

    afterEach ->
      $.mockjaxClear()

    describe "submit", ->
      describe "on failure with code 200 ", ->
        it "should save track to cache", ->
          $.mockjax({
            url: 'http://ws.audioscrobbler.com/2.0/?api_key=86afa310841f8a1d440b2310b1845b77&method=track.scrobble&artist=Nomad+Soul+Collective&duration=235&timestamp=1321566320&track=Murmuration&sk=fakeSessionID&api_sig=1f0d17fec79bbd4883856f219d03581c&format=json',
            responseText: responses.serviceOffline200
          })

          sc.submit tracks.track1
          expect(sc.fallbackTracks()).toEqual([tracks.track1])

        it "shouldn't save tracks to cache for failed updateNowPlaying requests", ->
          $.mockjax({
            url: 'http://ws.audioscrobbler.com/2.0/?api_key=86afa310841f8a1d440b2310b1845b77&method=track.UpdateNowPlaying&artist=Nomad+Soul+Collective&duration=235&timestamp=1321566320&track=Murmuration&sk=fakeSessionID&api_sig=edbd50855348da8196b49f54b301680b&format=json',
            responseText: responses.serviceOffline200
          })

          sc.submit tracks.track1, 'track.UpdateNowPlaying'
          expect(sc.fallbackTracks()).toEqual([])

    describe "handleScrobbleFailure", ->
      it "should store given track", ->
        sc.handleScrobbleFailure(tracks.track1)
        sc.handleScrobbleFailure(tracks.track2)
        expect(sc.fallbackTracks()).toEqual([tracks.track1, tracks.track2])

    describe "indexProperties", ->
      it "should index each property", ->
        indexed = sc.indexProperties(tracks.track1, 2)
        expect(indexed['track[2]']).toEqual(tracks.track1['track'])
        expect(indexed['track']).toEqual(undefined)

    describe "submitBatch", ->
      beforeEach  ->
        sc.handleScrobbleFailure(tracks.track1)
        sc.handleScrobbleFailure(tracks.track2)
        sc.handleScrobbleFailure(tracks.track3)

        $.mockjax({
          url: 'http://ws.audioscrobbler.com/2.0/?api_key=86afa310841f8a1d440b2310b1845b77&method=track.scrobble&artist%5B0%5D=Nomad+Soul+Collective&duration%5B0%5D=235&timestamp%5B0%5D=1321566320&track%5B0%5D=Murmuration&artist%5B1%5D=SL1&duration%5B1%5D=126&timestamp%5B1%5D=1321567351&track%5B1%5D=Eclipse+%5Bcut+from+mix%5D&sk=fakeSessionID&api_sig=f6818585c59bed812299e64713e2255d&format=json',
          responseText: responses.serviceOK
        })

      it "should not remove tracks from cache if submit failed", ->
        $.mockjax({
          url: 'http://ws.audioscrobbler.com/2.0/?api_key=86afa310841f8a1d440b2310b1845b77&method=track.scrobble&artist%5B0%5D=Mark+E&duration%5B0%5D=512&timestamp%5B0%5D=1321711853&track%5B0%5D=Oranges+(Jacques+Renault+Edit)&sk=fakeSessionID&api_sig=08b72c71f125e1c37fadb5b0a2f349ec&format=json',
          responseText: responses.serviceOffline200,
        })

        sc.submitBatch(2)
        cachedTracks = sc.fallbackTracks()
        expect(cachedTracks).toEqual([tracks.track3])

      it "should remove tracks for cache if submit", ->
        $.mockjax({
          url: 'http://ws.audioscrobbler.com/2.0/?api_key=86afa310841f8a1d440b2310b1845b77&method=track.scrobble&artist%5B0%5D=Mark+E&duration%5B0%5D=512&timestamp%5B0%5D=1321711853&track%5B0%5D=Oranges+(Jacques+Renault+Edit)&sk=fakeSessionID&api_sig=08b72c71f125e1c37fadb5b0a2f349ec&format=json',
          responseText: responses.serviceOK
        })

        sc.submitBatch(2)
        cachedTracks = sc.fallbackTracks()
        expect(cachedTracks).toEqual([])

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
