describe "onScrobble", ->
  describe "soundcloud", ->
    describe "trackInfo", ->
      it "should set artist, track and duration vlaues", ->
        info = { user: { username: "Overall Triple" }, title: "Overall Triple - Jaku", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "Overall Triple"
        expect(track.track).toEqual "Jaku"
        expect(track.duration).toEqual 406

      it "should work with a long dash", ->
        info = { user: { username: "Overall Triple" }, title: "Overall Triple – Jaku", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "Overall Triple"
        expect(track.track).toEqual "Jaku"
        
      it "should set info when artist is not present", ->
        info = { user: { username: "Nomad Soul Collective" }, title: "murmuration", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "Nomad Soul Collective"
        expect(track.track).toEqual "murmuration"

      it "should set info when multiple dashes are present", ->
        info = { user: { username: "The Funk Hunters" }, title: "See-I - Soul Hit Man (The Funk Hunters Remix)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "See-I"
        expect(track.track).toEqual "Soul Hit Man (The Funk Hunters Remix)"

      it "should not take into account multiple dashes surrounded by spaces", ->
        info = { user: { username: "S.Y. ＤEfＥCtＳ" }, title: "West Is East - Sy Defects - (>><<)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "West Is East"
        expect(track.track).toEqual "Sy Defects"

      it "should decode html entities", ->
        info = { user: { username: "test" }, title: "Essay &amp; Stumbleine - Rhiannon (&quot;buy this track&quot; for DL)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "Essay & Stumbleine"
        expect(track.track).toEqual "Rhiannon (\"buy this track\" for DL)"

      it "should remove prepended artist from track name", ->
        info = { user: { username: "Corbie" }, title: "Corbie-mosquitoes lullaby (excerpt 2011)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "Corbie"
        expect(track.track).toEqual "mosquitoes lullaby (excerpt 2011)"

      it "should be case insensitive", ->
        info = { user: { username: "Corbie" }, title: "corbie-mosquitoes lullaby (excerpt 2011)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "corbie"
        expect(track.track).toEqual "mosquitoes lullaby (excerpt 2011)"

      it "should work with longed dash", ->
        info = { user: { username: "Corbie" }, title: "corbie–mosquitoes lullaby (excerpt 2011)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "corbie"
        expect(track.track).toEqual "mosquitoes lullaby (excerpt 2011)"

      it "should strip track number", ->
        info = { user: { username: "test" }, duration: 406253, title: "04 - bohren & der club of gore - street tattoo" }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "bohren & der club of gore"
        expect(track.track).toEqual "street tattoo"
