-- Geschlecht-Feld hinzufügen
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS geschlecht TEXT DEFAULT 'feminisiert';

-- Pflanzenhöhe-Felder hinzufügen
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS pflanzenhohe_zuechter TEXT;
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS pflanzenhohe_eigen TEXT;

-- Ertrag-Felder umbenennen (Selektion/Produktion → Züchter/Eigen)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sorten' AND column_name = 'ertrag_selektion') THEN
    ALTER TABLE sorten RENAME COLUMN ertrag_selektion TO ertrag_zuechter;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sorten' AND column_name = 'ertrag_produktion') THEN
    ALTER TABLE sorten RENAME COLUMN ertrag_produktion TO ertrag_eigen;
  END IF;
END $$;

-- Nicht mehr benötigte Felder entfernen
ALTER TABLE sorten DROP COLUMN IF EXISTS topping_empfohlen;
ALTER TABLE sorten DROP COLUMN IF EXISTS hat_mutterpflanze;

-- Status-Constraint um 'geplant' erweitern
ALTER TABLE sorten DROP CONSTRAINT IF EXISTS sorten_status_check;
ALTER TABLE sorten ADD CONSTRAINT sorten_status_check
  CHECK (status = ANY (ARRAY['geplant', 'aktiv', 'selektion', 'beendet', 'stash']));
