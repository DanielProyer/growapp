-- Pflanzenanzahl pro Phase statt einzelnem Wert
-- Pflanzen können durch Ausfälle, Zwitter, Krüppelwuchs etc. weniger werden

ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS pflanzen_anzahl_start INTEGER;
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS pflanzen_anzahl_vegi INTEGER;
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS pflanzen_anzahl_bluete INTEGER;

-- Bestehende Daten migrieren
UPDATE durchgaenge SET pflanzen_anzahl_start = pflanzen_anzahl
WHERE pflanzen_anzahl IS NOT NULL AND pflanzen_anzahl_start IS NULL;

-- Alte Spalte entfernen
ALTER TABLE durchgaenge DROP COLUMN IF EXISTS pflanzen_anzahl;
