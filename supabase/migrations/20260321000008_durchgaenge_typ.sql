-- Durchgang-Typ: 'samen' oder 'steckling'
-- Bestimmt die verfügbaren Status-Phasen
ALTER TABLE durchgaenge ADD COLUMN IF NOT EXISTS typ TEXT NOT NULL DEFAULT 'steckling';

-- Typ-Constraint
ALTER TABLE durchgaenge DROP CONSTRAINT IF EXISTS durchgaenge_typ_check;
ALTER TABLE durchgaenge ADD CONSTRAINT durchgaenge_typ_check
  CHECK (typ IN ('samen', 'steckling'));

-- Status um 'keimung' erweitern (für Samen-Grows)
ALTER TABLE durchgaenge DROP CONSTRAINT IF EXISTS durchgaenge_status_check;
ALTER TABLE durchgaenge ADD CONSTRAINT durchgaenge_status_check
  CHECK (status IN ('vorbereitung', 'keimung', 'steckling', 'vegetation', 'bluete', 'ernte', 'curing', 'beendet'));
