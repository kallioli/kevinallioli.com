// The only script on the site. It reads a stored preference, applies it
// before first paint, and reveals the toggle. The site is dark by default,
// in CSS; light is an explicit choice, never the system preference, so the
// toggle has a well-defined state even when nothing is stored.
(function () {
  var root = document.documentElement;
  var KEY = "theme";
  var stored;
  try {
    stored = localStorage.getItem(KEY);
  } catch (e) {}
  if (stored === "light" || stored === "dark") {
    root.setAttribute("data-theme", stored);
  }
  document.addEventListener("DOMContentLoaded", function () {
    var btn = document.getElementById("theme-toggle");
    if (!btn) return;
    btn.hidden = false;
    btn.addEventListener("click", function () {
      var isLight = root.getAttribute("data-theme") === "light";
      var next = isLight ? "dark" : "light";
      root.setAttribute("data-theme", next);
      try {
        localStorage.setItem(KEY, next);
      } catch (e) {}
    });
  });
})();
