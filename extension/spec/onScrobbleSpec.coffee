describe "onScrobble", ->
  describe "scrobbler", ->
    describe "canSubmit", ->
      it "should let submit track if more than 4 minutes were played", ->
        expect(onScrobble.canSubmit(4*60+1, 10*60)).toEqual true
        expect(onScrobble.canSubmit(4*60, 10*60)).toEqual true

      it "should let submit track if more than half the tracks duration were played", ->
        expect(onScrobble.canSubmit(1.5*60+1, 3*60)).toEqual true
        expect(onScrobble.canSubmit(1.5*60, 3*60)).toEqual true

      it "should not let submit the track", ->
        expect(onScrobble.canSubmit(60, 3*60)).toEqual false

      it "should not let submit the track if less than 30 seconds were played", ->
        expect(onScrobble.canSubmit(29, 29)).toEqual false
