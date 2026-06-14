/*
 * build_media.js — transforme la sortie du workflow fetch-item-media en media.sql.
 * Usage : node build_media.js <chemin-output-workflow>
 * Produit media.sql (UPDATE item SET image_url/mfr_link ... WHERE id=...).
 * media.sql s'applique APRÈS build_db.sql :
 *   sqlite3 gear.db < build_db.sql && sqlite3 gear.db < media.sql
 */
'use strict';
const fs = require('node:fs');

const outPath = process.argv[2];
if (!outPath) { console.error('Usage: node build_media.js <output-file>'); process.exit(1); }

const data = JSON.parse(fs.readFileSync(outPath, 'utf8'));
const cats = (data.result && data.result.categories) || data.categories || [];

// Décode les entités HTML qui ont pu fuiter dans les URLs (surtout &amp;).
function dec(s) {
  if (s == null) return s;
  return String(s)
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>');
}
function sq(s) { return "'" + String(s).replace(/'/g, "''") + "'"; }
const isUrl = (u) => typeof u === 'string' && /^https?:\/\//i.test(u.trim());

const lines = [
  '-- media.sql — images + liens constructeur (généré depuis le workflow fetch-item-media).',
  '-- Appliquer APRÈS build_db.sql :  sqlite3 gear.db < build_db.sql && sqlite3 gear.db < media.sql',
  'BEGIN;',
];

let nItems = 0, nImg = 0, nMfr = 0;
const perCat = {};
for (const c of cats) {
  const cat = c.category || '?';
  perCat[cat] = perCat[cat] || { img: 0, mfr: 0, tot: 0 };
  for (const it of (c.items || [])) {
    nItems++; perCat[cat].tot++;
    const img = dec(it.image_url);
    const mfr = dec(it.mfr_link);
    const sets = [];
    if (isUrl(img)) { sets.push('image_url=' + sq(img.trim())); nImg++; perCat[cat].img++; }
    if (isUrl(mfr)) { sets.push('mfr_link=' + sq(mfr.trim())); nMfr++; perCat[cat].mfr++; }
    if (sets.length) lines.push('UPDATE item SET ' + sets.join(', ') + ' WHERE id=' + sq(it.id) + ';');
  }
}
lines.push('COMMIT;');
fs.writeFileSync('media.sql', lines.join('\n') + '\n');

console.log(`media.sql écrit — ${nItems} items traités | ${nImg} images | ${nMfr} liens constructeur`);
console.log('Couverture par catégorie (images / total · liens / total) :');
for (const k of Object.keys(perCat).sort()) {
  const p = perCat[k];
  console.log(`  ${k.padEnd(16)} ${p.img}/${p.tot} img · ${p.mfr}/${p.tot} liens`);
}
