-- Curing-Gläser erweitern: Behältertyp, Größe, Gewichte, Boveda, Qualität
ALTER TABLE curing_glaeser
  ADD COLUMN IF NOT EXISTS behaelter_typ TEXT DEFAULT 'glas'
    CHECK (behaelter_typ IN ('glas', 'grove_bag', 'cvault', 'eimer', 'sonstig')),
  ADD COLUMN IF NOT EXISTS groesse_ml INTEGER,
  ADD COLUMN IF NOT EXISTS nass_gewicht_g NUMERIC(8,1),
  ADD COLUMN IF NOT EXISTS endgewicht_g NUMERIC(8,1),
  ADD COLUMN IF NOT EXISTS boveda_typ TEXT,
  ADD COLUMN IF NOT EXISTS qualitaet_notizen JSONB DEFAULT '{}';

-- Curing-Messwerte erweitern: Temperatur, Gewicht, Lüftung
ALTER TABLE curing_messwerte
  ADD COLUMN IF NOT EXISTS temperatur NUMERIC(4,1),
  ADD COLUMN IF NOT EXISTS gewicht_g NUMERIC(8,1),
  ADD COLUMN IF NOT EXISTS gelueftet BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS lueftungsdauer_min INTEGER;
