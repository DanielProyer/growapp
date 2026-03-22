-- Fotos für Inventar-Artikel ermöglichen
ALTER TABLE fotos ADD COLUMN IF NOT EXISTS inventar_id UUID REFERENCES inventar(id);
