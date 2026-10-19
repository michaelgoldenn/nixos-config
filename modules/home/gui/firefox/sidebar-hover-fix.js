
// Collapse the expand-on-hover sidebar when the pointer leaves the window.
// Firefox only knows the last mouse position it saw inside the window, so leaving
// through the sidebar's edge (e.g. onto another monitor) leaves it stuck expanded.
try {
  Services.obs.addObserver((win) => {
    win.addEventListener("DOMContentLoaded", () => {
      if (win.location.href !== "chrome://browser/content/browser.xhtml") return;
      win.addEventListener("mouseout", (e) => {
        if (e.relatedTarget) return; // still inside the window
        // run after MousePosTracker has recorded the exit position, then override it
        win.setTimeout(() => {
          const tracker = win.MousePosTracker;
          if (!tracker) return;
          tracker._x = tracker._y = -1e6;
          tracker._listeners.forEach((l) => tracker._callListener(l));
        }, 0);
      });
    }, { once: true });
  }, "chrome-document-global-created");
} catch (e) {
  Cu.reportError(e);
}
