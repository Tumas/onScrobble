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
    },
    load: function() {
      var current_track, idle_start, idle_time, start_play;
      start_play = void 0;
      idle_start = void 0;
      idle_time = 0;
      current_track = void 0;
      console.log("onScrobble loaded");
      console.log($(onScrobble.selectors.played).size());
      return $(onScrobble.selectors.player).each(function(index, el) {
        var song;
        song = onScrobble.artist($(onScrobble.selectors.user, $(el)).text(), $(onScrobble.selectors.track, $(el)).text());
        $(el).bind(onScrobble.events.play, function() {
          var current, time_played;
          console.log("event play: " + song);
          current = timestamp();
          if (idle_start) {
            idle_time += current - idle_start;
            idle_start = void 0;
          }
          if (!current_track || current_track !== song) {
            time_played = 0;
            if (start_play) {
              time_played = current - stat_play;
              time_played -= idle_time;
              console.log("Song played: " + time_played + " seconds");
              console.log("Idle time was: " + idle_time + " seconds");
            }
          }
          start_play = current;
          idle_time = 0;
          return current_track = song;
        });
        return $(el).bind(onScrobble.events.pause, function() {
          console.log("event.pause: " + song);
          return idle_start = current;
        });
      });
    }
  };
  (typeof exports !== "undefined" && exports !== null ? exports : this).onScrobble = onScrobble;
  $(function() {
    onScrobble.load();
    return console.log("load test");
  });
}).call(this);
