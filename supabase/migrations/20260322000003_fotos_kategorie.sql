-- Kategorie-Spalte für Fotos (was wurde fotografiert)
ALTER TABLE fotos
  ADD COLUMN IF NOT EXISTS kategorie TEXT
  CHECK (kategorie IN ('pflanze', 'wurzeln', 'buds', 'trichome'));
