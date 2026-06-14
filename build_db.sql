-- =====================================================================
--  gear.db — base de données matériel de plongée (source unique)
--  Un élément = UNE ligne. Prix (€) et poids (kg) canoniques.
--  Les listes d'achat (configs) référencent ces lignes -> totaux calculés.
--  Reconstruire :  sqlite3 gear.db < build_db.sql
-- =====================================================================
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS config_item;
DROP TABLE IF EXISTS config;
DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS category;

CREATE TABLE category (
  id    TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  sort  INTEGER NOT NULL
);

CREATE TABLE item (
  id          TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES category(id),
  brand       TEXT NOT NULL,
  model       TEXT NOT NULL,
  price_eur   REAL,            -- prix canonique en € (NULL si US / inconnu)
  price_text  TEXT,            -- affichage (fourchette, "US", etc.)
  weight_kg   REAL,            -- poids canonique en kg (NULL si inconnu)
  weight_text TEXT,
  region      TEXT,            -- EU / US / UK / DE / FR
  dir         TEXT,            -- évaluation DIR si pertinent
  use_reco    TEXT,            -- usage recommandé / caractéristiques clés
  specs       TEXT,            -- spécifications complémentaires
  link        TEXT,            -- lien REVENDEUR (achat)
  image_url   TEXT,            -- URL image produit (constructeur) — rempli par media.sql
  mfr_link    TEXT,            -- lien page produit CONSTRUCTEUR — rempli par media.sql
  available   INTEGER NOT NULL DEFAULT 1  -- 1 = achetable EU, 0 = non dispo / import
);

CREATE TABLE config (
  id    TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  sort  INTEGER NOT NULL
);

CREATE TABLE config_item (
  config_id TEXT NOT NULL REFERENCES config(id),
  section   TEXT NOT NULL,        -- systeme / perso / accessoires
  item_id   TEXT NOT NULL REFERENCES item(id),
  qty       INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (config_id, item_id)
);

-- ---------------------------------------------------------------------
INSERT INTO category (id,label,sort) VALUES
 ('bcd_backmount','BCD backmount (single tank)',1),
 ('bcd_sidemount','Stab sidemount',2),
 ('first_stage','Détendeur — 1er étage',3),
 ('second_stage','Détendeur — 2e étage',4),
 ('mask','Masques',5),
 ('fins','Palmes',6),
 ('wetsuit','Combinaisons',7),
 ('baselayer','Sous-couches thermiques',8),
 ('boots','Bottillons & chaussettes',9),
 ('computer','Ordinateurs',10),
 ('light','Lampes primaires',11),
 ('bag','Sacs de transport',12),
 ('protection','Protection des fragiles',13),
 ('compass','Compas',14),
 ('dsmb','DSMB / parachute',15),
 ('spool','Spools',16),
 ('cutter','Coupe-ligne',17),
 ('wetnotes','Wetnotes',18),
 ('boltsnap','Bolt snaps',19),
 ('sm_kit','Sidemount — gréement & poches',20);

-- ============================ BCD BACKMOUNT ==========================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,weight_text,region,dir,use_reco,specs,link,available) VALUES
 ('bcd-halcyon-pro-era30','bcd_backmount','Halcyon','Pro Single Cylinder + Era 30',1190,'1 190–1 210 €',4.0,'~4 kg','EU','✅','Système carbone monté (SET)','Platine carbone 0,54 kg + STA carbone + harnais Cinch deluxe + aile Era 30 (4 poches lest)','https://www.dive24.store/en/product-page/halcyon-eclipse-pro-wingsystem',1),
 ('bcd-tecline-donut15','bcd_backmount','Tecline','Donut 15 + harnais DIR',599,'599 € (+385 plaque carbone)',2.8,'~2,8 kg','EU','✅','Set alu, plaque carbone en option','Donut 15 + harnais DIR continu','https://www.diveavenue.com/en/tecline/1215-wing-donut-15-tecline-harness-dir.html',1),
 ('bcd-dirzone-ring','bcd_backmount','DIRZone','RING Wing Set Single',625,'~620–630 €',2.0,'~1,9–2,1 kg','EU','✅','Set complet alu léger','Plaque alu 0,75 kg','https://www.divesupport.de/en/dir-zone-ring-wing-set-single/400590',1),
 ('bcd-xdeep-zen-ul','bcd_backmount','xDeep','NX Zen Ultralight Standard',628.99,NULL,3.0,'~3 kg','EU','✅ (Standard)','Set voyage alu-magnésium',NULL,'https://www.tradeinn.com/diveinn/en/xdeep-zen-ultralight-standard-without-weight-pockets-wing/136806313/p',1),
 ('bcd-finnsub-fly-ul','bcd_backmount','Finnsub','FLY Ultralite Set',639,NULL,2.5,'~2,5 kg','EU','✅','Set voyage alu',NULL,'https://www.diveavenue.com/en/finnsub/239-travel-wing-finnsub-ultralite-set.html',1),
 ('bcd-oms-mono32','bcd_backmount','OMS','Plaque + harnais + Performance Mono 32',523,'~523 €',2.5,'~2,5 kg','EU','✅','À assembler (3 réf.)','Plaque alu 0,79 kg','https://www.tradeinn.com/diveinn/en/oms-performance-mono-wing-32-lbs/137602208/p',1),
 ('bcd-diverite-xtlite','bcd_backmount','Dive Rite','XT Lite + TransPlate + Voyager',625,'~625 €',2.7,'~2,7 kg','EU','✅','À assembler, plaque inox','Inox 1,18 kg (pas de carbone)','https://www.gidivestore.com/eu/en/single-tank-wings/dive-rite-voyager-with-elbow-12-black.html',1),
 ('bcd-audaxpro-imbraco','bcd_backmount','Audax Pro','Imbraco Stealth alu + Sacca 16',469,'~469 €',2.5,'~2,5 kg','EU','🟡','Sur-mesure 10-15 j, sacca monocellule','Plaque alu 0,23 kg','https://www.audaxpro.com/product-page/im-2010-imbraco-stealth-con-piastra-alluminio-col-nero',1),
 ('bcd-scubapro-stek-pure','bcd_backmount','Scubapro','S-Tek Pure',664,'664 € alu / 779 € set inox',2.9,'~2,9 kg (alu)','EU','✅ (Pure)','Set inox ou alu (2 réf.)',NULL,'https://www.lucasdivestore.com/en/scubapro-s-tek-pure-system.html',1),
 ('bcd-maresxr-rec-trim','bcd_backmount','Mares XR','XR-Rec Trim Single',468.99,NULL,2.8,'2,8 kg','EU','🟡','Set, harnais rembourré','Plaque alu skeleton 0,75 kg','https://www.lucasdivestore.com/en/mares-xr-rec-trim-single-backmount-set.html',1),
 ('bcd-apeks-wtx-d30','bcd_backmount','Apeks','WTX-D30 + plaque alu',719,NULL,3.3,'~3,3 kg','EU','✅','Set en stock','Plaque alu 6061 0,78 kg','https://www.planet-plongee.fr/plongee-tek/7072-kit-apeks-wtxd30-ou-d40-plaque-et-harnais-3665771064858.html',1),
 ('bcd-hollis-st-elite','bcd_backmount','Hollis','ST Elite Travel',680,'680 € (+380 ST35)',2.85,'~2,7–3 kg','EU','🟡','Travel alu 10 kg, harnais réglable','Plaque alu 1,0 kg','https://www.sous-la-mer.com/hollis-st-elite-travel-system-noir-md-lg-15655655-modele3.html',1),
 ('bcd-deep6-single','bcd_backmount','Deep 6','Single Tank BP/W Package',NULL,'~490 $',3.3,'~3–3,6 kg','US','✅','Import US (pas de revendeur EU)','Plaque alu','https://www.deep6gear.com/deep-6-single-tank-backplate-and-wing-package.html',0),
 ('bcd-zeagle-30lb','bcd_backmount','Zeagle','30 LB Backplate Combo',NULL,'650 $',3.3,'~3,3 kg','US','✅','Import US, inox','Plaque inox','https://www.zeagle.com/product/bcd-components/backplate-haress-systems/backplate-combo-pack/',0);

-- ============================ BCD SIDEMOUNT ==========================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,weight_text,region,dir,use_reco,specs,link,available) VALUES
 ('sm-xdeep-stealth-20-tec','bcd_sidemount','xDeep','Stealth 2.0 TEC',619,'589–619 €',2.8,'2,8 kg','EU','✅','Intégré, sangle continue DIR, wing latéral souple','Portance 19 kg','https://www.palanquee.com/harnais-sidemount-stealth-2-0-tec-xdeep',1),
 ('sm-razor-4','bcd_sidemount','Razor','Razor 4 Complete',889,NULL,1.26,'1,26 kg (harnais)','EU','✅','Modulaire, bi-vessie redondante','Portance ~16 kg x2','https://razorgosidemount.eu/en/product/razor-4-side-mount-system-complete/',1),
 ('sm-diverite-nomad-ray','bcd_sidemount','Dive Rite','Nomad Ray',729.92,NULL,2.6,'2,6 kg','EU','✅','Intégré, 3 poches lest, quincaillerie inox','Portance 19 kg','https://www.gidivestore.com/eu/en/sidemount-sets/dive-rite-nomad-ray.html',1),
 ('sm-hollis-katana2','bcd_sidemount','Hollis','SMS Katana 2',578.99,NULL,3.6,'3,6 kg','EU','✅','Intégré, aile trapézoïdale, mounts CCR natifs','Portance 18 kg','https://www.tradeinn.com/diveinn/fr/hollis-bcd-sms-katana-2/137186444/p',1),
 ('sm-dtd-diamond','bcd_sidemount','DTD / DIRZone','DIAMOND',462,'~462 €',2.4,'~2,4 kg','EU','✅','Modulaire, sangle continue + mini-plaques trim, certifié CE','Portance 13 kg (L)','https://jonasdive.com/en/complete-wings/289-dtd-diamond.html',1),
 ('sm-tecline-side16','bcd_sidemount','Tecline','SIDE 16 Avenger',553.50,NULL,3.5,'~3,5 kg (avec lest)','EU','✅','Intégré, Cordura 2000D, 4 poches lest','Portance 16 kg','https://www.diveavenue.com/en/bcd-and-wings-sidemount/2884-tecline-sidemount-side16.html',1),
 ('sm-oms-sidestream27','bcd_sidemount','OMS','SideStream 27',559,NULL,3.16,'3,16 kg','EU','🟡','Intégré softpack, vessie arrière unique (back-inflate)','Portance 12,25 kg','https://www.sidemountshop.de/en/p/oms-sidestream-27',1),
 ('sm-maresxr-pure-light','bcd_sidemount','Mares XR','Pure Light Sidemount Set',370.99,NULL,2.75,'~2,5–3 kg','EU','✅','Modulaire, vessie souple bas-profil, ferrures alu','Portance 10 kg','https://www.tradeinn.com/diveinn/en/mares-xr-pure-light-bcd-jacket/137086810/p',1),
 ('sm-halcyon-zero-gravity','bcd_sidemount','Halcyon','Zero Gravity',799,NULL,2.15,'~1,8–2,5 kg','EU','✅','Intégré, wing en U, sangle continue cinch','Portance 12,25 kg','https://www.diveavenue.com/en/bcd-and-wings-sidemount/2920-halcyon-zero-gravity-side-mount-system.html',1),
 ('sm-scubapro-xtek','bcd_sidemount','Scubapro','X-TEK Sidemount',885,'~885 €',2.35,'~2,2–2,5 kg','EU','✅','Modulaire, harnais Airnet + wing 12/20 L','Portance 12 ou 20 kg','https://diving2000.com/shop/18-bcd/9082-scubapro-x-tek-sidemount-wing-12l/',1),
 ('sm-apeks-wsx45','bcd_sidemount','Apeks','WSX-45',999,NULL,3.0,'~3 kg','EU','🟡','Intégré, plaque inox 2 pièces, harnais non continu','Portance ~12 kg','https://www.diveboutik.com/stab-tek/1823-harnais-sidemount-apeks-wsx-45.html',1),
 ('sm-finnsub-fly-side','bcd_sidemount','Finnsub','FLY SIDE',890,NULL,3.85,'3,85 kg (alu)','EU','✅','Modulaire backplate alu, wing harmonica plat','Portance 12,45 kg','https://www.finnsub.com/en/sidemount-wings/fly-side',1),
 ('sm-subgravity-diamond','bcd_sidemount','SubGravity','Diamond Sidemount',NULL,'569 $',2.9,'~2,9 kg','US','✅','Souple intégré, DIR/cave','Portance 8-13 kg','https://divecenter.com/subgravity-diamond-sidemount-system/',0),
 ('sm-utd-zsystem','bcd_sidemount','UTD','Z-System / Z-Trim PRO',NULL,'899 $',1.5,'~1,5 kg','US','✅','Modulaire, signé Georgitsis','Portance 13-20 kg','https://www.utdscubaequipment.com/product-page/z-single-tank-system-complete-recreational-side-mount',0);

-- ============================ 1er ÉTAGE ==============================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,weight_text,region,dir,use_reco,specs,link,available) VALUES
 ('fs-scubapro-mk19-evo','first_stage','Scubapro','MK19 EVO BT (DIN)',430,'≈ 430 €',0.665,'665 g','EU','★★★★★','Membrane scellée balancée, top sidemount','Turret pivotant 5 LP (4+1 axial) + 2 HP, anti-givre','https://www.lucasdivestore.com/en/scubapro-mk19-evo-first-stage.html',1),
 ('fs-apeks-evx200','first_stage','Apeks','EVX200',599,'599 €',0.690,'≈ 690 g',NULL,'★★★★★','Membrane sur-compensée scellée','ACD + échangeur, 5 LP / 2 HP orientés','https://www.lucasdivestore.com/en/apeks-evx200-first-stage.html',1),
 ('fs-scubapro-mk17-evo2','first_stage','Scubapro','MK17 EVO 2',370,'≈ 370 €',0.625,'625 g','EU','🟡','Membrane scellée, turret FIXE (ne pivote pas)','4 LP / 2 HP, anti-givre','https://www.lucasdivestore.com/en/scubapro-mk17-evo-first-stage.html',1),
 ('fs-scubapro-mk25-evo','first_stage','Scubapro','MK25 EVO',320,'≈ 320 €',0.570,'570 g','EU','✅','Piston XTIS non scellé','5 LP turret pivotant / 2 HP','https://www.lucasdivestore.com/en/scubapro-mk25-evo-first-stage.html',1),
 ('fs-hollis-dcx','first_stage','Hollis','DCX',330,'≈ 330 €',0.660,'≈ 660 g','EU','✅','Membrane sur-compensée scellée, pièces gratuites à vie','5 LP turret / 2 HP','https://shop.seaturtle.at/atemregler/1-2-stufe/hollis-200lx-dcx.html',1),
 ('fs-halcyon-h75p','first_stage','Halcyon','H-75P',420,'≈ 420 €',0.600,'≈ 600 g','EU','✅','Piston balancé anti-givre','5 LP turret pivotant / 2 HP','https://www.halcyon.net/',1),
 ('fs-atomic-t3','first_stage','Atomic','T3',1349,'1 349 €',NULL,'titane (set ≈ 734 g)','EU','✅','Piston Jet Seat scellé usine, titane massif','5 LP turret / 2 HP','https://www.lucasdivestore.com/en/atomic-aquatics-t3-din-first-stage-only.html',1),
 ('fs-deep6-signature','first_stage','Deep 6','Signature',390,'~390 € ($399)',0.650,'≈ 650 g','US','✅','Membrane scellée balancée','5 LP turret / 2 HP, SAV faible en EU','https://www.deep6gear.com/',0);

-- ============================ 2e ÉTAGE ===============================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,weight_text,region,dir,use_reco,specs,link,available) VALUES
 ('ss-scubapro-g260','second_stage','Scubapro','G260 BT',396,'396 €',0.275,'275 g','EU','★★★★★','Full métal, respiration ★★★★★, réversible sidemount','Switch venturi + molette dureté','https://www.tradeinn.com/diveinn/en/scubapro-g260-2nd-stage-regulator/59345/p',1),
 ('ss-apeks-evx200','second_stage','Apeks','EVX200',299,'299 €',0.260,'≈ 260 g','EU','★★★★★','Techno-polymère + métal, réversible','Switch VAD + molette','https://www.lucasdivestore.com/fr/apeks-evx200-deuxieme-etage.html',1),
 ('ss-scubapro-a700','second_stage','Scubapro','A700 Carbon',710,'710 € (standard ≈ 361 €)',0.265,'265 g','EU','★★★★','Métal + capot carbone, réversible','Switch venturi + molette','https://www.bubble-diving.com/plonge/deuxieme-etage-a700-carbon-black-tech.html',1),
 ('ss-scubapro-s620ti','second_stage','Scubapro','S620 Ti',388,'388 €',0.179,'179 g','EU','★★★★','Fût titane, très léger, réversible','Switch VIVA (pas de molette)','https://boulogne-plongee.fr/1552-2eme-etage-s620-ti.html',1),
 ('ss-halcyon-halo','second_stage','Halcyon','Halo',289,'289 €',0.270,'≈ 270 g','EU','★★★★★','Métal/composite, réversible','Switch ACV + réglable','https://www.diveavenue.com/en/halcyon/1897-halcyon-halo-2nd-stage-regulator.html',1),
 ('ss-hollis-200lx','second_stage','Hollis','200LX',300,'~300 €',0.273,'273 g','EU','★★★★','Laiton PVD, réversible sans outil','Molette de dureté','https://shop.seaturtle.at/atemregler/1-2-stufe/hollis-200lx-dcx.html',1),
 ('ss-atomic-tfx','second_stage','Atomic','TFX',NULL,'vendu en set complet',0.385,'≈ 385 g (avec flexible)',NULL,'★★★','Titane, échappement frontal, NON réversible','Automatique (ni switch ni molette)','https://www.atomicaquatics.com/products/regulators/tfx/',1),
 ('ss-scubapro-s600','second_stage','Scubapro','S600',299,'299 €',0.193,'193 g','EU','★★★★','Métal + techno-polymère, réversible (ancien)','Switch venturi + molette','https://www.techniplongee.fr/deuxieme-etage-detendeur-plongee-sous-marine/53-detendeur-2eme-etage-s600-scubapro.html',1),
 ('ss-scubapro-d420','second_stage','Scubapro','D420',299,'299 €',0.216,'216 g','EU','★★★','Techno-polymère réversible','Switch + molette','https://www.techniplongee.fr/detendeurs-de-plongee-sous-marine/1793-detendeur-2eme-etage-d420-scubapro.html',1);

-- ============================ MASQUES ================================
INSERT INTO item (id,category_id,brand,model,price_eur,weight_kg,region,use_reco,link,available) VALUES
 ('mask-tusa-zensee-pro','mask','TUSA','ZenSee Pro (M-1010S)',179,NULL,'EU','Verre CrystalView anti-reflet UV420, low-profile, jupe noire','https://www.lucasdivestore.com/fr/tusa-zensee-pro-masque-m1010s.html',1),
 ('mask-fourthelement-seeker','mask','Fourth Element','Seeker (Contrast)',175,NULL,'EU','Champ quasi-naturel, verres proches du visage, jupe noire','https://www.diveavenue.com/en/diving-masks/3741-fourth-element-seeker-mask.html',1),
 ('mask-atomic-venom','mask','Atomic','Venom Frameless',166.99,NULL,'EU','Verre Schott Superwite, jupe Gummi Bear, garantie 30 ans','https://www.sous-la-mer.com/atomic-aquatics-venom-frameless-diving-mask-noir-9291988-modele3.html',1),
 ('mask-apeks-vx1','mask','Apeks','VX1 (Pure View)',129,NULL,'EU','Ultra low-vol, jupe silicone noire chirurgicale','https://www.diveboutik.com/masque-plongee/1831-masque-apeks-vx1-verre-pure-view.html',1),
 ('mask-oms-tattoo','mask','OMS','Tattoo (UltraClear)',93.99,NULL,'EU','Ultra low-vol, double silicone, sangle 3D — DIR','https://www.tradeinn.com/diveinn/en/oms-tatto-western-ultra-clear-diving-mask/137602318/p',1),
 ('mask-halcyon-univision','mask','Halcyon','UniVision (mono)',92.50,NULL,'EU','Verre trempé, jupe noire, low-vol','https://www.lucasdivestore.com/en/halcyon-univision-mask.html',1),
 ('mask-scubapro-frameless','mask','Scubapro','Frameless (Classic)',85,NULL,'EU','Volume très faible, jupe noire, vidage facile','https://www.diveboutik.com/masque-plongee/462-masque-scubapro-frameless-noir.html',1),
 ('mask-diverite-es155','mask','Dive Rite','ES155 UltraClear',68,NULL,'EU','Verre UltraClear, double silicone, low-vol — DIR','https://www.tradeinn.com/diveinn/en/dive-rite-es155-diving-mask/137056016/p',1),
 ('mask-hollis-m1','mask','Hollis','M1 Frameless',89,0.2,'EU','Verre Saint-Gobain, ultra-bas volume, jupe noire — tech/DIR','https://www.diveavenue.com/en/hollis/301-diving-mask-m1-hollis.html',1),
 ('mask-poseidon-blackline','mask','Poseidon','Black Line (LVSL)',85.95,NULL,'EU','Verre incliné, ultra-low-vol, tout-noir, jupe extra-deep','https://www.tek-diver-shop.de/Diving-Mask-Black-Line-Mask-from-Poseidon',1),
 ('mask-beuchat-maxlux','mask','Beuchat','Maxlux S',67.90,NULL,'EU','127 cm3 très bas volume, jupe anallergique, panoramique','https://www.nootica.com/mask-beuchat-maxlux-s-black.html',1),
 ('mask-xsscuba-crew','mask','XS Scuba','Crew Frameless',63.49,NULL,'EU','Double feather-edge, jupe noire, large champ','https://www.tradeinn.com/diveinn/en/xs-scuba-crew-silicone-diving-mask/139068010/p',1),
 ('mask-oceanic-shadow','mask','Oceanic','Shadow',59,NULL,'EU','Ultra low-vol, jupe noire, plie à plat','https://www.diveavenue.com/fr/masques/525-1695-masque-oceanic-shadow-black-ou-clear.html',1),
 ('mask-seac-pura','mask','Seac Sub','Pura (Anti-Fog)',54.99,NULL,'EU','Antibuée plasma, jupe noire, boucle 3D','https://www.nootica.com/seac-sub-pura-anti-fog-diving-mask-black.html',1),
 ('mask-c4-skyline','mask','C4 Carbon','Skyline',54.90,NULL,'EU','Antibuée plasma permanent, panoramique, jupe noire','https://globalneoprene.com/fr/masque-de-plongee/2864-masque-plongee-100-antibuee-c4-skyline-monoverre.html',1),
 ('mask-sherwood-rona','mask','Sherwood','Rona',49,NULL,'EU','Verre trempé, jupe noire, low-vol','https://ruhrpottdivers-onlineshop.de/Sherwood-Maske-Rona',1),
 ('mask-aqualung-plazma','mask','Aqua Lung','Plazma',48.90,NULL,'EU','Low-vol, jupe noir/blanc, profil récréatif','https://www.bubble-diving.com/plonge/masque-plazma-aqualung.html',1),
 ('mask-cressi-f1','mask','Cressi','F1 Frameless',36.90,0.15,'EU','Volume très réduit, jupe noire, vidange facile (masque de secours)','https://www.subchandlers.com/3192-masque-de-plongee-f1-cressi.html',1),
 ('mask-divesoft-sentry','mask','Divesoft','Sentry',68,NULL,'EU','Verre trempé, jupe noire, low-vol, grand champ','https://eshop.divesoft.com/sentry-mask/3900',1),
 ('mask-tecline-superview','mask','Tecline','Frameless Super View',62.96,NULL,'EU','170° FOV, jupe noire, boucles métal, orienté tech','https://katalog.tecline.com.pl/en/products/tecline/masks/masks,2,5197',1),
 ('mask-genesis-sigma','mask','Genesis','Sigma',75,NULL,'US','Mono frameless low-vol, jupe noire (value US)','https://www.genesisscuba.com/product-catalog?productId=209',0),
 ('mask-ndiver-classic','mask','Northern Diver','Classic Frameless',38,NULL,'UK','Mono frameless, jupe noire, double joint','https://www.ndiver.com/classic-frameless-dive-mask',1),
 ('mask-mares-jupiter','mask','Mares','Jupiter',24.49,NULL,'EU','Mono-verre frameless basique','https://www.tradeinn.com/diveinn/en/mares-jupiter-diving-mask/140702399/p',1);

-- ============================ PALMES =================================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,weight_text,region,use_reco,specs,link,available) VALUES
 ('fins-apeks-rk3','fins','Apeks','RK3 (standard)',138.99,NULL,2.0,'~2,0 kg','EU','Flottaison positive, jet rigide','Spring straps inox inclus','https://www.tradeinn.com/diveinn/en/apeks-rk3-diving-fins/137691341/p',1),
 ('fins-tecline-lightjet','fins','Tecline','LightJet (T40015)',129,NULL,2.0,'1,6–2,2 kg','EU','Flottaison positive, lame souple, frog/back/heli','Spring straps inox inclus','https://www.diveavenue.com/en/tecline/2401-lightjet-rubber-fin-with-spring-straps.html',1),
 ('fins-cressi-origin-ld','fins','Cressi','Origin LD',131.99,NULL,3.0,'~3,0 kg','EU','Flottaison positive','Spring straps inox inclus','https://www.tradeinn.com/diveinn/en/cressi-origin-ld-diving-fins/141846374/p',1),
 ('fins-seac-propulsion-s','fins','Seac Sub','Propulsion S',73.99,NULL,2.0,'~2,0 kg','EU','Flottaison positive, frog/back/heli OK','Spring en option','https://www.tradeinn.com/diveinn/en/seac-propulsion-s-diving-fins/136678982/p',1),
 ('fins-tusa-solla','fins','TUSA','Solla (SF-22)',129,NULL,NULL,'très légère','EU','Flottaison positive, lame longue','Spring en option','https://www.nootica.com/tusa-solla-b-scuba-diving-fins-red.html',1),
 ('fins-mares-xstream','fins','Mares','X-Stream (Bungee)',149,'~149 €',1.3,'~1,3 kg','EU','Flottaison positive, lame molle, back kick limité','Bungee','https://www.tradeinn.com/diveinn/en/mares-x-stream-diving-fins/137048492/p',1),
 ('fins-oms-slipstream','fins','OMS','Slipstream (Monoprène)',128,NULL,2.4,'~2,4 kg','EU','Flottaison neutre, jet léger','Spring straps inox inclus','https://www.diveavenue.com/en/oms/1514-oms-slipstream-fins-adjustable-with-spring.html',1),
 ('fins-diverite-xt','fins','Dive Rite','XT Fins',169.99,NULL,2.6,'~2,6 kg','EU','Flottaison neutre, tous kicks','Spring straps inox inclus','https://www.tradeinn.com/diveinn/en/dive-rite-xt-diving-fins/1305366/p',1),
 ('fins-deep6-eddy','fins','Deep6','Eddy (standard)',NULL,'~197 € (US)',2.1,'~2,1 kg','US','Flottaison neutre','Spring straps inox inclus','https://www.deep6gear.com/deep6-eddy-fin.html',0),
 ('fins-poseidon-trident','fins','Poseidon','Trident',179,NULL,NULL,'lourde','EU','Neutre vers lég. négative, cave/CCR','Spring straps inox inclus','https://proteushop.com/fr/palmes/92705-palmes-poseidon-trident-noires.html',1),
 ('fins-scubapro-stek','fins','Scubapro','S-Tek Fin',183,NULL,2.0,'~2,0 kg','EU','Flottaison réglable (plaques inox), lame pré-angulée 30°','Bungee (spring option)','https://www.palanquee.com/palmes-s-tek-scubapro',1),
 ('fins-halcyon-vector-pro','fins','Halcyon','Vector Pro',325,NULL,2.82,'~2,82 kg','EU','Flottaison réglable (lest inox 6 crans), back/heli','Spring straps inox inclus','https://www.diveavenue.com/en/diving-fins/3998-halcyon-vector-pro-fins.html',1),
 ('fins-atomic-x1','fins','Atomic','X1 BladeFin',161.99,NULL,2.3,'~2,3 kg','EU','Flottaison variable, anti-roulis','Spring en option','https://www.tradeinn.com/diveinn/fr/atomic-aquatics-palmes-plongee-x1/136881125/p',1),
 ('fins-aqualung-xshot','fins','Aqua Lung','X-Shot',78.99,NULL,1.8,'~1,8 kg','EU','Flottaison variable (≈neutre)','Spring straps inox inclus','https://www.sous-la-mer.com/palmes-de-talons-ouvertes-xshot-354767-modele3.html',1),
 ('fins-hollis-f1lt','fins','Hollis','F1 LT',178.49,NULL,3.0,'~3,0 kg','EU','Flottaison négative','Spring straps inox inclus','https://www.tradeinn.com/diveinn/en/hollis-f1-lt-diving-fins/137543848/p',1),
 ('fins-fourthelement-techfin','fins','Fourth Element','Tech Fin',175,'~175 €',2.0,'~2,0 kg','EU','Flottaison négative','Spring straps inox inclus','https://varuste.net/en/p121796/fourth-element-tech-fin',1),
 ('fins-xdeep-ex1','fins','xDeep','EX1 (Soft)',125,NULL,2.5,'~2,5 kg','EU','Flottaison négative (clone Jetfin)','Spring straps inox inclus','https://www.diveavenue.com/en/xdeep/2030-xdeep-ex1-diving-fins-soft-version.html',1),
 ('fins-beuchat-powerjet','fins','Beuchat','PowerJet',118.99,NULL,NULL,'légère','EU','Flottaison négative','Spring straps inox inclus','https://www.tradeinn.com/diveinn/en/beuchat-powerjet-diving-fins/1236639/p',1),
 ('fins-ndiver-jetfins','fins','Northern Diver','Jet Fins',63,'~63 €',NULL,'lourde','UK','Flottaison négative','Spring en option','https://www.ndiver.com/jet-fins',1),
 ('fins-ist-rubber-rocket','fins','IST','Rubber Rocket',115,'~115 € (US)',1.6,'~1,6 kg','US','Flottaison négative','Spring en option','https://www.americandivingsupply.com/IST-Propulsion-Rubber-Rocket-Fins-p/f4-xx.htm',0),
 ('fins-c4-storm','fins','C4 Carbon','Storm',50.49,NULL,1.2,'~0,6 kg/palme','EU','Apnée, chausson fermé (pas frog/back)','Carbone','https://www.tradeinn.com/diveinn/en/c4-storm-diving-fins/140472300/p',1);

-- ============================ COMBINAISONS ===========================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('suit-scubapro-everflex-yulex','wetsuit','Scubapro','Everflex YULEX 7,5/5 mm',479,'479 €',3.0,'EU','SANS néoprène (Yulex, caoutchouc naturel FSC) — hypoallergénique','Humide intégrale, doublure polaire Diamond Span','https://www.diveboutik.com/combinaison-plongee/2228-combinaison-scubapro-everflex-yulex-homme-7-mm.html',1),
 ('suit-scubapro-yulex-hood','wetsuit','Scubapro','Yulex 5/3 mm veste à cagoule',279,'279 €',0.9,'EU','SANS néoprène, cagoule attenante, double le torse à ~12,5 mm','Se porte sous l intégrale','https://www.lucasdivestore.com/fr/scubapro-everflex-yulex-5-3mm-veste-a-cagoule-homm.html',1),
 ('suit-henderson-greenprene','wetsuit','Henderson','Greenprene 7 mm Back-Zip',611,'~611 €',NULL,'EU','SANS néoprène (canne à sucre + huître), vendue pour allergiques','Back-zip, cagoule 7/5 séparée (indispo EU)','https://www.hendersoneurope.com/product/mens-greenprene-back-zip-fullsuit/',1),
 ('suit-elios-natura','wetsuit','Elios','Natura semi-étanche 7 mm 2-pièces',550,'~450–650 € (devis)',NULL,'EU','Limestone 99,7% CaCO3, mérinos en option, sur-mesure','Custom non remboursable, cagoule incluse','https://www.eliossub.com/our-wetsuits/wetsuit-catalogue/natura-wetsuit/',1),
 ('suit-beuchat-med-czip','wetsuit','Beuchat','Med C-Zip 8/7 mm',399,'399 €',NULL,'EU','Limestone, doublure Fireskin intégrale, cagoule intégrée','Zip frontal semi-étanche','https://www.scubazar.fr/plongee/combinaisons-de-plongee/combinaisons-humides/combinaison-med-c-zip-homme-monopiece-8-7-mm-avec-zip-frontal-horizontal.html',1),
 ('suit-camaro-gamma','wetsuit','Camaro','Gamma X-Treme 7 mm',449.95,NULL,NULL,'EU','Limestone, cagoule + chaussons attenants, TRU-Zip','Semi-étanche','https://www.camaro-watersports.com/en/Gamma-X-Treme-7-mm-OV-Herren/C7914559-99-50',1),
 ('suit-waterproof-sd-combat','wetsuit','Waterproof','SD Combat 7 mm',796,'796 €',NULL,'EU','Limestone, zip sec étanche aux gaz, cagoule H1 incluse','Joints glideskin au contact peau','https://www.palanquee.com/combinaison-sd-combat-waterproof-7mm-homme',1),
 ('suit-xcel-thermoflex','wetsuit','Xcel','Thermoflex Celliant 7/6 mm',449,'~439–549 €',NULL,'EU','Limestone japonais + doublure IR Celliant','Zip dorsal, cagoule séparée','https://xcelwetsuits.eu/products/mens-thermoflex-celliant-dive-fullsuit-7-6mm',1),
 ('suit-aqualung-solaflex','wetsuit','Aqua Lung','Solaflex 8/7 mm',449,'449 €',NULL,'EU','Néoprène sans pétrole/HAP + colle eau, cagoule attenante','Coutures Liquid Fusion','https://www.scubazar.fr/plongee/combinaisons-de-plongee/combinaisons-semi-etanches/combinaison-solaflex-8mm-cagoule-attenante-homme.html',1),
 ('suit-fourthelement-proteus','wetsuit','Fourth Element','Proteus II 5 mm',594.50,NULL,NULL,'EU','Limestone (FE dit NON hypoallergénique), doublure Hexcore','5 mm, cagoule séparée','https://fourthelement.com/product/mens-proteus-ii-5mm-diving-wetsuit/',1),
 ('suit-mares-protherm','wetsuit','Mares','Pro Therm 8/7 mm',398.99,NULL,NULL,'EU','Néoprène pétrole, cagoule intégrée','Fire Plush, joints Glideskin','https://www.tradeinn.com/diveinn/en/mares-pro-therm-8-7-mm-diving-wetsuit/139380892/p',1),
 ('suit-bare-velocity','wetsuit','Bare','Velocity Ultra 8/7 mm',636.99,NULL,NULL,'EU','Chloroprène (Prop 65), doublure IR Omnired','Cagoule attenante','https://www.tradeinn.com/diveinn/en/bare-velocity-ultra-8-7-mm-semi-dry-suit/138027396/p',1),
 ('suit-hollis-neotek','wetsuit','Hollis','NeoTek 8/7/6 V2',499.99,NULL,NULL,'EU','Chloroprène, donné 7-12°C, cagoule attenante','Coutures quadruple-collées','https://www.diveavenue.com/en/hollis/1961-hollis-neotek-semi-drysuit-diving-suit.html',1),
 ('suit-cressi-ice','wetsuit','Cressi','ICE 7 mm',549,'549 €',NULL,'EU','Néoprène pétrole, classe B (10-18°C)','Cagoule séparée','https://globalneoprene.com/fr/plongee/170-combinaison-plongee-semi-etanche-homme-cressi-ice-7mm.html',1),
 ('suit-seac-spacedry','wetsuit','Seac','Spacedry 7 mm',499.99,NULL,NULL,'EU','Néoprène pétrole, cagoule incluse','Titex Master Seal','https://www.planet-plongee.fr/combinaisons-semi-etanches/8689-combinaison-seac-spacedry-7mm.html',1),
 ('suit-pinnacle-merino','wetsuit','Pinnacle','Merino Elastiprene 7 mm',289.99,NULL,NULL,'EU','Néoprène pétrole + doublure mérinos, pas de cagoule','Humide','https://www.tradeinn.com/diveinn/en/pinnacle-aquatics-merino-elastiprene-7-mm-diving-wetsuit/143019972/p',1),
 ('suit-typhoon-centre','wetsuit','Typhoon','Centre 5 mm',159.99,NULL,NULL,'EU','Néoprène pétrole, gamme location, sans cagoule','Max 5 mm','https://www.tradeinn.com/diveinn/en/typhoon-centre-5-mm-diving-wetsuit/138729260/p',1),
 ('suit-polosub-lisse','wetsuit','Polosub','Lisse Refendu open-cell',358,'358 €',NULL,'EU','Apnée/chasse, open-cell à même la peau (pas scuba 45 m)','Sur-mesure','https://www.polosub.com/fra/catalogue/cat-1-lisse-refendu',1);

-- ============================ SOUS-COUCHES ===========================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('base-sharkskin-t2','baselayer','Sharkskin','T2 Chillproof Top + Pants',452,'239 € top + ~213 € pants',0.5,'EU','SANS néoprène, équiv. 4,5–5 mm, ne se comprime pas à 45 m','Composite 3 couches nano-titane IR','https://www.diveavenue.com/en/sharkskin/3718-sharkskin-chilproof-t2-long-sleeve-top-men.html',1),
 ('base-lavacore-fullsuit','baselayer','Lavacore','Full Suit Polytherm',187,'187 €',NULL,'EU','SANS néoprène, hypoallergénique, équiv. ~2 mm','Tri-laminé polyuréthane','https://www.tradeinn.com/diveinn/en/lavacore/575/m',1),
 ('base-fourthelement-thermocline','baselayer','Fourth Element','Thermocline LS Top (+ Leggings)',200,'~185–215 €',NULL,'EU','SANS néoprène (ECONYL), équiv. 2–3 mm','Nylon recyclé','https://www.tradeinn.com/diveinn/fr/fourth-element-thermocline-ls-top/593191/p',1),
 ('base-bare-ultrawarmth','baselayer','Bare','Ultrawarmth Top + Pants',219,'119 € top + ~100 € pants',NULL,'EU','SANS néoprène (Omnired IR), isole même mouillé','Polaire IR','https://www.lucasdivestore.com/en/bare-ultrawarmth-base-layer-top-men.html',1),
 ('base-waterproof-bodytec','baselayer','Waterproof','BodyTec Dual Layer',103,'103 €',NULL,'EU','SANS néoprène, chaud mouillé','Polaire polyester 2x260 g','https://www.palanquee.com/top-bodytec-waterproof-dual-layer',1),
 ('base-scubapro-k2-light','baselayer','Scubapro','K2 Light Top',54,'54 €',NULL,'EU','SANS néoprène, modéré','Polaire polyester 164 g','https://www.diveboutik.com/sous-vetements-thermiques/1369-top-scubapro-k2-light.html',1),
 ('base-santi-flex80','baselayer','Santi','FLEX80 1 pièce',310,'310 €',NULL,'EU','SANS néoprène, faible en humide','Polyester/élasthanne','https://www.scubasupport.nl/us/santi-flex80-undersuit-men.html',1),
 ('base-thermalution-red','baselayer','Thermalution','Red Grade Ultra 100 m',1495,'1 495 €',NULL,'EU','Chauffante (3 zones), sans néoprène — fort','S imbibe en humide','https://thermalution.eu/en/producten/red-grade-ultra-100m/',1);

-- ============================ BOTTILLONS / CHAUSSETTES ===============
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('boot-bare-7mm','boots','Bare','7 mm Ultrawarmth',109,'109 €',NULL,'EU','Semelle dure (spring straps OK), doublure IR Omnired','7 mm + zip étanche','https://www.lucasdivestore.com/fr/bare-7mm-ultrawarmth-bottillons.html',1),
 ('boot-tecline-7mm-ti','boots','Tecline','7 mm Titanium',63,'63 €',NULL,'EU','Semelle dure + ergot talon','7 mm + doublure titane','https://www.diveavenue.com/en/diving-slippers-and-booties/3425-scubatech-neoprene-diving-boots-7mm-titanium.html',1),
 ('boot-xsscuba-thug','boots','XS Scuba','8 mm Thug',92,'~85–100 €',NULL,'EU','Semelle dure moulée heavy-duty','8 mm + zip eau froide','https://www.xsscuba.com/boots/8mm-thug-boots',1),
 ('boot-aqualung-superzip','boots','Aqua Lung','Superzip 7 mm',46,'~45–48 €',NULL,'EU','Semelle dure rock-boot ERGO','7 mm + zip YKK','https://www.nootica.com/dive-boots-aqualung-superzip-7-mm.html',1),
 ('boot-beuchat-sirocco','boots','Beuchat','Sirocco Elite 7 mm',59,'59 €',NULL,'EU','Semi-rigide + cale-sangle','7 mm limestone','https://www.diveavenue.com/en/diving-slippers-and-booties/3658-sirocco-elite-7mm-dive-boot-beuchat.html',1),
 ('boot-cressi-isla','boots','Cressi','Isla 7 mm',50,'~50 €',NULL,'EU','Semelle dure + ergot anti-glissement','7 mm + zip','https://globalneoprene.com/fr/bottillons-chaussons-de-plongee/232-botillons-plongee-cressi-isla-7mm.html',1),
 ('boot-scubapro-hd','boots','Scubapro','Heavy-Duty 6,5 mm',94.50,'94,50 €',0.85,'EU','Semelle dure + retenue de sangle (spring straps OK)','6,5 mm + Diamond Span + zip velcro (XL = 43-44)','https://www.lucasdivestore.com/en/scubapro-heavy-duty-boot.html',1),
 ('boot-mares-flexa-ds','boots','Mares','Flexa DS 6,5 mm',73,'73 €',NULL,'EU','Semelle dure + ergot passant de sangle','6,5 mm doublé + zip','https://www.tradeinn.com/diveinn/en/mares-flexa-ds-6.5-mm-booties/137086745/p',1),
 ('boot-waterproof-b2','boots','Waterproof','B2 6,5 mm Semi-Dry',92,'92 €',NULL,'EU','Semelle structurée + rebord sangle','6,5 mm semi-sec + zip YKK','https://www.lucasdivestore.com/en/waterproof-b2-65mm-semi-dry-boots.html',1),
 ('boot-fourthelement-amphibian','boots','Fourth Element','Amphibian 6,5 mm',116,'~116 €',NULL,'EU','Semelle dure + ergot retenue','6,5 mm + zip heavy-duty','https://shop4divers.eu/en/boots-socks/1072-pelagic-boots-fourth-element-0661708250182.html',1),
 ('boot-seac-pro-hd','boots','Seac','Pro HD 6 mm',74,'~74 €',NULL,'EU','Semelle dure raide + ergot','6 mm','https://www.nootica.com/seac-sub-pro-hd-6mm-booties.html',1),
 ('sock-sharkskin-tifir','boots','Sharkskin','Chillproof TIFIR (chaussette)',55.90,'55,90 €',0.1,'EU','SANS néoprène, équiv. 4-5 mm, ne se comprime pas à 45 m','Semelle souple (chaussette) — barrière allergie sous bottillon','https://www.palanquee.com/chaussons-tifir-sharkskin',1),
 ('sock-lavacore-booties','boots','Lavacore','Reinforced Booties',34.49,'34,49 €',NULL,'EU','SANS néoprène (appoint ~3 mm)','Semelle souple','https://www.tradeinn.com/diveinn/en/lavacore-reinforced-booties/13558338/p',1),
 ('boot-hollis-overboot','boots','Hollis','Canvas Over-Boot (étanche)',85,'~80–90 €',NULL,'EU','Sur-botte étanche (sans isolation), semelle dure','Pour étanche','https://www.tradeinn.com/diveinn/en/hollis-over-boot-for-dry-suit/82666/p',1),
 ('boot-dui-rockboot','boots','DUI','RockBoot V2 (sur-botte étanche)',168,'~168 €',NULL,'EU','Sur-botte étanche, semelle dure','1,5 mm','https://diving-store.eu/en/buty-do-suchego-skafandra/632-dui-rockboots-dry-suit-boots.html',1);

-- ============================ ORDINATEURS ============================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('comp-shearwater-peregrine','computer','Shearwater','Peregrine',520,'~520 € (base) / 720 € TX',0.12,'EU','Bühlmann GF réglables, multigaz nitrox + déco (3 gaz)','Montre, USB-C, ~120 g (TX = AI option)','https://www.subchandlers.com/52793-ordinateur-peregrine-tx-shearwater.html',1),
 ('comp-garmin-g2','computer','Garmin','Descent G2',599.99,'599,99 €',NULL,'EU','Bühlmann ZHL-16C + GF, multigaz nitrox + déco (trimix/CCR dispo)','Montre AMOLED, AI option','https://www.diveavenue.com/en/diving-watch-/4046-garmin-descent-g2.html',1),
 ('comp-scubapro-g3','computer','Scubapro','Galileo 3 (G3)',499,'499 €',NULL,'EU','Bühlmann ZH-L16 + GF, 8 gaz nitrox/trimix, SM/CCR','Montre couleur, AI option','https://www.palanquee.com/ordinateur-galileo-3-scubapro',1),
 ('comp-mares-quad2','computer','Mares','Quad 2',299,'299 €',NULL,'EU','Bühlmann ZHL-16C + GF, nitrox + trimix (5 mél.)','Puck','https://www.lucasdivestore.com/fr/mares-quad-2.html',1),
 ('comp-ratio-idive','computer','Ratio','iDive Color Tech+',499,'499 €',NULL,'EU','Bühlmann ZHL-16B + GF, nitrox + déco (10 mél.), trimix/CCR','Montre, AI option','https://www.diveavenue.com/en/ratio-dive-computers/675-dive-computer-ratio-idive-color-tech.html',1),
 ('comp-divesoft-freedom','computer','Divesoft','Freedom+ Advanced Nitrox',549,'549 €',NULL,'EU','Bühlmann + GF, nitrox + déco (3 mél.), évolutif trimix/CCR','Puck OLED','https://divelyon.fr/produit/ordinateur-de-plongee-divesoft-freedom-advanced-nitrox/',1),
 ('comp-apeks-dsx','computer','Apeks','DSX',699,'699 €',NULL,'EU','Bühlmann ZHL-16C + GF, nitrox/trimix + CCR (6 gaz), SM','Montre TFT, AI option','https://www.subchandlers.com/39678-ordinateur-dsx-apeks.html',1),
 ('comp-hw-ostc','computer','Heinrichs Weikamp','OSTC+ (hwOS)',745,'745 €',NULL,'EU','Bühlmann ZHL-16C + GF (open-source), trimix/CCR firmware','Puck','https://hwdiving.com/produkt/ostc/?lang=en',1),
 ('comp-suunto-ocean','computer','Suunto','Ocean',799,'799 €',NULL,'EU','Suunto Bühlmann 16 GF, nitrox + déco (5 mél.), pas de trimix','Montre AMOLED, AI option','https://www.diveavenue.com/en/204-suunto-dive-computers',1),
 ('comp-halcyon-symbios','computer','Halcyon','Symbios',1090,'1 090 €',NULL,'EU','Bühlmann ZHL-16C + GF, nitrox/trimix + CCR (5 gaz)','Montre couleur, AI option','https://www.diveavenue.com/en/dive-computers-instruments/3999-halcyon-symbios-dive-computer.html',1),
 ('comp-aqualung-dsx','computer','Aqualung','DSX (= Apeks DSX)',1149,'1 149 €',NULL,'EU','Bühlmann ZHL-16C + GF, nitrox/trimix + CCR (6 gaz)','Montre TFT','https://www.diveboutik.com/ordinateur-trimix/2180-ordinateur-apeks-dsx.html',1),
 ('comp-oceanic-geo-air','computer','Oceanic','Geo Air',480,'410–549 €',NULL,'EU','Pelagic Z+ ou DSAT (pas de GF), air/nitrox 2 gaz','Montre, AI option','https://www.diveavenue.com/en/dive-computers-instruments/3391-oceanic-geo-air-computer-watch.html',1),
 ('comp-seac-tablet','computer','Seac Sub','Tablet',299,'299 €',NULL,'EU','ZHL-16C 6 niveaux figés (pas de GF libre), nitrox 3 gaz','Puck, AI option','https://www.lucasdivestore.com/fr/seac-tablet.html',1),
 ('comp-tusa-element3','computer','TUSA','Element III',249,'249 €',NULL,'EU','ZHL-16C (pas de GF), air/nitrox monogaz','Montre','https://www.nootica.com/tusa-element-iii-dive-computer-watch.html',1),
 ('comp-cressi-raffaello','computer','Cressi','Raffaello',299,'299 €',NULL,'EU','RGBM Cressi (pas de Bühlmann ni GF), nitrox 3 gaz','Montre','https://www.subchandlers.com/55233-ordinateur-raffaello-cressi.html',1);

-- ============================ LAMPES =================================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('light-orcatorch-dc710','light','OrcaTorch','DC710',148,'148 €',0.25,'EU','3000 lm, faisceau 6° serré, USB-C direct, alu 150 m','~250 g','https://www.lucasdivestore.com/fr/orcatorch-dc710.html',1),
 ('light-mares-eos-pro','light','Mares','EOS Pro',129,'129 €',0.226,'EU','1300 lm, 8°, USB-C, très légère','226 g','https://www.subchandlers.com/52731-phare-eos-pro-1300-lumen-mares.html',1),
 ('light-xtar-d26','light','XTAR','D26 2800',159,'159 €',0.34,'EU','2800 lm, 7°, USB-C','~340 g','https://www.lucasdivestore.com/en/xtar-d26-2800-dive-light-set.html',1),
 ('light-tillytec-mini','light','Tillytec','Mini uni SET',249,'249 €',0.165,'DE','2000 lm, 10° (modules 5/10/15°), USB-C','165 g','https://tillytec.de/products/tillytec%C2%AE-mini-uni-set',1),
 ('light-kraken-nr1800','light','Kraken Sports','NR-1800',171,'171 €',0.26,'EU','1800 lm, 6° laser, USB-C','~260 g','https://www.tradeinn.com/diveinn/en/kraken-nr-1800-6--green-laser-torch/141907956/p',1),
 ('light-divepro-s40','light','Divepro','S40',229,'229 €',0.35,'EU','4200 lm, 9°, USB','~350 g','https://www.diveavenue.com/en/divepro/1816-underwater-dive-light-divepro-s40-4200lm-9-beam.html',1),
 ('light-scubapro-nova1000r','light','Scubapro','Nova 1000R',209,'209 €',0.315,'EU','1000 lm, 8°, USB','~315 g','https://www.planet-plongee.fr/lampes-et-phares-de-plongee/9091-lampe-de-plongee-scubapro-nova-1000r-4048336434805.html',1),
 ('light-diverite-fx40','light','Dive Rite','FX40',695,'695 €',0.57,'EU','2400 lm, 4° très serré, USB-C','570 g','https://www.tradeinn.com/diveinn/en/dive-rite-fx40-torch/141739239/p',1),
 ('light-halcyon-flare-exp','light','Halcyon','Flare EXP+',1099,'1 099 €',0.57,'EU','~3000 lm, 8-10°, recharge berceau','570 g','https://www.lucasdivestore.com/en/halcyon-flare-exp-plus-dive-light.html',1),
 ('light-finnsub-finnlight','light','Finnsub','Finn Light 2500 Short',660,'660 €',0.656,'DE','2500 lm, 5°, recharge magnétique','656 g','https://www.tauchversandonline.de/FINNSUB-FINN-LIGHT-2500-Short',1),
 ('light-lightmotion-sola','light','Light & Motion','Sola Dive Pro 2000',495,'495 €',0.333,'EU','2000 lm, 8°, scellé (marque en liquidation)','333 g','https://www.diveavenue.com/en/light-motion/932-light-motion-sola-dive-pro-2000.html',1),
 ('light-bigblue-al1300','light','Bigblue','AL1300NP',175,'175 €',0.168,'EU','1300 lm, 10°, batterie 18650','168 g','https://www.palanquee.com/phare-al1300-np-bigblue',1),
 ('light-apeks-luna','light','Apeks','Luna',669,'669 €',0.258,'EU','2000 lm, 20° large, USB','258 g','https://fr.apeksdiving.com/products/luna-primary-dive-torch',1),
 ('light-tovatec-t3500','light','Tovatec','T3500S',223,'223 €',0.268,'EU','3500 lm, 13°, USB','268 g','https://www.gidivestore.com/eu/en/dive-lights/tovatec-3500s.html',1),
 ('light-seac-r30','light','Seac Sub','R30',199,'199 €',0.48,'EU','1500 lm, 12°, micro-USB','480 g','https://www.palanquee.com/lampe-r30-seac-sub',1),
 ('light-ammonite-ledone','light','Ammonite','LED One',144,'144 €',0.37,'EU','400 lm, 6°, piles AA','~370 g','https://shop4divers.eu/en/ammonite-system/797-ammonite-system-led-one-compact-torch-5900316920007.html',1),
 ('light-oms-vega-k2','light','OMS','Vega K2',158.81,'158,81 €',NULL,'EU','280 lm, 6°, piles AA','léger','https://www.sous-la-mer.com/oms-vega-k2-led-lamp-9403-modele2.html',1);

-- ============================ SACS ===================================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('bag-eaglecreek-cargo110','bag','Eagle Creek','Cargo Hauler Wheeled 110 L',230,'~230 €',1.95,'EU','À roulettes tout-terrain + bretelles dos, garantie à vie','800D + base 1680D (non-plongée)','https://eaglecreek.eu/products/cargo-hauler-wheeled-duffel-110l-1',1),
 ('bag-seac-equipage500','bag','Seac','Equipage 500 (130 L)',120,'119–134 €',2.0,'EU','À roulettes + bretelles dos, poche palmes drainante (dive)','Polyester 600D + bâche','https://www.tradeinn.com/diveinn/en/seac-equipage-500-130l-gear-bag/137335942/p',1),
 ('bag-mares-cruise-dry140','bag','Mares','Cruise Dry Roller 140 (140 L)',146,'~146 €',2.3,'EU','À roulettes + dos (3 modes), PU 500D soudé ÉTANCHE (dive)','Roll-top','https://www.tradeinn.com/diveinn/en/mares-cruise-dry-roller-140-gear-bag/138619104/p',1),
 ('bag-beuchat-airlight4','bag','Beuchat','Air Light 4 (150 L)',165,'~165 €',2.35,'EU','À roulettes + dos','Nylon/PVC 600D + fond 1000D','https://www.nootica.com/bag-beuchat-air-light-150l.html',1),
 ('bag-scubapro-mesh100','bag','Scubapro','Sport Mesh N Roll 100 (100 L)',160,'~150–170 €',2.51,'EU','À roulettes + dos, filet drainant','600D + filet','https://www.amazon.de/SCUBAPRO-Sport-Mesh-Roll-100/dp/B0CHTSDWJ5',1),
 ('bag-cressi-moby85','bag','Cressi','Moby Light (85 L)',150,'~150 €',2.9,'EU','À roulettes + dos','Nylon 420D','https://www.tradeinn.com/diveinn/en/cressi-moby-light-85l-bag/6099/p',1),
 ('bag-mares-cruise-roller128','bag','Mares','Cruise Backpack Roller (128 L)',113,'~113 €',3.0,'EU','À roulettes + dos, poches palmes drainantes (dive)','r-PET','https://www.sous-la-mer.com/sacs-de-sport-cruise-roller-128l-8289730-modele3.html',1),
 ('bag-ndiver-voyager136','bag','Northern Diver','Voyager Lightweight (136 L)',140,'~140 €',3.2,'EU','À roues tout-terrain + télescopique','Nylon Ripstop hydrofuge','https://www.ndiver.com/lightweight',1),
 ('bag-oms-roller145','bag','OMS','Roller 145L (145 L)',229,'~229 €',3.7,'EU','À roues roulements + télescopique (dive, tech)','Nylon 840D, dos rigide','https://www.tradeinn.com/diveinn/en/oms-roller-145l-gear-bag/137739678/p',1),
 ('bag-oceanic-roller130','bag','Oceanic','Roller Duffel (130 L)',219,'~219 €',4.0,'EU','À roulettes, garantie à vie','1260D balistique + Hypalon + YKK#10','https://www.tradeinn.com/diveinn/en/oceanic-new-duffel-bag-with-wheels/604330/p',1),
 ('bag-apeks-roller90','bag','Apeks','Roller 90L (90 L)',154,'~154 €',4.2,'EU','À roulettes heavy-duty','Bâche PVC 500D, fond rigide','https://www.tradeinn.com/diveinn/en/apeks-roller-90l-gear-bag/137980818/p',1),
 ('bag-hollis-duffel95','bag','Hollis','Duffel (95 L)',169,'~169 €',1.47,'EU','Sans roulettes (bretelles dos), bâche anti-abrasion (dive)','Très léger','https://www.lucasdivestore.com/en/hollis-duffle-bag.html',1),
 ('bag-fourthelement-exped90','bag','Fourth Element','Expedition Duffel (90 L)',140,'~140 €',1.5,'EU','Sans roulettes (bretelles amovibles)','500D PVC + base 600D','https://varuste.net/en/p118416/fourth-element-expedition-series-duffelbag-90l',1),
 ('bag-osprey-transporter120','bag','Osprey','Transporter Duffel (120 L)',156,'~132–180 €',1.7,'EU','Sans roulettes (bretelles dos), garantie à vie','900D TPU recyclé','https://www.idealo.fr/prix/205981244/osprey-transporter-duffel-120.html',1),
 ('bag-tnf-basecamp-xl','bag','The North Face','Base Camp Duffel XL (132 L)',150,'~125–170 €',1.97,'EU','Sans roulettes (bretelles dos)','1000D + base 840D','https://www.thenorthface.com/fr-fr/p/sacs-and-equipement-211747/sac-duffel-base-camp-132l-xl-NF0A52SC',1),
 ('bag-oms-duffel155','bag','OMS','Gear Bag Duffel (155 L)',148,'~148 €',2.16,'EU','Sans roulettes, cloison humide/sec (dive)','1000D TPU laminé ÉTANCHE','https://www.tradeinn.com/diveinn/en/oms-roller-145l-gear-bag/137739678/p',1);

-- ============================ PROTECTION FRAGILES ====================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('prot-mares-shell','protection','Mares','Shell Regulator',32,'~32 €',0.24,'EU','Étui EVA semi-rigide + velours (écran ordi + verres)','Anti-choc léger, cabine','https://www.lucasdivestore.com/en/mares-shell-regulator.html',1),
 ('prot-scubapro-def10','protection','Scubapro','Definition Regulator 10',68,'~68 €',0.372,'EU','Sac matelassé souple 600D','Protection moyenne','https://diving2000.com/shop/62-bags/9160-scubapro-definition-regulator-bag-10-l/',1),
 ('prot-apeks-regbag','protection','Apeks','Regulator Bag',30,'~30 €',0.4,'EU','Sac matelassé souple, mesh drainage','Protection moyenne','https://www.lucasdivestore.com/en/apeks-regulator-bag.html',1),
 ('prot-halcyon-voyager','protection','Halcyon','Voyager Case',103,'~103 €',0.55,'EU','Étui EVA semi-rigide 840D (assorti gilet)','Protection moyenne-haute','https://jonasdive.com/en/regulator-bags/2427-halcyon-voyager-case.html',1),
 ('prot-nanuk-910','protection','Nanuk','910 + mousse cubique',129,'~129 €',1.7,'EU','Valise rigide NK-7 IP67, mousse découpable','Format plat','https://www.valises-etanches.com/valise-etanche-nanuk-910.html',1),
 ('prot-bw-type3000','protection','B&W','Outdoor.Case Type 3000',92,'~85–98 €',1.7,'EU','Valise rigide PP IP67 + valve, mousse','Coque + valve','https://www.tradeinn.com/techinn/en/b-w-outdoor-case-type-3000-with-pre-cut-foam-insert/137858267/p',1),
 ('prot-peli-air1525','protection','Pelican / Peli','Air 1525 (Pick N Pluck)',356,'~356 €',3.23,'EU','Valise rigide HPX2 IP67 + MIL-STD, mousse','Norme militaire','https://www.kofferundschaum.de/fr/peli-cases/air-cases/peli-air-case-1525-noir-avec-mousse-predecoupee.html',1);

-- ============================ COMPAS =================================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,link,available) VALUES
 ('comp-suunto-sk8','compass','Suunto','SK-8 Bungee',75,'75 €',0.1,'EU','Tilt ±30°, fenêtre latérale, lunette crantée, card phospho','https://www.diveboutik.com/boussole-plongee/1746-compas-suunto-sk8-sur-bungee.html',1),
 ('comp-scubapro-fs2','compass','Scubapro','FS-2',99,'99 €',NULL,'EU','Tilt ~35°, fenêtre latérale, aimant flottant','https://www.techniplongee.fr/boussoles-et-accessoires-de-plongee-sous-marine/402-compas-fs2-capsule-scubapro.html',1),
 ('comp-apeks-bungee','compass','Apeks','Bungee Mount Compass',63.99,'63,99 €',NULL,'EU','Tilt ±30°, fenêtre gun-sight, cadran lumineux','https://www.sous-la-mer.com/apeks-bungee-mount-compass-noir-11387436-modele3.html',1),
 ('comp-sub2o','compass','SUB2O','Compas Bungee ±30°',55,'55 €',NULL,'FR','Module italien (équiv. NAV-PRO), capsule large','https://www.sub2o.fr/compas-bungee-inclinaison-30-xml-378_379_392-1097.html',1);

-- ============================ DSMB ===================================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,link,available) VALUES
 ('dsmb-apeks-14','dsmb','Apeks','DSMB 1.4 m (closed)',82,'77–87 €',0.3,'EU','Fermé, gonflage oral 1 souffle, OPV à tirette gantée, SOLAS 2 faces','https://www.tradeinn.com/diveinn/en/apeks-smb-deco-buoy-1.4-m/137658702/p',1),
 ('dsmb-xdeep-140','dsmb','xDeep','Closed DSMB 140',47,'47 €',NULL,'EU','Fermé ~145 cm, levée 11 kg, OPV, oral+LP, poche cyalume','https://www.tradeinn.com/diveinn/en/xdeep-closed-140-smb-deco-buoy/1096933/p',1),
 ('dsmb-tecline-117','dsmb','Tecline','Closed Buoy 117 cm',56,'56 €',NULL,'EU','Fermé, OPV, valve métal oral OU inflateur LP, 2x SOLAS','https://www.divesupport.de/en/tecline-buoy-closed-11-x-117-cm/2400160',1),
 ('dsmb-halcyon-marker','dsmb','Halcyon','Diver Alert Marker 1 m OPV',78,'~65–90 €',NULL,'EU','Fermé, valve No-Lock orale + LP, OPV (assorti rig)','https://www.tradeinn.com/diveinn/en/halcyon-divers-alert-marker-with-opv-100-cm/137169303/p',1);

-- ============================ SPOOL ==================================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,link,available) VALUES
 ('spool-halcyon-defender45','spool','Halcyon','Defender Pro 45 m',61,'61 € (45 m) / 52 € (30 m)',0.2,'EU','Delrin plein, Easy-Grip gants, double-ender inox, ligne #24','https://www.divesupport.de/en/halcyon-defender-pro-spool/90010020',1),
 ('spool-tecline-coldwater','spool','Tecline','Cold Water 30/40 m',56,'54–58 €',NULL,'EU','Delrin monobloc, gros trou + flasque évasée (gants), double-ender','https://www.divesupport.de/en/tecline-cold-water-spool-with-ss-doubleender/2400120',1),
 ('spool-diverite-finger36','spool','Dive Rite','Finger Spool POM 36 m',39,'~39 €',NULL,'EU','POM acétal, ligne #24 tressée 100 kg, double-ender inox','https://www.dirdirect.com/products/dive-rite-finger-reel-large',1),
 ('spool-apeks-lifeline','spool','Apeks','Lifeline 30/45 m',21,'18–24 €',NULL,'EU','Ligne orange haute-visi, double-ender inox','https://www.dirdirect.com/collections/reels-and-spools',1);

-- ============================ COUPE-LIGNE ============================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,link,available) VALUES
 ('cut-eezycut-trilobite','cutter','Eezycut','Trilobite (+ pochette 50 mm)',30,'~30 €',0.05,'EU','Double lame 440A remplaçable, coupe à 2 mains avec gants','https://www.diveavenue.com/en/eezycut/449-eezycut-trilobite-diving-cutter.html',1),
 ('cut-halcyon-cutter','cutter','Halcyon','Line Cutter (céramique)',35,'35 €',NULL,'EU','Lame céramique remplaçable, pochette Velcro sangle 50 mm','https://www.tec-divesysteme.com/en/p/halcyon-line-cutter',1),
 ('cut-diverite-zknife','cutter','Dive Rite','Line Cutter / Z-Knife',27,'25–30 €',NULL,'EU','Crochet céramique ou Z-Knife inox 440, pochette Velcro','https://plongeecapitale.com/en/produit/dive-rite-line-cutter/',1);

-- ============================ WETNOTES ===============================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,link,available) VALUES
 ('wn-halcyon-notebook','wetnotes','Halcyon','Diver Notebook',48,'48 €',0.2,'EU','Nylon balistique, boucle bungee double-ender, 2 poches déco/tables','https://www.diveavenue.com/en/useful/4303-halcyon-logbook-for-diver-wetnotes.html',1),
 ('wn-gue','wetnotes','GUE','Wetnotes',53.90,'53,90 €',NULL,'EU','Nylon balistique, 25 feuilles, porte-crayon, boucle bolt snap','https://www.divesupport.de/en/gue-wetnotes-diver-s-notebook/50130',1),
 ('wn-diverite-writes','wetnotes','Dive Rite','Dive wRites',45.49,'45,49 €',NULL,'EU','28 pages waterproof, crayon + lanyard, poche compas','https://www.tradeinn.com/diveinn/en/dive-rite-dive-writes-underwater-notebook/13388/p',1),
 ('wn-oms','wetnotes','OMS','Wetnotes Notebook',34.90,'34,90 €',NULL,'EU','Pages waterproof amovibles, grande poche tables Velcro','https://www.divesupport.de/en/oms-wetnotes-diver-s-notebook/400325',1),
 ('wn-dtd','wetnotes','DTD','Wetnotes Complete',25.23,'25,23 €',NULL,'EU','Cordura, >40 feuilles, poches crayons, œillet double-ender','https://www.cascoantiguo.com/en/tek/tech-diving-spare-parts-accessories/wet-note-dtd',1);

-- ============================ BOLT SNAPS =============================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('bs-oms-biggrip','boltsnap','OMS','BigGrip Bolt Snap',9.99,'9,99 €',NULL,'EU','Ergonomie ★★★ levier BigGrip, fixe','316 intégral + ressort 316','https://www.tradeinn.com/diveinn/en/oms-biggrip-bolt-snap/137602358/p',1),
 ('bs-xdeep-nx','boltsnap','xDeep','NX Series Bolt Snap',13,'9,99–17 €',NULL,'EU','Ergonomie ★★★ gueule large 19 mm, fixe ou tournant','316 intégral + ressort 316','https://www.tradeinn.com/diveinn/en/xdeep-nx-series-bolt-snap-for-stage-sm-clip/137100516/p',1),
 ('bs-bestdivers-dir','boltsnap','Best Divers','DIR Carabiner',11.99,'11,99 €',NULL,'EU','Ergonomie ★★★ levier 90° large, gros œil 107/120','316','https://www.tradeinn.com/diveinn/en/best-divers-dir-carabiner/31067/p',1),
 ('bs-halcyon-316','boltsnap','Halcyon','Bolt Snap 316 (Swivel/Ergo)',16,'~13–19 €',NULL,'EU','Ergonomie ★★ ébavuré usine, fixe/tournant + gros œil 1"','316 + ressort inox','https://www.tec-divesysteme.com/en/p/halcyon-noble-steel-bolt-snap',1),
 ('bs-tecline-dtype','boltsnap','Tecline','SS Bolt Snap D-type (swivel)',12,'10,70–13,16 €',NULL,'EU','Ergonomie ★★ tournant D-type','316 ou laiton chromé','https://www.diveavenue.com/en/carabiners-clips/4716-tecline-100-mm-d-type-bolt-snap.html',1),
 ('bs-diverite-swivel','boltsnap','Dive Rite','Swivel Bolt Snap 316',13,'~11–15 €',NULL,'EU','Ergonomie ★★ tournant + double-ender','316','https://www.tradeinn.com/diveinn/fr/dive-rite-swivel-bolt-snap-90/662602/p',1),
 ('bs-dirzone-90','boltsnap','DIRZone','Boltsnap 90 mm',6.5,'5–8 €',NULL,'DE','Ergonomie ★★ fixe, 316 (V4A)','316 + ressort 316','https://www.tauchfieber.com/dirzone-boltsnap-90mm',1),
 ('bs-gear4tech-110','boltsnap','Gear4Tech','Bolt Snap DIR 110 mm',10,'~9–12 €',NULL,'EU','Ergonomie ★ fixe + gros œil 110 (mano)','316','https://www.tradeinn.com/diveinn/en/gear4tech-bolt-snap-dir-style-110-mm/136505338/p',1),
 ('bs-apeks-ap1000','boltsnap','Apeks','AP1000 Single-End 75 mm',5.90,'5,90 €',NULL,'DE','Ergonomie ★ 1 seul modèle, fixe','316 / V4A','https://www.sf-1.eu/AP1000_1',1),
 ('bs-scubapro-stek','boltsnap','Scubapro','S-Tek Bolt Snap',21.90,'~21,90 €',NULL,'EU','Ergonomie ★ fixe / swivel / big-eye','316 gravé laser','https://www.lucasdivestore.com/en/scubapro-stainless-steel-bolt-snaps.html',1);

-- ============================ SIDEMOUNT — GRÉEMENT ===================
INSERT INTO item (id,category_id,brand,model,price_eur,price_text,weight_kg,region,use_reco,specs,link,available) VALUES
 ('smk-xdeep-pockets','sm_kit','xDeep','Poches SM (lest central + 2 cargo + trim)',206,'~206 €',0.8,'EU','Lest CENTRAL sur la colonne (ESSENTIEL) + rangement cargo + paire trim','Lest central 71 € + cargo + trim','https://www.tradeinn.com/diveinn/en/xdeep-central-m-weight-pocket/136806329/p',1),
 ('smk-instrumentation','sm_kit','Apeks / Miflex','2x SPG Tek 52 + flexibles sidemount',312,'~312 €',0.8,'EU','2 manomètres + flexibles (long hose, court, HP x2, inflateur)','SPG Apeks Tek 52 mm 300 bar','https://www.bubble-diving.com/plonge/instruments/manometres/manometre-noir-tek-52mm-300bar-apeks.html',1),
 ('smk-rigging','sm_kit','D-Luxe','Kit rigging SM + bolt snaps + bungee',120,'~120 €',0.5,'EU','Colliers/sangles de bloc + bolt snaps + bungee (kit + 2 NX snaps)','D-Luxe rigging set','https://dluxedivegear.de/en/shop/sidemount-rigging-set-std-personalised/',1);

-- ============================ DEVIS (4) ==============================
-- 4 devis indépendants. Un setup complet = 1 BCD + thermique + accessoires.
INSERT INTO config (id,label,sort) VALUES
 ('bcd_backmount','Backmount BCD (poches + accessoires)',1),
 ('bcd_sidemount','Sidemount BCD (poches + accessoires)',2),
 ('thermal','Protection thermale (avec chaussons)',3),
 ('accessories','Accessoires (ordi, compas...)',4);

-- --- Devis 1 : Backmount BCD ---
INSERT INTO config_item (config_id,section,item_id,qty) VALUES
 ('bcd_backmount','stab','bcd-halcyon-pro-era30',1),
 ('bcd_backmount','detendeurs','fs-scubapro-mk19-evo',1),
 ('bcd_backmount','detendeurs','ss-scubapro-g260',1);

-- --- Devis 2 : Sidemount BCD (stab + poches lest + détendeurs x2 + instrumentation + gréement) ---
INSERT INTO config_item (config_id,section,item_id,qty) VALUES
 ('bcd_sidemount','stab','sm-xdeep-stealth-20-tec',1),
 ('bcd_sidemount','poches','smk-xdeep-pockets',1),
 ('bcd_sidemount','detendeurs','fs-scubapro-mk19-evo',2),
 ('bcd_sidemount','detendeurs','ss-scubapro-g260',2),
 ('bcd_sidemount','instrumentation','smk-instrumentation',1),
 ('bcd_sidemount','rigging','smk-rigging',1);

-- --- Devis 3 : Protection thermale (combi + veste cagoule + sous-couche + bottillons + chaussettes) ---
INSERT INTO config_item (config_id,section,item_id,qty) VALUES
 ('thermal','protection','suit-scubapro-everflex-yulex',1),
 ('thermal','protection','suit-scubapro-yulex-hood',1),
 ('thermal','protection','base-sharkskin-t2',1),
 ('thermal','protection','boot-scubapro-hd',1),
 ('thermal','protection','sock-sharkskin-tifir',1);

-- --- Devis 4 : Accessoires (ordi, compas, masque + secours, palmes, lampe, DSMB, spool, coupe-ligne, wetnotes, sac, protection) ---
INSERT INTO config_item (config_id,section,item_id,qty) VALUES
 ('accessories','accessoires','comp-shearwater-peregrine',1),
 ('accessories','accessoires','comp-suunto-sk8',1),
 ('accessories','accessoires','mask-hollis-m1',1),
 ('accessories','accessoires','mask-cressi-f1',1),
 ('accessories','accessoires','fins-tecline-lightjet',1),
 ('accessories','accessoires','light-orcatorch-dc710',1),
 ('accessories','accessoires','dsmb-apeks-14',1),
 ('accessories','accessoires','spool-halcyon-defender45',1),
 ('accessories','accessoires','cut-eezycut-trilobite',1),
 ('accessories','accessoires','wn-halcyon-notebook',1),
 ('accessories','accessoires','bag-seac-equipage500',1),
 ('accessories','accessoires','prot-mares-shell',1);
