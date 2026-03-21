-- Tägliche Logs pro Grow-Durchgang
CREATE TABLE IF NOT EXISTS tages_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  durchgang_id UUID NOT NULL REFERENCES durchgaenge(id) ON DELETE CASCADE,
  datum DATE NOT NULL,
  vegi_tag INTEGER,
  bluete_tag INTEGER,

  -- Umgebung
  temp_tag REAL,
  temp_nacht REAL,
  relf_tag REAL,
  relf_nacht REAL,
  licht_watt INTEGER,
  lampen_hoehe INTEGER,
  pflanzen_hoehe REAL,

  -- Bewässerung / Tank
  wasser_ml INTEGER,
  ph REAL,
  ec REAL,
  tank_fuellstand INTEGER,
  tank_temp REAL,

  -- Nährstoffe (flexibel per JSONB)
  naehrstoffe JSONB,

  bemerkung TEXT,
  erstellt_von UUID DEFAULT auth.uid() REFERENCES auth.users(id),
  erstellt_am TIMESTAMPTZ DEFAULT now(),
  aktualisiert_am TIMESTAMPTZ DEFAULT now(),

  UNIQUE(durchgang_id, datum)
);

-- RLS aktivieren
ALTER TABLE tages_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Eigene Tages-Logs sehen" ON tages_logs
  FOR SELECT USING (erstellt_von = auth.uid());
CREATE POLICY "Eigene Tages-Logs erstellen" ON tages_logs
  FOR INSERT WITH CHECK (erstellt_von = auth.uid());
CREATE POLICY "Eigene Tages-Logs bearbeiten" ON tages_logs
  FOR UPDATE USING (erstellt_von = auth.uid());
CREATE POLICY "Eigene Tages-Logs löschen" ON tages_logs
  FOR DELETE USING (erstellt_von = auth.uid());

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tages_logs_durchgang ON tages_logs(durchgang_id);
CREATE INDEX IF NOT EXISTS idx_tages_logs_datum ON tages_logs(durchgang_id, datum);

-- Aktualisiert-Trigger
CREATE OR REPLACE TRIGGER trigger_tages_logs_aktualisiert
  BEFORE UPDATE ON tages_logs
  FOR EACH ROW
  EXECUTE FUNCTION aktualisiert_am_setzen();
