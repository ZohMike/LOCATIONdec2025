-- Script pour créer le bucket client_docs et ses permissions
-- À exécuter dans l'éditeur SQL de votre dashboard Supabase

-- 1. Créer le bucket client_docs s'il n'existe pas déjà
INSERT INTO storage.buckets (id, name, public)
SELECT 'client_docs', 'Client Documents', true
WHERE NOT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'client_docs'
);

-- 2. Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Public Upload Access" ON storage.objects;
DROP POLICY IF EXISTS "Public Read Access" ON storage.objects;

-- 3. Créer les politiques RLS pour permettre l'upload et la lecture
CREATE POLICY "Public Upload Access"
  ON storage.objects
  FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'client_docs');

CREATE POLICY "Public Read Access"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'client_docs');

-- 4. Vérifier que le bucket a été créé
SELECT 
    id, 
    name, 
    public,
    created_at
FROM storage.buckets 
WHERE id = 'client_docs'; 