-- Durchgänge: zelt_id durch anbauflaeche_id ersetzen
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS anbauflaeche_id UUID REFERENCES anbauflaechen(id);

-- Equipment-Spalten entfernen (sind jetzt auf Anbaufläche)
ALTER TABLE durchgaenge DROP COLUMN IF EXISTS licht_watt;
ALTER TABLE durchgaenge DROP COLUMN IF EXISTS bewaesserung;

-- zelt_id FK entfernen (Zelt wird über Anbaufläche ermittelt)
ALTER TABLE durchgaenge DROP COLUMN IF EXISTS zelt_id;

-- Index für schnelle Abfrage
CREATE INDEX IF NOT EXISTS idx_durchgaenge_anbauflaeche ON durchgaenge(anbauflaeche_id);
CREATE INDEX IF NOT EXISTS idx_durchgaenge_sorte ON durchgaenge(sorte_id);
