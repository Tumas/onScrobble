describe "onScrobble", ->
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

