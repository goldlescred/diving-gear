/*
 * generate.js — générateur déterministe des pages HTML matériel de plongée.
 *
 * Source de vérité UNIQUE : gear.db (SQLite).
 * Modules NATIFS uniquement : node:sqlite, node:fs, node:path. Aucune dépendance npm.
 *
 * Aucune valeur (prix / poids / total) n'est codée en dur : tout vient de requêtes SQL.
 * Les fonctions de rendu (en-tête, nav, CSS, helpers) sont PARTAGÉES pour garantir
 * la cohérence entre toutes les pages.
 *
 * Modèle : 4 devis (2 BCD + thermique + accessoires). Un setup complet = 1 BCD + thermique + accessoires.
 *
 * Exécution : node generate.js
 * (un avertissement ExperimentalWarning concernant node:sqlite est normal et sans gravité)
 */

'use strict';

const { DatabaseSync } = require('node:sqlite');
const fs = require('node:fs');
const path = require('node:path');

const ROOT = __dirname;
const DB_PATH = path.join(ROOT, 'gear.db');

const db = new DatabaseSync(DB_PATH);

/* ------------------------------------------------------------------ */
/* Helpers de formatage / échappement (PARTAGÉS)                       */
/* ------------------------------------------------------------------ */

// Échappement HTML maison sur TOUT texte issu de la base.
function esc(value) {
  if (value === null || value === undefined) return '';
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// Formatage d'un nombre € (déterministe, séparateur fin d'espace, virgule décimale FR).
const NBSP = ' '; // espace insécable (typographie FR)
function fmtEur(n) {
  if (n === null || n === undefined) return '';
  const rounded = Math.round(Number(n) * 100) / 100;
  const [intPart, decPart] = rounded.toFixed(2).split('.');
  const grouped = intPart.replace(/\B(?=(\d{3})+(?!\d))/g, NBSP);
  const dec = decPart === '00' ? '' : ',' + decPart.replace(/0$/, '');
  return grouped + dec + NBSP + '€';
}

// Formatage d'un poids kg (déterministe, virgule décimale FR).
function fmtKg(n) {
  if (n === null || n === undefined) return '';
  const rounded = Math.round(Number(n) * 1000) / 1000;
  let s = rounded.toFixed(3).replace(/0+$/, '').replace(/\.$/, '');
  s = s.replace('.', ',');
  return s + NBSP + 'kg';
}

// Prix affiché : price_text si présent sinon price_eur formaté.
function priceDisplay(item) {
  if (item.price_text != null && String(item.price_text).trim() !== '') {
    return esc(item.price_text);
  }
  if (item.price_eur != null) return fmtEur(item.price_eur);
  return '<span class="na">—</span>';
}

// Poids affiché : weight_text si présent sinon weight_kg formaté.
function weightDisplay(item) {
  if (item.weight_text != null && String(item.weight_text).trim() !== '') {
    return esc(item.weight_text);
  }
  if (item.weight_kg != null) return fmtKg(item.weight_kg);
  return '<span class="na">—</span>';
}

// Vignette image produit (lien direct constructeur). Vide -> placeholder discret.
function imgThumb(item) {
  if (item.image_url && String(item.image_url).trim() !== '') {
    return `<img class="thumb" src="${esc(item.image_url)}" alt="${esc(
      (item.brand || '') + ' ' + (item.model || '')
    )}" loading="lazy" referrerpolicy="no-referrer">`;
  }
  return '<span class="noimg">—</span>';
}

// Lien vers la fiche constructeur. Vide si absent.
function mfrCell(item, label) {
  if (item.mfr_link && String(item.mfr_link).trim() !== '') {
    return `<a href="${esc(item.mfr_link)}" target="_blank" rel="noopener">${esc(
      label || 'Fiche constructeur'
    )}</a>`;
  }
  return '';
}

// Photo mise en valeur (devis) : cliquable vers la fiche constructeur si dispo.
function equipPhoto(item) {
  const alt = esc((item.brand || '') + ' ' + (item.model || ''));
  const img =
    item.image_url && String(item.image_url).trim() !== ''
      ? `<img class="ephoto" src="${esc(item.image_url)}" alt="${alt}" loading="lazy" referrerpolicy="no-referrer">`
      : '<span class="ephoto noimg">—</span>';
  if (item.mfr_link && String(item.mfr_link).trim() !== '') {
    return `<a class="ephoto-link" href="${esc(item.mfr_link)}" target="_blank" rel="noopener" title="Fiche constructeur">${img}</a>`;
  }
  return img;
}

// Nom de l'équipement, lien vers la fiche constructeur si dispo (sinon texte simple).
function equipName(item) {
  const name = `${esc(item.brand)} ${esc(item.model)}`;
  if (item.mfr_link && String(item.mfr_link).trim() !== '') {
    return `<a href="${esc(item.mfr_link)}" target="_blank" rel="noopener">${name}</a>`;
  }
  return name;
}

/* ------------------------------------------------------------------ */
/* Métadonnées d'affichage des devis (libellé court + classe couleur)  */
/* ------------------------------------------------------------------ */

const CONFIG_META = {
  bcd_backmount: { short: 'Backmount BCD', cls: 'bm' },
  bcd_sidemount: { short: 'Sidemount BCD', cls: 'sm' },
  thermal:       { short: 'Thermique',     cls: 'th' },
  accessories:   { short: 'Accessoires',   cls: 'ac' },
};
function cfgMeta(id) {
  return CONFIG_META[id] || { short: id, cls: 'bm' };
}

// Setups complets = combinaisons de devis (présentation : sommes calculées).
const COMBOS = [
  { label: 'Setup complet — Backmount', parts: ['bcd_backmount', 'thermal', 'accessories'], cls: 'bm' },
  { label: 'Setup complet — Sidemount', parts: ['bcd_sidemount', 'thermal', 'accessories'], cls: 'sm' },
];

/* ------------------------------------------------------------------ */
/* Template PARTAGÉ : CSS + en-tête + nav + pied de page               */
/* ------------------------------------------------------------------ */

const CSS = `
  :root{--teal:#0f5e6b;--teal2:#13788a;--ink:#1c2b30;--line:#e3e9eb;--bg:#f4f7f8;--muted:#6a7a7d;
        --green:#1e7e34;--gold:#9a6a00;--slate:#5a6b6e;--bm:#e7f1f3;--sm:#fbf2dd;--pick:#eef7f4}
  *{box-sizing:border-box}
  body{font-family:Arial,Helvetica,sans-serif;color:var(--ink);margin:0;background:var(--bg);line-height:1.45}
  a{color:var(--teal2)}
  .nav{background:var(--teal);color:#fff;padding:0 18px}
  .nav .inner{max-width:1100px;margin:0 auto;display:flex;gap:4px;flex-wrap:wrap;align-items:center}
  .nav a{color:#fff;text-decoration:none;font-size:13.5px;font-weight:bold;padding:13px 14px;display:inline-block}
  .nav a:hover{background:rgba(255,255,255,.12)}
  .nav a.active{background:rgba(255,255,255,.20)}
  .wrap{max-width:1100px;margin:0 auto;padding:22px 18px 60px}
  h1{font-size:25px;margin:6px 0 2px;color:var(--ink)}
  .lead{color:var(--muted);font-size:13.5px;margin:2px 0 22px}
  h2{font-size:20px;margin:2px 0 10px;color:var(--teal)}
  h3{font-size:14px;color:#fff;background:var(--teal);padding:8px 13px;border-radius:6px;margin:26px 0 12px;
     display:flex;align-items:center;gap:8px}
  h3 .count{margin-left:auto;font-size:11px;font-weight:normal;background:rgba(255,255,255,.18);padding:2px 9px;border-radius:20px}
  /* Cartes devis (accueil) */
  .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(244px,1fr));gap:16px;margin:0 0 22px}
  .cfg{background:#fff;border:1px solid var(--line);border-top:5px solid var(--teal);border-radius:12px;
       padding:18px 20px;box-shadow:0 2px 8px rgba(15,94,107,.08);display:flex;flex-direction:column}
  .cfg.bm{border-top-color:var(--teal)}
  .cfg.sm{border-top-color:var(--gold)}
  .cfg.th{border-top-color:var(--green)}
  .cfg.ac{border-top-color:var(--slate)}
  .cfg .kicker{font-size:11px;font-weight:bold;letter-spacing:.6px;text-transform:uppercase;color:var(--muted)}
  .cfg h2{font-size:19px;margin:2px 0 10px}
  .cfg.sm h2{color:var(--gold)}
  .cfg.th h2{color:var(--green)}
  .cfg.ac h2{color:var(--slate)}
  .tot{display:flex;gap:22px;margin:6px 0 4px}
  .tot .big{font-size:23px;font-weight:bold;color:var(--ink)}
  .tot .lbl{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px}
  .split{font-size:12px;color:var(--muted);margin:10px 0 0;border-top:1px dashed var(--line);padding-top:9px}
  .split b{color:var(--ink)}
  .split .row{display:flex;justify-content:space-between;padding:2px 0}
  .cfg .go{margin-top:auto;padding-top:15px}
  .btn{display:inline-block;background:var(--teal);color:#fff;text-decoration:none;font-weight:bold;
       font-size:13.5px;padding:10px 16px;border-radius:8px}
  .cfg.sm .btn{background:var(--gold)}
  .cfg.th .btn{background:var(--green)}
  .cfg.ac .btn{background:var(--slate)}
  .btn:hover{filter:brightness(1.08)}
  /* Setups complets */
  .combos{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:12px;margin:0 0 24px}
  .combo{background:#fff;border:1px solid var(--line);border-left:5px solid var(--teal);border-radius:10px;padding:13px 16px}
  .combo.sm{border-left-color:var(--gold)}
  .combo .ttl{font-weight:bold;color:var(--ink);font-size:14px}
  .combo .big{font-size:20px;font-weight:bold;color:var(--teal)}
  .combo.sm .big{color:var(--gold)}
  .combo .parts{font-size:11.5px;color:var(--muted);margin-top:4px}
  /* Grille de liens comparatifs */
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:10px}
  .card{display:block;background:#fff;border:1px solid var(--line);border-radius:9px;padding:11px 14px;
        text-decoration:none;color:inherit;transition:transform .08s ease,box-shadow .12s ease,border-color .12s ease}
  .card:hover{transform:translateY(-2px);box-shadow:0 4px 14px rgba(15,94,107,.16);border-color:#bcd7dc}
  .card .t{font-weight:bold;color:var(--teal);font-size:13.5px;display:block;margin-bottom:2px}
  .card .d{color:var(--muted);font-size:11.5px;display:block}
  /* Tableaux */
  table{border-collapse:collapse;width:100%;background:#fff;font-size:12.5px;margin:0 0 8px;
        border:1px solid var(--line);border-radius:8px;overflow:hidden}
  thead th{background:var(--teal);color:#fff;text-align:left;padding:8px 10px;font-size:11.5px;
           font-weight:bold;border-right:1px solid rgba(255,255,255,.15)}
  tbody td{padding:7px 10px;border-top:1px solid var(--line);border-right:1px solid var(--line);vertical-align:top}
  tbody tr:nth-child(even){background:#fafcfc}
  td.num,th.num{text-align:right;white-space:nowrap}
  .na{color:var(--muted)}
  .thumb{width:52px;height:52px;object-fit:contain;background:#fff;border:1px solid var(--line);border-radius:6px;display:block}
  td .thumb{margin:0 auto}
  .noimg{color:var(--muted);font-size:11px}
  .equip{display:flex;gap:13px;align-items:center}
  .ephoto{width:72px;height:72px;object-fit:contain;background:#fff;border:1px solid var(--line);border-radius:8px;display:block;padding:4px}
  .ephoto-link{display:inline-block;line-height:0}
  .ephoto-link:hover .ephoto{border-color:var(--teal);box-shadow:0 2px 10px rgba(15,94,107,.20)}
  span.ephoto{width:72px;height:72px;display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:11px}
  .equip-name{font-size:13.5px;font-weight:bold}
  .equip-name a{color:var(--teal2);text-decoration:none}
  .equip-name a:hover{text-decoration:underline}
  .pick{background:var(--pick)!important}
  .badges{display:flex;gap:5px;flex-wrap:wrap;margin-top:3px}
  .badge{font-size:10px;font-weight:bold;padding:2px 7px;border-radius:20px;white-space:nowrap}
  .badge.bm{background:var(--teal);color:#fff}
  .badge.sm{background:var(--gold);color:#fff}
  .badge.th{background:var(--green);color:#fff}
  .badge.ac{background:var(--slate);color:#fff}
  .notdispo{opacity:.62}
  .tag{font-size:10px;font-weight:bold;padding:1px 6px;border-radius:4px;background:#eef4f5;color:var(--muted)}
  .tag.no{background:#fbe9e9;color:#a33}
  .subtotal td{background:#eef4f5;font-weight:bold;border-top:2px solid var(--teal)}
  .grandtotal td{background:var(--teal);color:#fff;font-weight:bold;font-size:13.5px}
  .grandtotal a{color:#fff}
  .secwrap{margin-bottom:26px}
  footer{margin-top:34px;padding-top:14px;border-top:1px solid var(--line);font-size:11.5px;color:var(--muted)}
  @media print{.card,.cfg,.combo{box-shadow:none}.nav{display:none}}
`;

// Barre de nav IDENTIQUE sur chaque page, construite dynamiquement depuis les devis.
// `current` = nom de fichier actif.
function nav(current) {
  const links = [['index.html', 'Accueil']].concat(
    configs.map((c) => [`liste-${c.id}.html`, cfgMeta(c.id).short])
  );
  const items = links
    .map(([href, label]) => {
      const cls = href === current ? ' class="active"' : '';
      return `      <a href="${href}"${cls}>${esc(label)}</a>`;
    })
    .join('\n');
  return `<nav class="nav"><div class="inner">\n${items}\n    </div></nav>`;
}

// Squelette HTML PARTAGÉ. `current` pilote la nav active.
function page(current, title, bodyHtml) {
  return `<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<style>${CSS}</style>
</head>
<body>
${nav(current)}
<div class="wrap">
${bodyHtml}
<footer>Page générée automatiquement par <code>generate.js</code> depuis <code>gear.db</code>. Ne pas éditer à la main.</footer>
</div>
</body>
</html>
`;
}

// Lien externe revendeur (target=_blank). Vide si pas de lien.
function buyLink(item, label) {
  if (!item.link || String(item.link).trim() === '') return '<span class="na">—</span>';
  return `<a href="${esc(item.link)}" target="_blank" rel="noopener">${esc(label || 'Voir')}</a>`;
}

function comparatifFile(categoryId) {
  return `comparatif-${categoryId}.html`;
}

/* ------------------------------------------------------------------ */
/* Requêtes SQL (toutes les valeurs proviennent d'ici)                 */
/* ------------------------------------------------------------------ */

// Ordre fixe et libellés des sections (couvre tous les devis).
const SECTION_ORDER = ['stab', 'poches', 'detendeurs', 'instrumentation', 'rigging', 'protection', 'accessoires'];
const SECTION_LABEL = {
  stab: 'Stab / wing',
  poches: 'Poches de lest',
  detendeurs: 'Détendeurs',
  instrumentation: 'Instrumentation',
  rigging: 'Gréement & fixations',
  protection: 'Protection thermale',
  accessoires: 'Accessoires',
};
function sectionRank(section) {
  const i = SECTION_ORDER.indexOf(section);
  return i === -1 ? 99 : i;
}
function sectionLabel(s) {
  return SECTION_LABEL[s] || s;
}

const categories = db
  .prepare('SELECT id, label, sort FROM category ORDER BY sort, id')
  .all();

const categoryCounts = (() => {
  const m = new Map();
  for (const r of db
    .prepare('SELECT category_id, COUNT(*) n FROM item GROUP BY category_id')
    .all()) {
    m.set(r.category_id, r.n);
  }
  return m;
})();

const configs = db.prepare('SELECT id, label, sort FROM config ORDER BY sort, id').all();

// Totaux par devis calculés en SQL.
const configTotals = (() => {
  const m = new Map();
  const rows = db
    .prepare(
      `SELECT ci.config_id,
              SUM(i.price_eur * ci.qty)  AS price_eur,
              SUM(i.weight_kg * ci.qty)  AS weight_kg
       FROM config_item ci
       JOIN item i ON i.id = ci.item_id
       GROUP BY ci.config_id`
    )
    .all();
  for (const r of rows) m.set(r.config_id, r);
  return m;
})();

// Nombre de postes (lignes) par devis — pour une info uniforme sur les cartes d'accueil.
const configPosteCounts = (() => {
  const m = new Map();
  for (const r of db.prepare('SELECT config_id, COUNT(*) n FROM config_item GROUP BY config_id').all()) {
    m.set(r.config_id, r.n);
  }
  return m;
})();

// Sous-totaux par devis + section, calculés en SQL.
const sectionTotalsByConfig = (() => {
  const m = new Map(); // config_id -> Map(section -> {price,weight})
  const rows = db
    .prepare(
      `SELECT ci.config_id, ci.section,
              SUM(i.price_eur * ci.qty) AS price_eur,
              SUM(i.weight_kg * ci.qty) AS weight_kg
       FROM config_item ci
       JOIN item i ON i.id = ci.item_id
       GROUP BY ci.config_id, ci.section`
    )
    .all();
  for (const r of rows) {
    if (!m.has(r.config_id)) m.set(r.config_id, new Map());
    m.get(r.config_id).set(r.section, r);
  }
  return m;
})();

// Lignes détaillées d'un devis (jointure complète), triées section puis sort catégorie.
const configItemsStmt = db.prepare(
  `SELECT ci.config_id, ci.section, ci.qty,
          i.id AS item_id, i.brand, i.model,
          i.price_eur, i.price_text, i.weight_kg, i.weight_text,
          i.region, i.available, i.link, i.image_url, i.mfr_link,
          c.id AS category_id, c.label AS category_label, c.sort AS category_sort
   FROM config_item ci
   JOIN item i ON i.id = ci.item_id
   JOIN category c ON c.id = i.category_id
   WHERE ci.config_id = ?`
);
function configItems(configId) {
  const rows = configItemsStmt.all(configId);
  rows.sort((a, b) => {
    const s = sectionRank(a.section) - sectionRank(b.section);
    if (s !== 0) return s;
    if (a.category_sort !== b.category_sort) return a.category_sort - b.category_sort;
    return a.item_id < b.item_id ? -1 : a.item_id > b.item_id ? 1 : 0;
  });
  return rows;
}

// Items d'une catégorie pour le comparatif, triés : dispo EU d'abord puis price_eur asc (NULL en dernier), puis non-dispo.
const itemsByCatStmt = db.prepare(
  `SELECT id, brand, model, price_eur, price_text, weight_kg, weight_text,
          region, dir, use_reco, specs, link, image_url, mfr_link, available
   FROM item WHERE category_id = ?`
);
function itemsForCategory(catId) {
  const rows = itemsByCatStmt.all(catId);
  rows.sort((a, b) => {
    if (a.available !== b.available) return b.available - a.available;
    const ap = a.price_eur, bp = b.price_eur;
    if (ap == null && bp == null) {
      return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
    }
    if (ap == null) return 1;
    if (bp == null) return -1;
    if (ap !== bp) return ap - bp;
    return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
  });
  return rows;
}

// Pour chaque item : dans quels devis est-il choisi ? (pour surlignage comparatif)
const itemConfigs = (() => {
  const m = new Map(); // item_id -> Set(config_id)
  for (const r of db.prepare('SELECT DISTINCT item_id, config_id FROM config_item').all()) {
    if (!m.has(r.item_id)) m.set(r.item_id, new Set());
    m.get(r.item_id).add(r.config_id);
  }
  return m;
})();

/* ------------------------------------------------------------------ */
/* Rendu : index.html                                                  */
/* ------------------------------------------------------------------ */

function renderIndex() {
  // Cartes par devis.
  const cards = configs
    .map((cfg) => {
      const tot = configTotals.get(cfg.id) || { price_eur: 0, weight_kg: 0 };
      const meta = cfgMeta(cfg.id);
      const postes = configPosteCounts.get(cfg.id) || 0;
      // Structure IDENTIQUE sur les 4 cartes : titre, prix+poids, ligne "Postes", bouton (aligné en bas).
      return `    <div class="cfg ${meta.cls}">
      <div class="kicker">Devis</div>
      <h2>${esc(cfg.label)}</h2>
      <div class="tot">
        <div><div class="big">${fmtEur(tot.price_eur)}</div><div class="lbl">Prix</div></div>
        <div><div class="big">${fmtKg(tot.weight_kg)}</div><div class="lbl">Poids</div></div>
      </div>
      <div class="split"><div class="row"><span>Postes</span><b>${postes}</b></div></div>
      <div class="go"><a class="btn" href="liste-${esc(cfg.id)}.html">Voir le devis &rarr;</a></div>
    </div>`;
    })
    .join('\n');

  // Setups complets (combinaisons de devis), totaux sommés depuis les totaux par devis.
  const combos = COMBOS.map((combo) => {
    let eur = 0, kg = 0;
    const partLabels = [];
    for (const p of combo.parts) {
      const t = configTotals.get(p);
      if (t) { eur += t.price_eur || 0; kg += t.weight_kg || 0; }
      partLabels.push(cfgMeta(p).short);
    }
    return `    <div class="combo ${combo.cls}">
      <div class="ttl">${esc(combo.label)}</div>
      <div class="big">${fmtEur(eur)} · ${fmtKg(kg)}</div>
      <div class="parts">${esc(partLabels.join(' + '))}</div>
    </div>`;
  }).join('\n');

  // Grille de liens vers TOUS les comparatifs.
  const links = categories
    .map((c) => {
      const n = categoryCounts.get(c.id) || 0;
      return `    <a class="card" href="${esc(comparatifFile(c.id))}">
      <span class="t">${esc(c.label)}</span>
      <span class="d">${n} ${n > 1 ? 'modèles comparés' : 'modèle'}</span>
    </a>`;
    })
    .join('\n');

  const body = `<h1>Matériel de plongée — comparatifs &amp; devis</h1>
<p class="lead">Quatre devis indépendants (2 BCD + protection thermale + accessoires) et le comparatif détaillé de chaque poste. Toutes les valeurs sont calculées depuis la base.</p>

<div class="cards">
${cards}
</div>

<h3>Setups complets <span class="count">1 BCD + thermique + accessoires</span></h3>
<div class="combos">
${combos}
</div>

<h3>Comparatifs par poste <span class="count">${categories.length} catégories</span></h3>
<div class="grid">
${links}
</div>`;

  return page('index.html', 'Matériel de plongée — accueil', body);
}

/* ------------------------------------------------------------------ */
/* Rendu : liste-<config>.html (un devis)                              */
/* ------------------------------------------------------------------ */

function renderListe(cfg) {
  const rows = configItems(cfg.id);
  const secMap = sectionTotalsByConfig.get(cfg.id) || new Map();
  const tot = configTotals.get(cfg.id) || { price_eur: 0, weight_kg: 0 };

  const bySection = new Map();
  for (const r of rows) {
    if (!bySection.has(r.section)) bySection.set(r.section, []);
    bySection.get(r.section).push(r);
  }

  const head = `      <thead><tr>
        <th>Catégorie</th>
        <th>Équipement</th>
        <th class="num">Qté</th>
        <th class="num">Prix unit.</th>
        <th class="num">Poids unit.</th>
        <th class="num">Sous-total €</th>
        <th class="num">Sous-total kg</th>
        <th>Achat</th>
      </tr></thead>`;

  const sections = SECTION_ORDER.filter((s) => bySection.has(s))
    .map((s) => {
      const items = bySection.get(s);
      const st = secMap.get(s) || { price_eur: 0, weight_kg: 0 };
      const trs = items
        .map((r) => {
          const lineEur = r.price_eur != null ? r.price_eur * r.qty : null;
          const lineKg = r.weight_kg != null ? r.weight_kg * r.qty : null;
          const catCell = `<a href="${esc(comparatifFile(r.category_id))}">${esc(
            r.category_label
          )}</a>`;
          const equip = `<div class="equip">${equipPhoto(r)}<div class="equip-name">${equipName(
            r
          )}</div></div>`;
          return `        <tr>
          <td>${catCell}</td>
          <td>${equip}</td>
          <td class="num">${r.qty}</td>
          <td class="num">${priceDisplay(r)}</td>
          <td class="num">${weightDisplay(r)}</td>
          <td class="num">${lineEur != null ? fmtEur(lineEur) : '<span class="na">—</span>'}</td>
          <td class="num">${lineKg != null ? fmtKg(lineKg) : '<span class="na">—</span>'}</td>
          <td>${buyLink(r, 'Acheter')}</td>
        </tr>`;
        })
        .join('\n');
      return `  <div class="secwrap">
    <h3>${esc(sectionLabel(s))} <span class="count">${items.length} poste${
        items.length > 1 ? 's' : ''
      }</span></h3>
    <table>
${head}
      <tbody>
${trs}
        <tr class="subtotal">
          <td colspan="5">Sous-total ${esc(sectionLabel(s))}</td>
          <td class="num">${fmtEur(st.price_eur)}</td>
          <td class="num">${fmtKg(st.weight_kg)}</td>
          <td></td>
        </tr>
      </tbody>
    </table>
  </div>`;
    })
    .join('\n');

  const grand = `  <table>
      <tbody>
        <tr class="grandtotal">
          <td colspan="5">TOTAL DEVIS — ${esc(cfg.label)}</td>
          <td class="num">${fmtEur(tot.price_eur)}</td>
          <td class="num">${fmtKg(tot.weight_kg)}</td>
          <td></td>
        </tr>
      </tbody>
    </table>`;

  const body = `<h1>Devis — ${esc(cfg.label)}</h1>
<p class="lead">Détail poste par poste. Cliquez un choix pour ouvrir son comparatif. Prix et poids calculés depuis la base.</p>
${sections}
${grand}`;

  return page(`liste-${cfg.id}.html`, `Devis — ${cfg.label}`, body);
}

/* ------------------------------------------------------------------ */
/* Rendu : comparatif-<category>.html                                  */
/* ------------------------------------------------------------------ */

function renderComparatif(cat) {
  const items = itemsForCategory(cat.id);
  const hasDir = items.some((i) => i.dir != null && String(i.dir).trim() !== '');

  const headCols = [
    '<th>Photo</th>',
    '<th>Marque</th>',
    '<th>Modèle</th>',
    '<th>Usage recommandé</th>',
    '<th>Spécifications</th>',
  ];
  if (hasDir) headCols.push('<th>DIR</th>');
  headCols.push('<th>Région</th>');
  headCols.push('<th class="num">Prix</th>');
  headCols.push('<th class="num">Poids</th>');
  headCols.push('<th>Liens</th>');

  const trs = items
    .map((i) => {
      const inConfigs = itemConfigs.get(i.id) || new Set();
      const classes = [];
      if (i.available === 0) classes.push('notdispo');
      if (inConfigs.size > 0) classes.push('pick');

      // Un badge par devis qui retient cet item (ordre des devis).
      const badges = [];
      for (const cfg of configs) {
        if (inConfigs.has(cfg.id)) {
          const m = cfgMeta(cfg.id);
          badges.push(`<span class="badge ${m.cls}">★ ${esc(m.short)}</span>`);
        }
      }
      const badgeHtml = badges.length ? `<div class="badges">${badges.join('')}</div>` : '';

      const dispoTag =
        i.available === 1
          ? '<span class="tag">EU dispo</span>'
          : '<span class="tag no">Import</span>';

      const cols = [
        `<td>${imgThumb(i)}</td>`,
        `<td>${esc(i.brand)}</td>`,
        `<td>${esc(i.model)}${badgeHtml}</td>`,
        `<td>${esc(i.use_reco) || '<span class="na">—</span>'}</td>`,
        `<td>${esc(i.specs) || '<span class="na">—</span>'}</td>`,
      ];
      if (hasDir) cols.push(`<td>${esc(i.dir) || '<span class="na">—</span>'}</td>`);
      cols.push(`<td>${esc(i.region) ? esc(i.region) + ' ' : ''}${dispoTag}</td>`);
      cols.push(`<td class="num">${priceDisplay(i)}</td>`);
      cols.push(`<td class="num">${weightDisplay(i)}</td>`);
      {
        const rev = buyLink(i, 'Revendeur');
        const mfr = mfrCell(i, 'Constructeur');
        cols.push(`<td>${rev}${mfr ? '<br>' + mfr : ''}</td>`);
      }

      const clsAttr = classes.length ? ` class="${classes.join(' ')}"` : '';
      return `        <tr${clsAttr}>
          ${cols.join('\n          ')}
        </tr>`;
    })
    .join('\n');

  const body = `<h1>Comparatif — ${esc(cat.label)}</h1>
<p class="lead">${items.length} modèle${
    items.length > 1 ? 's' : ''
  } comparé${items.length > 1 ? 's' : ''}. Tri : disponibles en Europe d'abord, par prix croissant. Les lignes surlignées sont retenues dans un devis.</p>
<table>
      <thead><tr>${headCols.join('')}</tr></thead>
      <tbody>
${trs}
      </tbody>
    </table>`;

  return page(comparatifFile(cat.id), `Comparatif — ${cat.label}`, body);
}

/* ------------------------------------------------------------------ */
/* Écriture des fichiers                                               */
/* ------------------------------------------------------------------ */

const written = [];
function writePage(filename, html) {
  const out = path.join(ROOT, filename);
  fs.writeFileSync(out, html, 'utf8');
  written.push(filename);
}

// 1. index
writePage('index.html', renderIndex());

// 2. un devis par config
for (const cfg of configs) {
  writePage(`liste-${cfg.id}.html`, renderListe(cfg));
}

// 3. comparatifs par catégorie (toutes les catégories de la table)
for (const cat of categories) {
  writePage(comparatifFile(cat.id), renderComparatif(cat));
}

/* ------------------------------------------------------------------ */
/* Récapitulatif console                                               */
/* ------------------------------------------------------------------ */

console.log('Pages générées :', written.length);
for (const f of written) console.log('  -', f);
console.log('Totaux par devis (depuis la base) :');
for (const cfg of configs) {
  const t = configTotals.get(cfg.id) || { price_eur: 0, weight_kg: 0 };
  console.log(`  ${cfg.id} : ${t.price_eur} € , ${t.weight_kg} kg`);
}
console.log('Setups complets :');
for (const combo of COMBOS) {
  let eur = 0, kg = 0;
  for (const p of combo.parts) {
    const t = configTotals.get(p);
    if (t) { eur += t.price_eur || 0; kg += t.weight_kg || 0; }
  }
  console.log(`  ${combo.label} : ${Math.round(eur * 100) / 100} € , ${Math.round(kg * 1000) / 1000} kg`);
}

db.close();
