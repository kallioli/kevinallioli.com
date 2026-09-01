// The only script on the site. It reads a stored preference, applies it
// before first paint, and reveals the toggle. With JavaScript off the
// toggle stays hidden and the system preference decides, in CSS.
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
      var current = root.getAttribute("data-theme");
      var isDark = current
        ? current === "dark"
        : window.matchMedia("(prefers-color-scheme: dark)").matches;
      var next = isDark ? "light" : "dark";
      root.setAttribute("data-theme", next);
      try {
        localStorage.setItem(KEY, next);
      } catch (e) {}
    });
  });
})();
