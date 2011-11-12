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
        info = { user: { username: "" }, title: "Essay &amp; Stumbleine - Rhiannon (&quot;buy this track&quot; for DL)", duration: 406253 }
        track = onScrobble.trackInfo(info)
        expect(track.artist).toEqual "Essay & Stumbleine"
        expect(track.track).toEqual "Rhiannon (\"buy this track\" for DL)"

    # TODO: when prepended user name and no dash is present 
    #   MAD DOG BOY EXAMPLE
    #
    #   + bug when page click in the middle of the play
