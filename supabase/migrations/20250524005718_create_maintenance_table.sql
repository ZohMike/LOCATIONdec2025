-- Create the maintenance table
CREATE TABLE IF NOT EXISTS public.maintenance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    equipement_id UUID NOT NULL REFERENCES public.materiels(id) ON DELETE CASCADE,
    date_maintenance DATE NOT NULL,
    type_intervention TEXT NOT NULL DEFAULT 'reparation',
    description TEXT NOT NULL,
    cout DECIMAL(10, 2) NOT NULL,
    prestataire TEXT,
    statut TEXT NOT NULL DEFAULT 'en_attente',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Add RLS policies
ALTER TABLE public.maintenance ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users
CREATE POLICY "Allow authenticated users full access to maintenance" ON public.maintenance
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_maintenance_updated_at
BEFORE UPDATE ON public.maintenance
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
