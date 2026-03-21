-- ============================================
-- GrowApp - Alle Tabellen auf Deutsch umbenennen
-- Da noch keine echten Daten vorhanden sind,
-- werden alle Tabellen neu erstellt.
-- ============================================

-- Alte Trigger entfernen
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS update_strains_updated_at ON strains;
DROP TRIGGER IF EXISTS update_grow_tents_updated_at ON grow_tents;
DROP TRIGGER IF EXISTS update_grows_updated_at ON grows;
DROP TRIGGER IF EXISTS update_plants_updated_at ON plants;
DROP TRIGGER IF EXISTS update_selections_updated_at ON selections;
DROP TRIGGER IF EXISTS update_selection_plants_updated_at ON selection_plants;
DROP TRIGGER IF EXISTS update_mothers_updated_at ON mothers;
DROP TRIGGER IF EXISTS update_curing_jars_updated_at ON curing_jars;
DROP TRIGGER IF EXISTS update_pest_incidents_updated_at ON pest_incidents;
DROP TRIGGER IF EXISTS update_inventory_items_updated_at ON inventory_items;
DROP TRIGGER IF EXISTS update_calendar_events_updated_at ON calendar_events;

-- Alle alten Tabellen entfernen (in korrekter Reihenfolge wegen FK)
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS calendar_events CASCADE;
DROP TABLE IF EXISTS photos CASCADE;
DROP TABLE IF EXISTS inventory_transactions CASCADE;
DROP TABLE IF EXISTS inventory_items CASCADE;
DROP TABLE IF EXISTS pest_incidents CASCADE;
DROP TABLE IF EXISTS curing_readings CASCADE;
DROP TABLE IF EXISTS curing_jars CASCADE;
DROP TABLE IF EXISTS cuttings CASCADE;
DROP TABLE IF EXISTS mothers CASCADE;
DROP TABLE IF EXISTS growth_measurements CASCADE;
DROP TABLE IF EXISTS selection_plants CASCADE;
DROP TABLE IF EXISTS selection_criteria CASCADE;
DROP TABLE IF EXISTS selections CASCADE;
DROP TABLE IF EXISTS plants CASCADE;
DROP TABLE IF EXISTS daily_logs CASCADE;
DROP TABLE IF EXISTS grows CASCADE;
DROP TABLE IF EXISTS grow_tents CASCADE;
DROP TABLE IF EXISTS strains CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Alte Funktionen entfernen
DROP FUNCTION IF EXISTS handle_new_user();
DROP FUNCTION IF EXISTS update_updated_at();

-- ============================================
-- Profile
-- ============================================
CREATE TABLE profile (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  anzeigename TEXT,
  avatar_url TEXT,
  rolle TEXT DEFAULT 'benutzer' CHECK (rolle IN ('admin', 'benutzer', 'betrachter')),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: Profil automatisch bei User-Registrierung erstellen
CREATE OR REPLACE FUNCTION neuer_benutzer_handler()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profile (id, anzeigename)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'display_name',
      split_part(NEW.email, '@', 1)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER bei_neuem_benutzer
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION neuer_benutzer_handler();

-- ============================================
-- Sorten
-- ============================================
CREATE TABLE sorten (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  zuechter TEXT,
  indica_anteil INTEGER DEFAULT 0 CHECK (indica_anteil BETWEEN 0 AND 100),
  sativa_anteil INTEGER DEFAULT 0 CHECK (sativa_anteil BETWEEN 0 AND 100),
  thc_gehalt NUMERIC(4,1),
  cbd_gehalt NUMERIC(4,1),
  bluetezeit_zuechter INTEGER,
  bluetezeit_eigen INTEGER,
  bluetezeit_sicherheit INTEGER,
  keimquote INTEGER CHECK (keimquote BETWEEN 0 AND 100),
  ertrag_selektion TEXT,
  ertrag_produktion TEXT,
  geschmack TEXT,
  wirkung TEXT,
  topping_empfohlen BOOLEAN DEFAULT FALSE,
  samen_anzahl INTEGER DEFAULT 0,
  hat_mutterpflanze BOOLEAN DEFAULT FALSE,
  status TEXT DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'selektion', 'beendet', 'stash')),
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Zelte
-- ============================================
CREATE TABLE zelte (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  breite_cm NUMERIC(5,1),
  tiefe_cm NUMERIC(5,1),
  hoehe_cm NUMERIC(5,1),
  licht_typ TEXT,
  licht_watt INTEGER,
  lueftung TEXT,
  bewaesserung TEXT,
  standort TEXT,
  etagen INTEGER DEFAULT 1,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Durchgaenge (Grow-Zyklen)
-- ============================================
CREATE TABLE durchgaenge (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zelt_id UUID REFERENCES zelte(id),
  sorte_id UUID REFERENCES sorten(id),
  status TEXT DEFAULT 'vorbereitung' CHECK (status IN (
    'vorbereitung', 'vegetation', 'bluete', 'ernte', 'curing', 'beendet'
  )),
  pflanzen_anzahl INTEGER,
  licht_watt INTEGER,
  bewaesserung TEXT,
  steckling_datum DATE,
  vegi_start DATE,
  bluete_start DATE,
  ernte_datum DATE,
  einglas_datum DATE,
  ernte_methode TEXT CHECK (ernte_methode IS NULL OR ernte_methode IN (
    'nassschnitt', 'trimbag', 'handschnitt'
  )),
  trocken_ertrag_g NUMERIC(8,1),
  trim_g NUMERIC(8,1),
  ertrag_pro_watt NUMERIC(6,3),
  siebung_1 NUMERIC(8,1),
  siebung_2 NUMERIC(8,1),
  siebung_3 NUMERIC(8,1),
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Tages-Logs
-- ============================================
CREATE TABLE tages_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  durchgang_id UUID NOT NULL REFERENCES durchgaenge(id) ON DELETE CASCADE,
  datum DATE NOT NULL,
  vegi_tag INTEGER,
  bluete_tag INTEGER,
  bluete_woche INTEGER,
  temp_tag NUMERIC(4,1),
  temp_nacht NUMERIC(4,1),
  rlf_tag INTEGER,
  rlf_nacht INTEGER,
  licht_watt NUMERIC(6,1),
  pflanzen_hoehe INTEGER,
  lampen_hoehe INTEGER,
  tank_inhalt INTEGER,
  ph_wert NUMERIC(3,1),
  ec_wert NUMERIC(4,2),
  tank_temp NUMERIC(4,1),
  wasser_ml INTEGER,
  naehrstoffe JSONB DEFAULT '{}',
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(durchgang_id, datum)
);

-- ============================================
-- Pflanzen
-- ============================================
CREATE TABLE pflanzen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  durchgang_id UUID REFERENCES durchgaenge(id),
  sorte_id UUID REFERENCES sorten(id),
  pflanzen_nr INTEGER NOT NULL,
  status TEXT DEFAULT 'keimung' CHECK (status IN (
    'keimung', 'vegetation', 'bluete', 'ernte', 'beendet', 'entsorgt'
  )),
  aussaat_datum DATE,
  keim_datum DATE,
  topf_1l_datum DATE,
  bluete_start DATE,
  ernte_datum DATE,
  hoehe_bluete_start NUMERIC(5,1),
  hoehe_ernte NUMERIC(5,1),
  stammdicke_bluete NUMERIC(4,1),
  stammdicke_ernte NUMERIC(4,1),
  nass_gewicht_g NUMERIC(8,1),
  trocken_gewicht_g NUMERIC(8,1),
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Selektionen
-- ============================================
CREATE TABLE selektionen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sorte_id UUID NOT NULL REFERENCES sorten(id),
  durchgang_id UUID REFERENCES durchgaenge(id),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'abgeschlossen')),
  start_datum DATE,
  samen_anzahl INTEGER,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE selektions_kriterien (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  selektion_id UUID NOT NULL REFERENCES selektionen(id) ON DELETE CASCADE,
  kriterium_name TEXT NOT NULL,
  gewichtung NUMERIC(3,2) DEFAULT 1.0,
  beschreibung TEXT,
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE selektions_pflanzen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  selektion_id UUID NOT NULL REFERENCES selektionen(id) ON DELETE CASCADE,
  pflanze_id UUID NOT NULL REFERENCES pflanzen(id),
  keeper_status TEXT DEFAULT 'vielleicht' CHECK (keeper_status IN ('ja', 'nein', 'vielleicht')),
  bewertung_vigor INTEGER CHECK (bewertung_vigor BETWEEN 1 AND 10),
  bewertung_struktur INTEGER CHECK (bewertung_struktur BETWEEN 1 AND 10),
  bewertung_harz INTEGER CHECK (bewertung_harz BETWEEN 1 AND 10),
  bewertung_aroma INTEGER CHECK (bewertung_aroma BETWEEN 1 AND 10),
  bewertung_ertrag INTEGER CHECK (bewertung_ertrag BETWEEN 1 AND 10),
  bewertung_schaedlingsresistenz INTEGER CHECK (bewertung_schaedlingsresistenz BETWEEN 1 AND 10),
  bewertung_gesamt NUMERIC(4,2),
  trichom_notizen JSONB DEFAULT '{}',
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Wachstums-Messungen
-- ============================================
CREATE TABLE wachstums_messungen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pflanze_id UUID NOT NULL REFERENCES pflanzen(id) ON DELETE CASCADE,
  datum DATE NOT NULL,
  hoehe_cm NUMERIC(5,1),
  nodien_anzahl INTEGER,
  stammdicke NUMERIC(4,1),
  getoppt BOOLEAN DEFAULT FALSE,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Muetterpflanzen
-- ============================================
CREATE TABLE muetterpflanzen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sorte_id UUID NOT NULL REFERENCES sorten(id),
  herkunft_pflanze_id UUID REFERENCES pflanzen(id),
  klon_nummer INTEGER,
  status TEXT DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'entsorgt')),
  steckling_datum DATE,
  topf_1l_datum DATE,
  topf_3_5l_datum DATE,
  entsorgt_datum DATE,
  entsorgt_grund TEXT,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Stecklinge
-- ============================================
CREATE TABLE stecklinge (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mutter_id UUID NOT NULL REFERENCES muetterpflanzen(id),
  datum DATE NOT NULL,
  anzahl_unten INTEGER DEFAULT 0,
  anzahl_oben INTEGER DEFAULT 0,
  naehrstoffe JSONB DEFAULT '{}',
  erfolgsrate INTEGER CHECK (erfolgsrate IS NULL OR erfolgsrate BETWEEN 0 AND 100),
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Curing-Glaeser
-- ============================================
CREATE TABLE curing_glaeser (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  durchgang_id UUID NOT NULL REFERENCES durchgaenge(id),
  sorte_id UUID REFERENCES sorten(id),
  glas_nr INTEGER NOT NULL,
  trim_methode TEXT CHECK (trim_methode IS NULL OR trim_methode IN (
    'nassschnitt', 'trimbag', 'handschnitt'
  )),
  status TEXT DEFAULT 'trocknung' CHECK (status IN ('trocknung', 'curing', 'fertig')),
  schimmel_erkannt BOOLEAN DEFAULT FALSE,
  ernte_datum DATE,
  einglas_datum DATE,
  trocken_gewicht_g NUMERIC(8,1),
  ziel_rlf INTEGER,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE curing_messwerte (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  glas_id UUID NOT NULL REFERENCES curing_glaeser(id) ON DELETE CASCADE,
  datum DATE NOT NULL,
  rlf_prozent INTEGER,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Schaedlings-Vorfaelle
-- ============================================
CREATE TABLE schaedlings_vorfaelle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zelt_id UUID REFERENCES zelte(id),
  durchgang_id UUID REFERENCES durchgaenge(id),
  schaedling_typ TEXT NOT NULL CHECK (schaedling_typ IN (
    'thripse', 'spinnmilben', 'trauermücken', 'sonstige'
  )),
  schweregrad TEXT DEFAULT 'niedrig' CHECK (schweregrad IN (
    'niedrig', 'mittel', 'hoch', 'kritisch'
  )),
  erkannt_datum DATE NOT NULL,
  behoben_datum DATE,
  behandlung TEXT,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Inventar
-- ============================================
CREATE TABLE inventar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  kategorie TEXT NOT NULL CHECK (kategorie IN (
    'duenger', 'schaedlingsbekaempfung', 'medium', 'equipment', 'sonstige'
  )),
  einheit TEXT DEFAULT 'Stück',
  aktueller_bestand NUMERIC(10,2) DEFAULT 0,
  mindest_bestand NUMERIC(10,2) DEFAULT 0,
  lieferant TEXT,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE inventar_buchungen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artikel_id UUID NOT NULL REFERENCES inventar(id) ON DELETE CASCADE,
  typ TEXT NOT NULL CHECK (typ IN ('eingang', 'verbrauch')),
  menge NUMERIC(10,2) NOT NULL,
  datum DATE DEFAULT CURRENT_DATE,
  bemerkung TEXT,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Fotos
-- ============================================
CREATE TABLE fotos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  speicher_pfad TEXT NOT NULL,
  vorschau_pfad TEXT,
  beschreibung TEXT,
  pflanze_id UUID REFERENCES pflanzen(id),
  durchgang_id UUID REFERENCES durchgaenge(id),
  zelt_id UUID REFERENCES zelte(id),
  aufgenommen_am TIMESTAMPTZ,
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Kalender-Eintraege
-- ============================================
CREATE TABLE kalender_eintraege (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titel TEXT NOT NULL,
  beschreibung TEXT,
  typ TEXT DEFAULT 'allgemein' CHECK (typ IN (
    'bewaesserung', 'duengung', 'ernte', 'stecklinge', 'allgemein'
  )),
  geplant_am TIMESTAMPTZ NOT NULL,
  wiederholung TEXT,
  erledigt BOOLEAN DEFAULT FALSE,
  durchgang_id UUID REFERENCES durchgaenge(id),
  pflanze_id UUID REFERENCES pflanzen(id),
  erstellt_von UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  erstellt_am TIMESTAMPTZ DEFAULT NOW(),
  aktualisiert_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Benachrichtigungen
-- ============================================
CREATE TABLE benachrichtigungen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  benutzer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  titel TEXT NOT NULL,
  inhalt TEXT,
  typ TEXT DEFAULT 'info',
  gelesen_am TIMESTAMPTZ,
  kalender_eintrag_id UUID REFERENCES kalender_eintraege(id),
  erstellt_am TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Row Level Security (RLS)
-- ============================================
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE sorten ENABLE ROW LEVEL SECURITY;
ALTER TABLE zelte ENABLE ROW LEVEL SECURITY;
ALTER TABLE durchgaenge ENABLE ROW LEVEL SECURITY;
ALTER TABLE tages_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE pflanzen ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektionen ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektions_kriterien ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektions_pflanzen ENABLE ROW LEVEL SECURITY;
ALTER TABLE wachstums_messungen ENABLE ROW LEVEL SECURITY;
ALTER TABLE muetterpflanzen ENABLE ROW LEVEL SECURITY;
ALTER TABLE stecklinge ENABLE ROW LEVEL SECURITY;
ALTER TABLE curing_glaeser ENABLE ROW LEVEL SECURITY;
ALTER TABLE curing_messwerte ENABLE ROW LEVEL SECURITY;
ALTER TABLE schaedlings_vorfaelle ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventar ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventar_buchungen ENABLE ROW LEVEL SECURITY;
ALTER TABLE fotos ENABLE ROW LEVEL SECURITY;
ALTER TABLE kalender_eintraege ENABLE ROW LEVEL SECURITY;
ALTER TABLE benachrichtigungen ENABLE ROW LEVEL SECURITY;

-- Profile
CREATE POLICY "Eigenes Profil lesen" ON profile FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Eigenes Profil erstellen" ON profile FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Eigenes Profil bearbeiten" ON profile FOR UPDATE USING (auth.uid() = id);

-- Sorten
CREATE POLICY "Sorten lesen" ON sorten FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Sorten erstellen" ON sorten FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Sorten bearbeiten" ON sorten FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Sorten loeschen" ON sorten FOR DELETE USING (auth.uid() = erstellt_von);

-- Zelte
CREATE POLICY "Zelte lesen" ON zelte FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Zelte erstellen" ON zelte FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Zelte bearbeiten" ON zelte FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Zelte loeschen" ON zelte FOR DELETE USING (auth.uid() = erstellt_von);

-- Durchgaenge
CREATE POLICY "Durchgaenge lesen" ON durchgaenge FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Durchgaenge erstellen" ON durchgaenge FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Durchgaenge bearbeiten" ON durchgaenge FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Durchgaenge loeschen" ON durchgaenge FOR DELETE USING (auth.uid() = erstellt_von);

-- Tages-Logs
CREATE POLICY "Logs lesen" ON tages_logs FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Logs erstellen" ON tages_logs FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Logs bearbeiten" ON tages_logs FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Logs loeschen" ON tages_logs FOR DELETE USING (auth.uid() = erstellt_von);

-- Pflanzen
CREATE POLICY "Pflanzen lesen" ON pflanzen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Pflanzen erstellen" ON pflanzen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Pflanzen bearbeiten" ON pflanzen FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Pflanzen loeschen" ON pflanzen FOR DELETE USING (auth.uid() = erstellt_von);

-- Selektionen
CREATE POLICY "Selektionen lesen" ON selektionen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Selektionen erstellen" ON selektionen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Selektionen bearbeiten" ON selektionen FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Selektionen loeschen" ON selektionen FOR DELETE USING (auth.uid() = erstellt_von);

-- Selektions-Kriterien
CREATE POLICY "Kriterien lesen" ON selektions_kriterien FOR SELECT
  USING (EXISTS (SELECT 1 FROM selektionen WHERE selektionen.id = selektions_kriterien.selektion_id AND selektionen.erstellt_von = auth.uid()));
CREATE POLICY "Kriterien erstellen" ON selektions_kriterien FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM selektionen WHERE selektionen.id = selektions_kriterien.selektion_id AND selektionen.erstellt_von = auth.uid()));
CREATE POLICY "Kriterien bearbeiten" ON selektions_kriterien FOR UPDATE
  USING (EXISTS (SELECT 1 FROM selektionen WHERE selektionen.id = selektions_kriterien.selektion_id AND selektionen.erstellt_von = auth.uid()));
CREATE POLICY "Kriterien loeschen" ON selektions_kriterien FOR DELETE
  USING (EXISTS (SELECT 1 FROM selektionen WHERE selektionen.id = selektions_kriterien.selektion_id AND selektionen.erstellt_von = auth.uid()));

-- Selektions-Pflanzen
CREATE POLICY "Sel-Pflanzen lesen" ON selektions_pflanzen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Sel-Pflanzen erstellen" ON selektions_pflanzen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Sel-Pflanzen bearbeiten" ON selektions_pflanzen FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Sel-Pflanzen loeschen" ON selektions_pflanzen FOR DELETE USING (auth.uid() = erstellt_von);

-- Wachstums-Messungen
CREATE POLICY "Messungen lesen" ON wachstums_messungen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Messungen erstellen" ON wachstums_messungen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Messungen bearbeiten" ON wachstums_messungen FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Messungen loeschen" ON wachstums_messungen FOR DELETE USING (auth.uid() = erstellt_von);

-- Muetterpflanzen
CREATE POLICY "Muetter lesen" ON muetterpflanzen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Muetter erstellen" ON muetterpflanzen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Muetter bearbeiten" ON muetterpflanzen FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Muetter loeschen" ON muetterpflanzen FOR DELETE USING (auth.uid() = erstellt_von);

-- Stecklinge
CREATE POLICY "Stecklinge lesen" ON stecklinge FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Stecklinge erstellen" ON stecklinge FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Stecklinge bearbeiten" ON stecklinge FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Stecklinge loeschen" ON stecklinge FOR DELETE USING (auth.uid() = erstellt_von);

-- Curing-Glaeser
CREATE POLICY "Glaeser lesen" ON curing_glaeser FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Glaeser erstellen" ON curing_glaeser FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Glaeser bearbeiten" ON curing_glaeser FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Glaeser loeschen" ON curing_glaeser FOR DELETE USING (auth.uid() = erstellt_von);

-- Curing-Messwerte
CREATE POLICY "Messwerte lesen" ON curing_messwerte FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Messwerte erstellen" ON curing_messwerte FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Messwerte bearbeiten" ON curing_messwerte FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Messwerte loeschen" ON curing_messwerte FOR DELETE USING (auth.uid() = erstellt_von);

-- Schaedlings-Vorfaelle
CREATE POLICY "Schaedlinge lesen" ON schaedlings_vorfaelle FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Schaedlinge erstellen" ON schaedlings_vorfaelle FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Schaedlinge bearbeiten" ON schaedlings_vorfaelle FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Schaedlinge loeschen" ON schaedlings_vorfaelle FOR DELETE USING (auth.uid() = erstellt_von);

-- Inventar
CREATE POLICY "Inventar lesen" ON inventar FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Inventar erstellen" ON inventar FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Inventar bearbeiten" ON inventar FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Inventar loeschen" ON inventar FOR DELETE USING (auth.uid() = erstellt_von);

-- Inventar-Buchungen
CREATE POLICY "Buchungen lesen" ON inventar_buchungen FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Buchungen erstellen" ON inventar_buchungen FOR INSERT WITH CHECK (auth.uid() = erstellt_von);

-- Fotos
CREATE POLICY "Fotos lesen" ON fotos FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Fotos erstellen" ON fotos FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Fotos loeschen" ON fotos FOR DELETE USING (auth.uid() = erstellt_von);

-- Kalender-Eintraege
CREATE POLICY "Termine lesen" ON kalender_eintraege FOR SELECT USING (auth.uid() = erstellt_von);
CREATE POLICY "Termine erstellen" ON kalender_eintraege FOR INSERT WITH CHECK (auth.uid() = erstellt_von);
CREATE POLICY "Termine bearbeiten" ON kalender_eintraege FOR UPDATE USING (auth.uid() = erstellt_von);
CREATE POLICY "Termine loeschen" ON kalender_eintraege FOR DELETE USING (auth.uid() = erstellt_von);

-- Benachrichtigungen
CREATE POLICY "Benachrichtigungen lesen" ON benachrichtigungen FOR SELECT USING (auth.uid() = benutzer_id);
CREATE POLICY "Benachrichtigungen bearbeiten" ON benachrichtigungen FOR UPDATE USING (auth.uid() = benutzer_id);

-- ============================================
-- Indizes
-- ============================================
CREATE INDEX idx_sorten_erstellt_von ON sorten(erstellt_von);
CREATE INDEX idx_sorten_status ON sorten(status);
CREATE INDEX idx_zelte_erstellt_von ON zelte(erstellt_von);
CREATE INDEX idx_durchgaenge_erstellt_von ON durchgaenge(erstellt_von);
CREATE INDEX idx_durchgaenge_zelt_id ON durchgaenge(zelt_id);
CREATE INDEX idx_durchgaenge_sorte_id ON durchgaenge(sorte_id);
CREATE INDEX idx_durchgaenge_status ON durchgaenge(status);
CREATE INDEX idx_tages_logs_durchgang_id ON tages_logs(durchgang_id);
CREATE INDEX idx_tages_logs_datum ON tages_logs(datum);
CREATE INDEX idx_pflanzen_durchgang_id ON pflanzen(durchgang_id);
CREATE INDEX idx_pflanzen_sorte_id ON pflanzen(sorte_id);
CREATE INDEX idx_selektionen_sorte_id ON selektionen(sorte_id);
CREATE INDEX idx_selektions_pflanzen_selektion_id ON selektions_pflanzen(selektion_id);
CREATE INDEX idx_selektions_pflanzen_pflanze_id ON selektions_pflanzen(pflanze_id);
CREATE INDEX idx_wachstums_messungen_pflanze_id ON wachstums_messungen(pflanze_id);
CREATE INDEX idx_muetterpflanzen_sorte_id ON muetterpflanzen(sorte_id);
CREATE INDEX idx_stecklinge_mutter_id ON stecklinge(mutter_id);
CREATE INDEX idx_curing_glaeser_durchgang_id ON curing_glaeser(durchgang_id);
CREATE INDEX idx_curing_messwerte_glas_id ON curing_messwerte(glas_id);
CREATE INDEX idx_fotos_pflanze_id ON fotos(pflanze_id);
CREATE INDEX idx_fotos_durchgang_id ON fotos(durchgang_id);
CREATE INDEX idx_kalender_eintraege_geplant_am ON kalender_eintraege(geplant_am);
CREATE INDEX idx_benachrichtigungen_benutzer_id ON benachrichtigungen(benutzer_id);

-- ============================================
-- Aktualisiert-Am Trigger
-- ============================================
CREATE OR REPLACE FUNCTION aktualisiert_am_setzen()
RETURNS TRIGGER AS $$
BEGIN
  NEW.aktualisiert_am = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER aktualisierung_profile BEFORE UPDATE ON profile FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_sorten BEFORE UPDATE ON sorten FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_zelte BEFORE UPDATE ON zelte FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_durchgaenge BEFORE UPDATE ON durchgaenge FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_pflanzen BEFORE UPDATE ON pflanzen FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_selektionen BEFORE UPDATE ON selektionen FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_selektions_pflanzen BEFORE UPDATE ON selektions_pflanzen FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_muetterpflanzen BEFORE UPDATE ON muetterpflanzen FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_curing_glaeser BEFORE UPDATE ON curing_glaeser FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_schaedlings_vorfaelle BEFORE UPDATE ON schaedlings_vorfaelle FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_inventar BEFORE UPDATE ON inventar FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
CREATE TRIGGER aktualisierung_kalender_eintraege BEFORE UPDATE ON kalender_eintraege FOR EACH ROW EXECUTE FUNCTION aktualisiert_am_setzen();
