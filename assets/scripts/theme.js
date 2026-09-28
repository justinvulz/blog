// Light/dark theme toggle (the button in the header, see `shell` in base.typ).
// The page follows the OS setting by default. Clicking flips to the other
// theme and pins it with <html data-theme="…"> + localStorage; flipping back
// to whatever the OS wants clears the pin, so the site follows the OS again.
// The saved pin is applied before first paint by the inline <script> in
// tola.toml's [site.header].elements.
(function () {
  var root = document.documentElement;
  var prefersDark = window.matchMedia("(prefers-color-scheme: dark)");

  function system() {
    return prefersDark.matches ? "dark" : "light";
  }

  function current() {
    return root.dataset.theme || system();
  }

  function label(button) {
    var next = current() === "dark" ? "light" : "dark";
    button.setAttribute("aria-label", "Switch to " + next + " theme");
    button.title = "Switch to " + next + " theme";
  }

  function init() {
    var button = document.querySelector(".theme-toggle");
    if (!button) return;
    label(button);
    button.addEventListener("click", function () {
      var next = current() === "dark" ? "light" : "dark";
      var pin = next !== system();
      if (pin) root.dataset.theme = next;
      else delete root.dataset.theme;
      try {
        if (pin) localStorage.setItem("theme", next);
        else localStorage.removeItem("theme");
      } catch (e) {}
      label(button);
    });
    prefersDark.addEventListener("change", function () {
      label(button);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
