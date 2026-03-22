-- Schädlingstypen erweitern (DROP + re-ADD CHECK constraint)
ALTER TABLE schaedlings_vorfaelle DROP CONSTRAINT IF EXISTS schaedlings_vorfaelle_schaedling_typ_check;
ALTER TABLE schaedlings_vorfaelle ADD CONSTRAINT schaedlings_vorfaelle_schaedling_typ_check
  CHECK (schaedling_typ IN (
    'thripse', 'spinnmilben', 'trauermücken', 'blattlaeuse', 'weisse_fliegen',
    'minierfliegen', 'breitmilben', 'rostmilben', 'raupen',
    'echter_mehltau', 'falscher_mehltau', 'botrytis', 'wurzelfaeule',
    'alternaria', 'septoria', 'umfallkrankheit', 'sonstige'
  ));

-- Behandlungen-Tabelle
CREATE TABLE IF NOT EXISTS schaedlings_behandlungen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vorfall_id UUID REFERENCES schaedlings_vorfaelle(id) ON DELETE CASCADE,
  zelt_id UUID NOT NULL REFERENCES zelte(id),
  behandlung_typ TEXT NOT NULL CHECK (behandlung_typ IN (
    'biologisch', 'chemisch', 'mechanisch', 'nuetzlinge'
  )),
  mittel TEXT NOT NULL,
  menge TEXT,
  datum DATE NOT NULL DEFAULT CURRENT_DATE,
  wirksamkeit TEXT CHECK (wirksamkeit IS NULL OR wirksamkeit IN (
    'keine', 'gering', 'mittel', 'gut', 'sehr_gut'
  )),
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- Fotos um vorfall_id erweitern
ALTER TABLE fotos ADD COLUMN IF NOT EXISTS vorfall_id UUID REFERENCES schaedlings_vorfaelle(id);

-- RLS
ALTER TABLE schaedlings_behandlungen ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Behandlungen lesen" ON schaedlings_behandlungen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Behandlungen erstellen" ON schaedlings_behandlungen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Behandlungen bearbeiten" ON schaedlings_behandlungen FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Behandlungen loeschen" ON schaedlings_behandlungen FOR DELETE USING (auth.uid() = erstellt_von);

-- Indizes
CREATE INDEX IF NOT EXISTS idx_behandlungen_vorfall_id ON schaedlings_behandlungen(vorfall_id);
CREATE INDEX IF NOT EXISTS idx_behandlungen_zelt_id ON schaedlings_behandlungen(zelt_id);
CREATE INDEX IF NOT EXISTS idx_fotos_vorfall_id ON fotos(vorfall_id);
CREATE INDEX IF NOT EXISTS idx_schaedlings_vorfaelle_zelt_id ON schaedlings_vorfaelle(zelt_id);

-- Trigger
CREATE TRIGGER aktualisierung_schaedlings_behandlungen
  BEFORE UPDATE ON schaedlings_behandlungen
  FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
