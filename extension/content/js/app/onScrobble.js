(function() {
  var onScrobble;
  onScrobble = {
    pre: function(code, object) {
      return "var onScrobble = " + code + "();\n onScrobble.load();";
    },
    inject: function(code) {
      var scriptNode, wrap;
      wrap = "function main(){\n" + (this.pre(code)) + "\n}";
      scriptNode = document.createElement("script");
      scriptNode.textContent = "" + wrap + ";\nmain();";
      return document.head.appendChild(scriptNode);
    },
    soundcloud: function() {
      return {
        events: {
          play: "onAudioPlay",
          pause: "onAudioPause"
        },
        timestamp: function() {
          return Math.round(Number(new Date()) / 1000);
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
          idle_time = 0;
          start_play = void 0;
          idle_start = void 0;
          current_track = void 0;
          $(document).bind(onScrobble.events.play, function(info) {
            var trackName;
            trackName = onScrobble.artist(info.track.user.username, info.track.title);
            return console.log("audio played: " + trackName);
          });
          return $(document).bind(onScrobble.events.pause, function(info) {
            var trackName;
            trackName = onScrobble.artist(info.track.user.username, info.track.title);
            return console.log("audio paused: " + trackName);
          });
        }
      };
    }
  };
  (typeof exports !== "undefined" && exports !== null ? exports : this).onScrobble = onScrobble;
  jQuery(function($) {
    var injected;
    injected = onScrobble.soundcloud.toString();
    return onScrobble.inject(injected);
  });
}).call(this);
