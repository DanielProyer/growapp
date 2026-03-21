-- Neue Felder für Sorten hinzufügen (idempotent)
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS kreuzung TEXT;
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS aroma TEXT;
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS terpenprofil TEXT;
ALTER TABLE sorten ADD COLUMN IF NOT EXISTS grow_tipp TEXT;

-- Spalte "wirkung" umbenennen zu "wirkung_high" für Klarheit
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sorten' AND column_name = 'wirkung') THEN
    ALTER TABLE sorten RENAME COLUMN wirkung TO wirkung_high;
  END IF;
END $$;

-- Blütezeit Sicherheit entfernen (wird nicht benötigt)
ALTER TABLE sorten DROP COLUMN IF EXISTS bluetezeit_sicherheit;
