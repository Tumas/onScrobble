(function() {
  var onScrobble;
  onScrobble = {
    pre: function(code) {
      return "var onScrobble = " + code + "();";
    },
    inject: function(code, generic) {
      var scriptNode, wrap;
      wrap = "function main(){\n" + (this.pre(code)) + "\n onScrobble.scrobbler = " + generic + "();\nonScrobble.load();\n}";
      scriptNode = document.createElement("script");
      scriptNode.textContent = "" + wrap + ";\nmain();";
      return document.head.appendChild(scriptNode);
    },
    scrobbler: function() {
      return {
        canSubmit: function(timePlayed, duration) {
          return timePlayed >= 30 && (timePlayed >= duration / 2 || timePlayed >= 60 * 4);
        },
        secondify: function(ts) {
          return Math.round(Number(ts / 1000));
        },
        submit: function(track) {}
      };
    },
    soundcloud: function() {
      return {
        events: {
          play: "onAudioPlay",
          pause: "onAudioPause",
          finish: "onAudioFinish",
          playStart: "onAudioPlayStart"
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
          var duration, finish_submit, idle_start, idle_time, start_time, track;
          idle_time = 0;
          idle_start = void 0;
          start_time = void 0;
          track = void 0;
          duration = 0;
          finish_submit = false;
          $(document).bind(onScrobble.events.play, function(info) {
            if (idle_start) {
              idle_time += info.timeStamp - idle_start;
              return idle_start = void 0;
            }
          });
          $(document).bind(onScrobble.events.pause, function(info) {
            return idle_start = info.timeStamp;
          });
          $(document).bind(onScrobble.events.finish, function(info) {
            var play_time;
            play_time = onScrobble.scrobbler.secondify(info.timeStamp - idle_time - start_time);
            if (onScrobble.scrobbler.canSubmit(play_time, duration)) {
              console.log("Submitting: " + track);
              return finish_submit = true;
            }
          });
          return $(document).bind(onScrobble.events.playStart, function(info) {
            var play_time, trackName;
            trackName = onScrobble.artist(info.track.user.username, info.track.title);
            if (idle_start) {
              idle_time += info.timeStamp - idle_start;
            }
            play_time = onScrobble.scrobbler.secondify(info.timeStamp - idle_time - start_time);
            if (!finish_submit && onScrobble.scrobbler.canSubmit(play_time, duration)) {
              console.log("Submitting: " + track);
            }
            console.log("Now playing: " + trackName);
            idle_time = 0;
            idle_start = void 0;
            start_time = info.timeStamp;
            finish_submit = false;
            track = trackName;
            return duration = onScrobble.scrobbler.secondify(info.track.duration);
          });
        }
      };
    }
  };
  (typeof exports !== "undefined" && exports !== null ? exports : this).onScrobble = onScrobble;
  jQuery(function($) {
    var generic, injected;
    injected = onScrobble.soundcloud.toString();
    generic = onScrobble.scrobbler.toString();
    return onScrobble.inject(injected, generic);
  });
}).call(this);
