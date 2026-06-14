/* =========================================================================
   _nav.js — Barre de navigation partagée (source de vérité unique)
   --------------------------------------------------------------------------
   Chaque page contient un <div data-nav="autobar" class="nav-bar"> ... </div>.
   Ce script remplit TOUTES ces barres avec la même navigation et surligne la
   page courante.
   La nav ne contient QUE l'essentiel : l'accueil + les 2 configs (= les 2
   listes d'achat). Les comparatifs et les fiches de référence (perso, module)
   ne sont PAS dans la nav : on y accède depuis la ligne concernée d'une liste.
   Pour changer la nav : on édite CE fichier, pas les pages.
   ========================================================================= */
(function () {
  "use strict";

  // --- Les 3 destinations : accueil + les 2 listes d'achat ----------------
  var SYNTHESE = [
    { href: "_Accueil.html",                icon: "🏠", label: "Accueil" },
    { href: "Rachat_RECAP-global.html",     icon: "🅑", label: "Ma config backmount" },
    { href: "Rachat_RECAP-sidemount.html",  icon: "🅢", label: "Ma config sidemount" }
  ];

  // --- Nom du fichier courant (gère file://, %20, séparateurs Windows) ----
  function currentFile() {
    var p = (location.pathname || "");
    p = p.split("/").pop().split("\\").pop();
    try { p = decodeURIComponent(p); } catch (e) {}
    return p || "_Accueil.html";
  }

  // --- Échappement minimal pour les libellés ------------------------------
  function esc(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  // --- Rendu d'une ligne de liens -----------------------------------------
  function renderRow(items, here) {
    var out = [];
    for (var i = 0; i < items.length; i++) {
      var it = items[i];
      var txt = (it.icon ? it.icon + " " : "") + esc(it.label);
      if (it.href === here) {
        out.push('<span class="nav-cur">' + txt + "</span>");
      } else {
        out.push('<a href="' + it.href + '" target="_self">' + txt + "</a>");
      }
    }
    return out.join('<span class="nav-sep">·</span>');
  }

  // --- CSS injecté une seule fois -----------------------------------------
  function injectCSS() {
    if (document.getElementById("nav-style")) return;
    var css =
      ".nav-bar{background:linear-gradient(180deg,#0f5e6b,#0a4a55);color:#fff;" +
        "border-radius:8px;padding:11px 16px;margin:0 0 18px;" +
        "font-family:Arial,Helvetica,sans-serif;box-shadow:0 1px 3px rgba(0,0,0,.18)}" +
      ".nav-row1{display:flex;flex-wrap:wrap;align-items:center;gap:6px 8px;font-size:13.5px}" +
      ".nav-bar a{color:#eef8fa;text-decoration:none;font-weight:bold;" +
        "padding:3px 9px;border-radius:5px;white-space:nowrap}" +
      ".nav-bar a:hover{background:rgba(255,255,255,.16);color:#fff}" +
      ".nav-cur{background:#ffd24d;color:#0a3a42;font-weight:bold;" +
        "padding:3px 11px;border-radius:5px;white-space:nowrap}" +
      ".nav-sep{color:rgba(255,255,255,.30);padding:0 1px}" +
      "@media print{.nav-bar{background:#0f5e6b !important;-webkit-print-color-adjust:exact;print-color-adjust:exact}}";
    var st = document.createElement("style");
    st.id = "nav-style";
    st.textContent = css;
    (document.head || document.documentElement).appendChild(st);
  }

  // --- Construction de la barre -------------------------------------------
  function build() {
    var bars = document.querySelectorAll('[data-nav="autobar"]');
    if (!bars.length) return;
    injectCSS();
    var here = currentFile();
    var row1 = '<div class="nav-row1">' + renderRow(SYNTHESE, here) + "</div>";
    for (var i = 0; i < bars.length; i++) {
      bars[i].className = "nav-bar";
      bars[i].innerHTML = row1;
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", build);
  } else {
    build();
  }
})();
