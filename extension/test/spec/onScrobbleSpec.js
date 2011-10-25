(function() {
  describe("onScrobble", function() {
    return describe("artist", function() {
      it("should not prepend artist if track starts with an artist", function() {
        var track;
        track = "Ambisonicz -When You Were Mine Feat. Kim English [Out now On Nurvous Records!";
        return expect(onScrobble.soundcloud().artist("Ambisonicz", track)).toEqual(track);
      });
      it("should not prepend artist if it's separated with ' - '", function() {
        var track;
        track = "Ambisonicz - When You Were Mine Feat. Kim English [Out now On Nurvous Records!";
        return expect(onScrobble.soundcloud().artist("ambisonicz", track)).toEqual(track);
      });
      it("should not prepend artist if it's separated with long dash", function() {
        var track;
        track = "Ambisonicz – When You Were Mine Feat. Kim English [Out now On Nurvous Records!";
        return expect(onScrobble.soundcloud().artist("ambisonicz", track)).toEqual(track);
      });
      return it("should prepend artist", function() {
        return expect(onScrobble.soundcloud().artist("indigolab", "Chaos Falls")).toEqual("indigolab - Chaos Falls");
      });
    });
  });
}).call(this);
