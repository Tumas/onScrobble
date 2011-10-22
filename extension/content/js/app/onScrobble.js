(function() {
  var onScrobble, timestamp;
  timestamp = function() {
    return Math.round(Number(new Date()) / 1000);
  };
  onScrobble = {
    events: {
      play: "onPlay",
      pause: "onPause"
    },
    selectors: {
      player: 'div.player',
      user: 'div.info-header span.user a',
      track: 'div.info-header h3 a'
    },
    artist: function(username, track) {
      var trackInfo;
      trackInfo = track;
      if (!track.match(' (-|–) ') && !track.match(new RegExp("^" + username))) {
        trackInfo = "" + username + " - " + track;
      }
      return trackInfo;
    }
  };
  (typeof exports !== "undefined" && exports !== null ? exports : this).onScrobble = onScrobble;
}).call(this);
