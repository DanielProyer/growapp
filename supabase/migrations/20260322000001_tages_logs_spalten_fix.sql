-- Tages-Logs: Spaltennamen an Code anpassen
ALTER TABLE tages_logs RENAME COLUMN rlf_tag TO relf_tag;
ALTER TABLE tages_logs RENAME COLUMN rlf_nacht TO relf_nacht;
ALTER TABLE tages_logs RENAME COLUMN ph_wert TO ph;
ALTER TABLE tages_logs RENAME COLUMN ec_wert TO ec;
ALTER TABLE tages_logs RENAME COLUMN tank_inhalt TO tank_fuellstand;

-- Spaltentypen anpassen (NUMERIC → REAL für Konsistenz)
ALTER TABLE tages_logs ALTER COLUMN temp_tag TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN temp_nacht TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN relf_tag TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN relf_nacht TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN licht_watt TYPE INTEGER USING licht_watt::INTEGER;
ALTER TABLE tages_logs ALTER COLUMN pflanzen_hoehe TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN ph TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN ec TYPE REAL;
ALTER TABLE tages_logs ALTER COLUMN tank_temp TYPE REAL;

-- Fehlende Spalte hinzufügen
ALTER TABLE tages_logs ADD COLUMN IF NOT EXISTS aktualisiert_am TIMESTAMPTZ DEFAULT now();

-- Nicht mehr verwendete Spalte entfernen
ALTER TABLE tages_logs DROP COLUMN IF EXISTS bluete_woche;

-- Aktualisiert-Trigger (falls noch nicht vorhanden)
DROP TRIGGER IF EXISTS trigger_tages_logs_aktualisiert ON tages_logs;
CREATE TRIGGER trigger_tages_logs_aktualisiert
  BEFORE UPDATE ON tages_logs
  FOR EACH ROW
  EXECUTE FUNCTION aktualisiert_am_setzen();
