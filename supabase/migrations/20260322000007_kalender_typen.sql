-- Kalender-Typen erweitern (umtopfen, schaedlingskontrolle, foto hinzufügen)
ALTER TABLE kalender_eintraege DROP CONSTRAINT IF EXISTS kalender_eintraege_typ_check;
ALTER TABLE kalender_eintraege ADD CONSTRAINT kalender_eintraege_typ_check
  CHECK (typ IN (
    'bewaesserung', 'duengung', 'ernte', 'stecklinge',
    'umtopfen', 'schaedlingskontrolle', 'foto', 'allgemein'
  ));

-- Erinnerungs-Spalte hinzufügen (Minuten vor dem Termin, 0 = keine)
ALTER TABLE kalender_eintraege ADD COLUMN IF NOT EXISTS erinnerung_minuten INTEGER DEFAULT 0;
