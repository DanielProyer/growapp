-- Selektion erweitern: neue Bewertungsfelder auf selektions_pflanzen
ALTER TABLE selektions_pflanzen
  ADD COLUMN IF NOT EXISTS bewertung_festigkeit INTEGER CHECK (bewertung_festigkeit BETWEEN 1 AND 10),
  ADD COLUMN IF NOT EXISTS bewertung_geschmack INTEGER CHECK (bewertung_geschmack BETWEEN 1 AND 10),
  ADD COLUMN IF NOT EXISTS bewertung_wirkung INTEGER CHECK (bewertung_wirkung BETWEEN 1 AND 10),
  ADD COLUMN IF NOT EXISTS vorselektion BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS bewertung_notizen JSONB DEFAULT '{}';
