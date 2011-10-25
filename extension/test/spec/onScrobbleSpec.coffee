describe "onScrobble", ->
  describe "scrobbler", ->
    describe "canSubmit", ->
      it "should let submit track if more that 4 minutes were played", ->
        expect(onScrobble.scrobbler().canSubmit(4*60+1, 10*60)).toEqual true
        expect(onScrobble.scrobbler().canSubmit(4*60, 10*60)).toEqual true

      it "should let submit track if more than half the tracks duration were played", ->
        expect(onScrobble.scrobbler().canSubmit(1.5*60+1, 3*60)).toEqual true
        expect(onScrobble.scrobbler().canSubmit(1.5*60, 3*60)).toEqual true

      it "should not let submit the track", ->
        expect(onScrobble.scrobbler().canSubmit(60, 3*60)).toEqual false

      it "should not let submit the track if less than 30 seconds were played", ->
        expect(onScrobble.scrobbler().canSubmit(29, 29)).toEqual false

  describe "soundcloud", ->
    describe "artist", ->
      it "should not prepend artist if track starts with an artist", ->
        track = "Ambisonicz -When You Were Mine Feat. Kim English [Out now On Nurvous Records!"
        expect(onScrobble.soundcloud().artist("Ambisonicz", track)).toEqual track

      it "should not prepend artist if it's separated with ' - '", ->
        track = "Ambisonicz - When You Were Mine Feat. Kim English [Out now On Nurvous Records!"
        expect(onScrobble.soundcloud().artist("ambisonicz", track)).toEqual track

      it "should not prepend artist if it's separated with long dash", ->
        track = "Ambisonicz – When You Were Mine Feat. Kim English [Out now On Nurvous Records!"
        expect(onScrobble.soundcloud().artist("ambisonicz", track)).toEqual track

      it "should prepend artist", ->
        expect(onScrobble.soundcloud().artist("indigolab", "Chaos Falls")).toEqual "indigolab - Chaos Falls"


