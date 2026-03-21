-- ============================================
-- GrowApp - Initiales Datenbank-Schema
-- ============================================

-- Profiles (erweitert auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'user', 'viewer')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: Profil automatisch bei User-Registrierung erstellen
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- Sorten (Strains)
-- ============================================
CREATE TABLE strains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  breeder TEXT,
  indica_pct INTEGER DEFAULT 0 CHECK (indica_pct BETWEEN 0 AND 100),
  sativa_pct INTEGER DEFAULT 0 CHECK (sativa_pct BETWEEN 0 AND 100),
  thc_pct NUMERIC(4,1),
  cbd_pct NUMERIC(4,1),
  bloom_time_breeder INTEGER, -- Tage
  bloom_time_own INTEGER, -- Tage (eigene Erfahrung)
  bloom_time_safety INTEGER, -- Sicherheitsfaktor Tage
  germination_rate INTEGER CHECK (germination_rate BETWEEN 0 AND 100),
  yield_selection TEXT,
  yield_production TEXT,
  taste TEXT,
  effect TEXT,
  topping_recommended BOOLEAN DEFAULT FALSE,
  seeds_count INTEGER DEFAULT 0,
  has_mother BOOLEAN DEFAULT FALSE,
  status TEXT DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'selektion', 'beendet', 'stash')),
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Grow-Zelte / Bereiche
-- ============================================
CREATE TABLE grow_tents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL, -- z.B. "P1", "P2", "S1", "M1"
  width_cm NUMERIC(5,1), -- Breite in cm
  depth_cm NUMERIC(5,1), -- Tiefe in cm
  height_cm NUMERIC(5,1), -- Höhe in cm
  light_type TEXT,
  light_wattage INTEGER,
  ventilation TEXT,
  irrigation_type TEXT, -- "Hand", "Tropf", "Ebbe-Flut" etc.
  location TEXT,
  shelf_count INTEGER DEFAULT 1, -- Anzahl Etagen
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Grow-Zyklen (Durchgänge)
-- ============================================
CREATE TABLE grows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tent_id UUID REFERENCES grow_tents(id),
  strain_id UUID REFERENCES strains(id),
  status TEXT DEFAULT 'vorbereitung' CHECK (status IN (
    'vorbereitung', 'vegetation', 'blüte', 'ernte', 'curing', 'beendet'
  )),
  plant_count INTEGER,
  light_wattage INTEGER,
  irrigation_type TEXT,
  cutting_date DATE,
  veg_start DATE,
  bloom_start DATE,
  harvest_date DATE,
  jar_date DATE,
  harvest_method TEXT CHECK (harvest_method IS NULL OR harvest_method IN (
    'nassschnitt', 'trimbag', 'handschnitt'
  )),
  dry_yield_g NUMERIC(8,1),
  trim_g NUMERIC(8,1),
  yield_per_watt NUMERIC(6,3),
  sieve_1 NUMERIC(8,1),
  sieve_2 NUMERIC(8,1),
  sieve_3 NUMERIC(8,1),
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Tägliche Logs
-- ============================================
CREATE TABLE daily_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  grow_id UUID NOT NULL REFERENCES grows(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  veg_day INTEGER,
  bloom_day INTEGER,
  bloom_week INTEGER,
  -- Umgebung
  temp_day NUMERIC(4,1),
  temp_night NUMERIC(4,1),
  humidity_day INTEGER,
  humidity_night INTEGER,
  light_wattage NUMERIC(6,1),
  plant_height INTEGER, -- cm
  lamp_height INTEGER, -- cm
  -- Reservoir
  tank_level INTEGER,
  ph NUMERIC(3,1),
  ec NUMERIC(4,2),
  tank_temp NUMERIC(4,1),
  -- Nährstoffe (flexibel als JSONB)
  water_ml INTEGER,
  nutrients JSONB DEFAULT '{}', -- {"canna_a": 10, "canna_b": 10, ...}
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(grow_id, date) -- Ein Log pro Grow pro Tag
);

-- ============================================
-- Einzelpflanzen
-- ============================================
CREATE TABLE plants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  grow_id UUID REFERENCES grows(id),
  strain_id UUID REFERENCES strains(id),
  plant_number INTEGER NOT NULL,
  status TEXT DEFAULT 'keimung' CHECK (status IN (
    'keimung', 'vegetation', 'blüte', 'ernte', 'beendet', 'entsorgt'
  )),
  seed_date DATE,
  germination_date DATE,
  pot_1l_date DATE,
  bloom_start DATE,
  harvest_date DATE,
  height_bloom_start NUMERIC(5,1),
  height_harvest NUMERIC(5,1),
  stem_thickness_bloom NUMERIC(4,1),
  stem_thickness_harvest NUMERIC(4,1),
  wet_weight_g NUMERIC(8,1),
  dry_weight_g NUMERIC(8,1),
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Selektion / Phänotyp-Hunting
-- ============================================
CREATE TABLE selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  strain_id UUID NOT NULL REFERENCES strains(id),
  grow_id UUID REFERENCES grows(id),
  name TEXT NOT NULL, -- z.B. "OG Kush Selektion März 2026"
  status TEXT DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'abgeschlossen')),
  start_date DATE,
  seed_count INTEGER,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE selection_criteria (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  selection_id UUID NOT NULL REFERENCES selections(id) ON DELETE CASCADE,
  criterion_name TEXT NOT NULL, -- z.B. "Vigor", "Harz", "Aroma"
  weight NUMERIC(3,2) DEFAULT 1.0, -- Gewichtung (0.0 - 1.0)
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE selection_plants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  selection_id UUID NOT NULL REFERENCES selections(id) ON DELETE CASCADE,
  plant_id UUID NOT NULL REFERENCES plants(id),
  keeper_status TEXT DEFAULT 'vielleicht' CHECK (keeper_status IN ('ja', 'nein', 'vielleicht')),
  score_vigor INTEGER CHECK (score_vigor BETWEEN 1 AND 10),
  score_structure INTEGER CHECK (score_structure BETWEEN 1 AND 10),
  score_resin INTEGER CHECK (score_resin BETWEEN 1 AND 10),
  score_aroma INTEGER CHECK (score_aroma BETWEEN 1 AND 10),
  score_yield INTEGER CHECK (score_yield BETWEEN 1 AND 10),
  score_pest_resistance INTEGER CHECK (score_pest_resistance BETWEEN 1 AND 10),
  score_overall NUMERIC(4,2), -- Gewichteter Gesamtscore
  trichome_notes JSONB DEFAULT '{}', -- {"bt55": "milchig", "bt60": "bernstein 20%"}
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Wachstumsmessungen
-- ============================================
CREATE TABLE growth_measurements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plant_id UUID NOT NULL REFERENCES plants(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  height_cm NUMERIC(5,1),
  node_count INTEGER,
  stem_thickness NUMERIC(4,1),
  topped BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Mutterpflanzen
-- ============================================
CREATE TABLE mothers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  strain_id UUID NOT NULL REFERENCES strains(id),
  source_plant_id UUID REFERENCES plants(id),
  clone_number INTEGER,
  status TEXT DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'entsorgt')),
  cutting_date DATE,
  pot_1l_date DATE,
  pot_3_5l_date DATE,
  disposal_date DATE,
  disposal_reason TEXT,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Stecklinge
-- ============================================
CREATE TABLE cuttings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mother_id UUID NOT NULL REFERENCES mothers(id),
  date DATE NOT NULL,
  count_lower INTEGER DEFAULT 0,
  count_upper INTEGER DEFAULT 0,
  nutrients JSONB DEFAULT '{}',
  success_rate INTEGER CHECK (success_rate IS NULL OR success_rate BETWEEN 0 AND 100),
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Curing
-- ============================================
CREATE TABLE curing_jars (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  grow_id UUID NOT NULL REFERENCES grows(id),
  strain_id UUID REFERENCES strains(id),
  jar_number INTEGER NOT NULL,
  trim_method TEXT CHECK (trim_method IS NULL OR trim_method IN (
    'nassschnitt', 'trimbag', 'handschnitt'
  )),
  status TEXT DEFAULT 'trocknung' CHECK (status IN ('trocknung', 'curing', 'fertig')),
  mold_detected BOOLEAN DEFAULT FALSE,
  harvest_date DATE,
  jar_date DATE,
  dry_weight_g NUMERIC(8,1),
  target_humidity INTEGER,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE curing_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  jar_id UUID NOT NULL REFERENCES curing_jars(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  humidity_pct INTEGER,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Schädlingsmanagement
-- ============================================
CREATE TABLE pest_incidents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tent_id UUID REFERENCES grow_tents(id),
  grow_id UUID REFERENCES grows(id),
  pest_type TEXT NOT NULL CHECK (pest_type IN (
    'thripse', 'spinnmilben', 'trauermücken', 'sonstige'
  )),
  severity TEXT DEFAULT 'niedrig' CHECK (severity IN (
    'niedrig', 'mittel', 'hoch', 'kritisch'
  )),
  detected_date DATE NOT NULL,
  resolved_date DATE,
  treatment TEXT,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Inventar / Hilfsmittel
-- ============================================
CREATE TABLE inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'dünger', 'schädlingsbekämpfung', 'medium', 'equipment', 'sonstige'
  )),
  unit TEXT DEFAULT 'Stück', -- ml, g, Stück, etc.
  current_stock NUMERIC(10,2) DEFAULT 0,
  min_stock NUMERIC(10,2) DEFAULT 0,
  supplier TEXT,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE inventory_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('eingang', 'verbrauch')),
  quantity NUMERIC(10,2) NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  notes TEXT,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Fotos
-- ============================================
CREATE TABLE photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  caption TEXT,
  plant_id UUID REFERENCES plants(id),
  grow_id UUID REFERENCES grows(id),
  tent_id UUID REFERENCES grow_tents(id),
  taken_at TIMESTAMPTZ,
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Kalender / Aufgaben
-- ============================================
CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT DEFAULT 'allgemein' CHECK (event_type IN (
    'bewässerung', 'düngung', 'ernte', 'stecklinge', 'allgemein'
  )),
  scheduled_at TIMESTAMPTZ NOT NULL,
  recurrence_rule TEXT, -- iCal RRULE Format
  completed BOOLEAN DEFAULT FALSE,
  related_grow_id UUID REFERENCES grows(id),
  related_plant_id UUID REFERENCES plants(id),
  created_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Benachrichtigungen
-- ============================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT DEFAULT 'info',
  read_at TIMESTAMPTZ,
  related_event_id UUID REFERENCES calendar_events(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- RLS aktivieren auf allen Tabellen
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE strains ENABLE ROW LEVEL SECURITY;
ALTER TABLE grow_tents ENABLE ROW LEVEL SECURITY;
ALTER TABLE grows ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE selection_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE selection_plants ENABLE ROW LEVEL SECURITY;
ALTER TABLE growth_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE mothers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cuttings ENABLE ROW LEVEL SECURITY;
ALTER TABLE curing_jars ENABLE ROW LEVEL SECURITY;
ALTER TABLE curing_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Policies: Benutzer sehen und bearbeiten nur eigene Daten

-- Profiles
CREATE POLICY "Eigenes Profil lesen" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Eigenes Profil bearbeiten" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Generische Policy-Funktion für created_by Tabellen
-- Strains
CREATE POLICY "Sorten lesen" ON strains FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Sorten erstellen" ON strains FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Sorten bearbeiten" ON strains FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Sorten löschen" ON strains FOR DELETE USING (auth.uid() = created_by);

-- Grow Tents
CREATE POLICY "Zelte lesen" ON grow_tents FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Zelte erstellen" ON grow_tents FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Zelte bearbeiten" ON grow_tents FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Zelte löschen" ON grow_tents FOR DELETE USING (auth.uid() = created_by);

-- Grows
CREATE POLICY "Grows lesen" ON grows FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Grows erstellen" ON grows FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Grows bearbeiten" ON grows FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Grows löschen" ON grows FOR DELETE USING (auth.uid() = created_by);

-- Daily Logs
CREATE POLICY "Logs lesen" ON daily_logs FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Logs erstellen" ON daily_logs FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Logs bearbeiten" ON daily_logs FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Logs löschen" ON daily_logs FOR DELETE USING (auth.uid() = created_by);

-- Plants
CREATE POLICY "Pflanzen lesen" ON plants FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Pflanzen erstellen" ON plants FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Pflanzen bearbeiten" ON plants FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Pflanzen löschen" ON plants FOR DELETE USING (auth.uid() = created_by);

-- Selections
CREATE POLICY "Selektionen lesen" ON selections FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Selektionen erstellen" ON selections FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Selektionen bearbeiten" ON selections FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Selektionen löschen" ON selections FOR DELETE USING (auth.uid() = created_by);

-- Selection Criteria (über Selection-Owner)
CREATE POLICY "Kriterien lesen" ON selection_criteria FOR SELECT
  USING (EXISTS (SELECT 1 FROM selections WHERE selections.id = selection_criteria.selection_id AND selections.created_by = auth.uid()));
CREATE POLICY "Kriterien erstellen" ON selection_criteria FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM selections WHERE selections.id = selection_criteria.selection_id AND selections.created_by = auth.uid()));
CREATE POLICY "Kriterien bearbeiten" ON selection_criteria FOR UPDATE
  USING (EXISTS (SELECT 1 FROM selections WHERE selections.id = selection_criteria.selection_id AND selections.created_by = auth.uid()));
CREATE POLICY "Kriterien löschen" ON selection_criteria FOR DELETE
  USING (EXISTS (SELECT 1 FROM selections WHERE selections.id = selection_criteria.selection_id AND selections.created_by = auth.uid()));

-- Selection Plants
CREATE POLICY "Sel-Pflanzen lesen" ON selection_plants FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Sel-Pflanzen erstellen" ON selection_plants FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Sel-Pflanzen bearbeiten" ON selection_plants FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Sel-Pflanzen löschen" ON selection_plants FOR DELETE USING (auth.uid() = created_by);

-- Growth Measurements
CREATE POLICY "Messungen lesen" ON growth_measurements FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Messungen erstellen" ON growth_measurements FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Messungen bearbeiten" ON growth_measurements FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Messungen löschen" ON growth_measurements FOR DELETE USING (auth.uid() = created_by);

-- Mothers
CREATE POLICY "Mütter lesen" ON mothers FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Mütter erstellen" ON mothers FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Mütter bearbeiten" ON mothers FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Mütter löschen" ON mothers FOR DELETE USING (auth.uid() = created_by);

-- Cuttings
CREATE POLICY "Stecklinge lesen" ON cuttings FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Stecklinge erstellen" ON cuttings FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Stecklinge bearbeiten" ON cuttings FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Stecklinge löschen" ON cuttings FOR DELETE USING (auth.uid() = created_by);

-- Curing Jars
CREATE POLICY "Gläser lesen" ON curing_jars FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Gläser erstellen" ON curing_jars FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Gläser bearbeiten" ON curing_jars FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Gläser löschen" ON curing_jars FOR DELETE USING (auth.uid() = created_by);

-- Curing Readings (über Jar-Owner)
CREATE POLICY "Messwerte lesen" ON curing_readings FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Messwerte erstellen" ON curing_readings FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Messwerte bearbeiten" ON curing_readings FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Messwerte löschen" ON curing_readings FOR DELETE USING (auth.uid() = created_by);

-- Pest Incidents
CREATE POLICY "Schädlinge lesen" ON pest_incidents FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Schädlinge erstellen" ON pest_incidents FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Schädlinge bearbeiten" ON pest_incidents FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Schädlinge löschen" ON pest_incidents FOR DELETE USING (auth.uid() = created_by);

-- Inventory Items
CREATE POLICY "Inventar lesen" ON inventory_items FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Inventar erstellen" ON inventory_items FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Inventar bearbeiten" ON inventory_items FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Inventar löschen" ON inventory_items FOR DELETE USING (auth.uid() = created_by);

-- Inventory Transactions
CREATE POLICY "Transaktionen lesen" ON inventory_transactions FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Transaktionen erstellen" ON inventory_transactions FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Photos
CREATE POLICY "Fotos lesen" ON photos FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Fotos erstellen" ON photos FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Fotos löschen" ON photos FOR DELETE USING (auth.uid() = created_by);

-- Calendar Events
CREATE POLICY "Termine lesen" ON calendar_events FOR SELECT USING (auth.uid() = created_by);
CREATE POLICY "Termine erstellen" ON calendar_events FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Termine bearbeiten" ON calendar_events FOR UPDATE USING (auth.uid() = created_by);
CREATE POLICY "Termine löschen" ON calendar_events FOR DELETE USING (auth.uid() = created_by);

-- Notifications
CREATE POLICY "Benachrichtigungen lesen" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Benachrichtigungen bearbeiten" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- Indizes für Performance
-- ============================================
CREATE INDEX idx_strains_created_by ON strains(created_by);
CREATE INDEX idx_strains_status ON strains(status);
CREATE INDEX idx_grow_tents_created_by ON grow_tents(created_by);
CREATE INDEX idx_grows_created_by ON grows(created_by);
CREATE INDEX idx_grows_tent_id ON grows(tent_id);
CREATE INDEX idx_grows_strain_id ON grows(strain_id);
CREATE INDEX idx_grows_status ON grows(status);
CREATE INDEX idx_daily_logs_grow_id ON daily_logs(grow_id);
CREATE INDEX idx_daily_logs_date ON daily_logs(date);
CREATE INDEX idx_plants_grow_id ON plants(grow_id);
CREATE INDEX idx_plants_strain_id ON plants(strain_id);
CREATE INDEX idx_selections_strain_id ON selections(strain_id);
CREATE INDEX idx_selection_plants_selection_id ON selection_plants(selection_id);
CREATE INDEX idx_selection_plants_plant_id ON selection_plants(plant_id);
CREATE INDEX idx_growth_measurements_plant_id ON growth_measurements(plant_id);
CREATE INDEX idx_mothers_strain_id ON mothers(strain_id);
CREATE INDEX idx_cuttings_mother_id ON cuttings(mother_id);
CREATE INDEX idx_curing_jars_grow_id ON curing_jars(grow_id);
CREATE INDEX idx_curing_readings_jar_id ON curing_readings(jar_id);
CREATE INDEX idx_photos_plant_id ON photos(plant_id);
CREATE INDEX idx_photos_grow_id ON photos(grow_id);
CREATE INDEX idx_calendar_events_scheduled_at ON calendar_events(scheduled_at);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);

-- ============================================
-- Updated_at Trigger
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_strains_updated_at BEFORE UPDATE ON strains FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_grow_tents_updated_at BEFORE UPDATE ON grow_tents FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_grows_updated_at BEFORE UPDATE ON grows FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_plants_updated_at BEFORE UPDATE ON plants FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_selections_updated_at BEFORE UPDATE ON selections FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_selection_plants_updated_at BEFORE UPDATE ON selection_plants FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_mothers_updated_at BEFORE UPDATE ON mothers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_curing_jars_updated_at BEFORE UPDATE ON curing_jars FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_pest_incidents_updated_at BEFORE UPDATE ON pest_incidents FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_calendar_events_updated_at BEFORE UPDATE ON calendar_events FOR EACH ROW EXECUTE FUNCTION update_updated_at();
