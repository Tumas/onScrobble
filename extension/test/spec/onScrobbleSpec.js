(function() {
  describe("onScrobble", function() {
    describe("scrobbler", function() {
      return describe("canSubmit", function() {
        it("should let submit track if more that 4 minutes were played", function() {
          expect(onScrobble.scrobbler().canSubmit(4 * 60 + 1, 10 * 60)).toEqual(true);
          return expect(onScrobble.scrobbler().canSubmit(4 * 60, 10 * 60)).toEqual(true);
        });
        it("should let submit track if more than half the tracks duration were played", function() {
          expect(onScrobble.scrobbler().canSubmit(1.5 * 60 + 1, 3 * 60)).toEqual(true);
          return expect(onScrobble.scrobbler().canSubmit(1.5 * 60, 3 * 60)).toEqual(true);
        });
        it("should not let submit the track", function() {
          return expect(onScrobble.scrobbler().canSubmit(60, 3 * 60)).toEqual(false);
        });
        return it("should not let submit the track if less than 30 seconds were played", function() {
          return expect(onScrobble.scrobbler().canSubmit(29, 29)).toEqual(false);
        });
      });
    });
    return describe("soundcloud", function() {
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
  });
}).call(this);
