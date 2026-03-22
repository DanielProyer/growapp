-- Inventar erweitern: Typ, Preis, Kategorien, Buchungs-Stückpreis

-- Typ: Equipment vs Verbrauchsmaterial
ALTER TABLE inventar ADD COLUMN IF NOT EXISTS typ TEXT NOT NULL DEFAULT 'verbrauchsmaterial'
  CHECK (typ IN ('equipment', 'verbrauchsmaterial'));

-- Preis am Artikel (aktueller/letzter bekannter Preis)
ALTER TABLE inventar ADD COLUMN IF NOT EXISTS preis NUMERIC(10,2);

-- Kategorie-Constraint erweitern (alte droppen, neue setzen)
ALTER TABLE inventar DROP CONSTRAINT IF EXISTS inventar_kategorie_check;
ALTER TABLE inventar ADD CONSTRAINT inventar_kategorie_check
  CHECK (kategorie IN (
    'duenger', 'schaedlingsbekaempfung', 'medium',
    'beleuchtung', 'belueftung', 'bewaesserung', 'messinstrumente', 'zubehoer',
    'sonstige'
  ));

-- Stückpreis pro Buchung (Preis zum Zeitpunkt der Transaktion)
ALTER TABLE inventar_buchungen ADD COLUMN IF NOT EXISTS stueckpreis NUMERIC(10,2);
