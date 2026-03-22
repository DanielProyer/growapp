-- Storage Bucket für Fotos erstellen
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('fotos', 'fotos', false, 52428800, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO NOTHING;

-- Lesen: Nur eigene Dateien
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'fotos_select_own' AND tablename = 'objects') THEN
    CREATE POLICY "fotos_select_own"
      ON storage.objects FOR SELECT
      TO authenticated
      USING (
        bucket_id = 'fotos'
        AND (storage.foldername(name))[1] = auth.uid()::text
      );
  END IF;
END $$;

-- Hochladen: Nur in eigenen Ordner
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'fotos_insert_own' AND tablename = 'objects') THEN
    CREATE POLICY "fotos_insert_own"
      ON storage.objects FOR INSERT
      TO authenticated
      WITH CHECK (
        bucket_id = 'fotos'
        AND (storage.foldername(name))[1] = auth.uid()::text
      );
  END IF;
END $$;

-- Löschen: Nur eigene Dateien
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'fotos_delete_own' AND tablename = 'objects') THEN
    CREATE POLICY "fotos_delete_own"
      ON storage.objects FOR DELETE
      TO authenticated
      USING (
        bucket_id = 'fotos'
        AND (storage.foldername(name))[1] = auth.uid()::text
      );
  END IF;
END $$;
