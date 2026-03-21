-- Durchgänge: Eine Anbaufläche pro Phase (Steckling, Vegi, Blüte)
-- Pflanzen können je nach Wachstumsphase auf unterschiedlichen Anbauflächen stehen

-- Drei separate FK-Spalten für die Phasen
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS steckling_anbauflaeche_id UUID REFERENCES anbauflaechen(id);
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS vegi_anbauflaeche_id UUID REFERENCES anbauflaechen(id);
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS bluete_anbauflaeche_id UUID REFERENCES anbauflaechen(id);

-- Bestehende Daten migrieren: alte anbauflaeche_id in alle drei Phasen kopieren
UPDATE durchgaenge SET
  steckling_anbauflaeche_id = anbauflaeche_id,
  vegi_anbauflaeche_id = anbauflaeche_id,
  bluete_anbauflaeche_id = anbauflaeche_id
WHERE anbauflaeche_id IS NOT NULL
  AND steckling_anbauflaeche_id IS NULL
  AND vegi_anbauflaeche_id IS NULL
  AND bluete_anbauflaeche_id IS NULL;

-- Alte Spalte entfernen
ALTER TABLE durchgaenge DROP COLUMN IF EXISTS anbauflaeche_id;

-- Status um 'steckling' erweitern
ALTER TABLE durchgaenge DROP CONSTRAINT IF EXISTS durchgaenge_status_check;
ALTER TABLE durchgaenge ADD CONSTRAINT durchgaenge_status_check
  CHECK (status IN ('vorbereitung', 'steckling', 'vegetation', 'bluete', 'ernte', 'curing', 'beendet'));

-- Indexe
DROP INDEX IF EXISTS idx_durchgaenge_anbauflaeche;
CREATE INDEX IF NOT EXISTS idx_durchgaenge_steckling_af ON durchgaenge(steckling_anbauflaeche_id);
CREATE INDEX IF NOT EXISTS idx_durchgaenge_vegi_af ON durchgaenge(vegi_anbauflaeche_id);
CREATE INDEX IF NOT EXISTS idx_durchgaenge_bluete_af ON durchgaenge(bluete_anbauflaeche_id);
