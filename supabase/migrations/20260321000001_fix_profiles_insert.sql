-- Fix: INSERT Policy für profiles hinzufügen
-- Der Trigger handle_new_user braucht diese Policy nicht (SECURITY DEFINER),
-- aber für direkte Inserts aus der App heraus wird sie benötigt.
CREATE POLICY "Eigenes Profil erstellen" ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Sicherstellen, dass der Trigger korrekt funktioniert
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
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
