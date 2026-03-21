-- Neue Felder für Sorten hinzufügen
ALTER TABLE sorten ADD COLUMN kreuzung TEXT;          -- z.B. "Jelly Donutz #117 × Purple Cartel"
ALTER TABLE sorten ADD COLUMN aroma TEXT;             -- z.B. "süß, fruchtig, erdig"
ALTER TABLE sorten ADD COLUMN terpenprofil TEXT;      -- z.B. "Myrcen, Limonen, Caryophyllen"
ALTER TABLE sorten ADD COLUMN grow_tipp TEXT;         -- Anbau-Tipps

-- Spalte "wirkung" umbenennen zu "wirkung_high" für Klarheit
ALTER TABLE sorten RENAME COLUMN wirkung TO wirkung_high;

-- Blütezeit Sicherheit entfernen (wird nicht benötigt)
ALTER TABLE sorten DROP COLUMN bluetezeit_sicherheit;
