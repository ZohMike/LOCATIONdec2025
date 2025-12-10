-- Create a storage bucket for client documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('client_docs', 'Client Documents', true);

-- Set up RLS policy to allow anyone to upload to this bucket
CREATE POLICY "Public Upload Access"
  ON storage.objects
  FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'client_docs');

-- Allow anyone to read from this bucket
CREATE POLICY "Public Read Access"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'client_docs');
