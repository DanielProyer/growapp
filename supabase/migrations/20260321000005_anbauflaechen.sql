-- Neue Tabelle: Anbauflächen (Bereiche innerhalb eines Zelts)
CREATE TABLE IF NOT EXISTS anbauflaechen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zelt_id UUID NOT NULL REFERENCES zelte(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  licht_typ TEXT,
  licht_watt INTEGER,
  lueftung TEXT,
  bewaesserung TEXT,
  etage INTEGER,
  bemerkung TEXT,
  erstellt_von UUID DEFAULT auth.uid() REFERENCES auth.users(id),
  erstellt_am TIMESTAMPTZ DEFAULT now(),
  aktualisiert_am TIMESTAMPTZ DEFAULT now()
);

-- RLS aktivieren
ALTER TABLE anbauflaechen ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Eigene Anbauflächen sehen" ON anbauflaechen
  FOR SELECT USING (erstellt_von = auth.uid());
CREATE POLICY "Eigene Anbauflächen erstellen" ON anbauflaechen
  FOR INSERT WITH CHECK (erstellt_von = auth.uid());
CREATE POLICY "Eigene Anbauflächen bearbeiten" ON anbauflaechen
  FOR UPDATE USING (erstellt_von = auth.uid());
CREATE POLICY "Eigene Anbauflächen löschen" ON anbauflaechen
  FOR DELETE USING (erstellt_von = auth.uid());

-- Index für schnelle Abfrage nach Zelt
CREATE INDEX IF NOT EXISTS idx_anbauflaechen_zelt ON anbauflaechen(zelt_id);

-- Aktualisiert-Trigger
CREATE OR REPLACE TRIGGER trigger_anbauflaechen_aktualisiert
  BEFORE UPDATE ON anbauflaechen
  FOR EACH ROW
  EXECUTE FUNCTION aktualisiert_am_setzen();

-- Equipment-Spalten vom Zelt entfernen (wandern zur Anbaufläche)
ALTER TABLE zelte DROP COLUMN IF EXISTS licht_typ;
ALTER TABLE zelte DROP COLUMN IF EXISTS licht_watt;
ALTER TABLE zelte DROP COLUMN IF EXISTS lueftung;
ALTER TABLE zelte DROP COLUMN IF EXISTS bewaesserung;
ALTER TABLE zelte DROP COLUMN IF EXISTS etagen;
