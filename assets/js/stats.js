// Anonymous site stats sent to Umami (no cookies). Umami itself counts page views,
// referrers, countries and devices; this adds what it can't see on a one-page visit:
// reading time, how far down the page people get, and video plays.
(function () {
  "use strict";

  function track(name, data) {
    if (window.umami && typeof window.umami.track === "function") window.umami.track(name, data);
  }

  var page = location.pathname;

  // Reading time: only while the tab is visible. Sent once, the first time the
  // visitor leaves the page or switches tabs, so it is a lower bound.
  var visibleSince = document.visibilityState === "visible" ? Date.now() : null;
  var activeMs = 0;
  var timeSent = false;

  function bucket(s) {
    if (s < 10) return "0-10 s";
    if (s < 30) return "10-30 s";
    if (s < 60) return "30-60 s";
    if (s < 180) return "1-3 min";
    if (s < 600) return "3-10 min";
    return "10+ min";
  }

  document.addEventListener("visibilitychange", function () {
    if (document.visibilityState === "hidden") {
      if (visibleSince) { activeMs += Date.now() - visibleSince; visibleSince = null; }
      if (!timeSent && activeMs >= 3000) {
        timeSent = true;
        var s = Math.round(activeMs / 1000);
        track("Tiempo en la página", { pagina: page, rango: bucket(s), segundos: String(s) });
      }
    } else {
      visibleSince = Date.now();
    }
  });

  // Sections seen: fires once per section when its top passes the middle of the screen.
  if ("IntersectionObserver" in window) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        track("Sección vista", { pagina: page, seccion: entry.target.id });
        observer.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -50% 0px" });
    document.querySelectorAll("main section[id]").forEach(function (s) { observer.observe(s); });
  }

  // Video: first play and watched to the end.
  document.querySelectorAll("video").forEach(function (video) {
    var played = false;
    video.addEventListener("play", function () {
      if (played) return;
      played = true;
      track("Video reproducido", { pagina: page });
    });
    video.addEventListener("ended", function () { track("Video visto completo", { pagina: page }); });
  });
})();
