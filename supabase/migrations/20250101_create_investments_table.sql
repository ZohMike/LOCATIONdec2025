-- Migration pour créer la table des investissements
-- Date: 2025-01-01

-- Créer la table des investissements
CREATE TABLE IF NOT EXISTS public.investments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    montant_initial DECIMAL(15,2) NOT NULL,
    montant_actuel DECIMAL(15,2),
    categorie VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('materiel', 'logiciel', 'formation', 'infrastructure', 'marketing', 'autre')),
    date_achat DATE NOT NULL,
    duree_amortissement INTEGER, -- en mois
    fournisseur VARCHAR(255),
    numero_facture VARCHAR(100),
    statut VARCHAR(50) NOT NULL DEFAULT 'actif' CHECK (statut IN ('actif', 'amorti', 'vendu', 'obsolete')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Créer un index sur la date d'achat pour les requêtes de tri
CREATE INDEX IF NOT EXISTS idx_investments_date_achat ON public.investments(date_achat DESC);

-- Créer un index sur le statut pour les filtres
CREATE INDEX IF NOT EXISTS idx_investments_statut ON public.investments(statut);

-- Créer un index sur la catégorie pour les filtres
CREATE INDEX IF NOT EXISTS idx_investments_categorie ON public.investments(categorie);

-- Créer un index sur le type pour les filtres
CREATE INDEX IF NOT EXISTS idx_investments_type ON public.investments(type);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour mettre à jour automatiquement updated_at
CREATE TRIGGER update_investments_updated_at 
    BEFORE UPDATE ON public.investments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Activer RLS (Row Level Security)
ALTER TABLE public.investments ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre toutes les opérations aux utilisateurs authentifiés
CREATE POLICY "Enable all operations for authenticated users" ON public.investments
    FOR ALL USING (auth.role() = 'authenticated');

-- Commentaires pour documenter la table
COMMENT ON TABLE public.investments IS 'Table pour stocker les investissements de l''entreprise';
COMMENT ON COLUMN public.investments.nom IS 'Nom de l''investissement';
COMMENT ON COLUMN public.investments.description IS 'Description détaillée de l''investissement';
COMMENT ON COLUMN public.investments.montant_initial IS 'Montant initial de l''investissement en FCFA';
COMMENT ON COLUMN public.investments.montant_actuel IS 'Valeur actuelle de l''investissement en FCFA';
COMMENT ON COLUMN public.investments.categorie IS 'Catégorie de l''investissement (equipement_photo, informatique, etc.)';
COMMENT ON COLUMN public.investments.type IS 'Type d''investissement (materiel, logiciel, formation, etc.)';
COMMENT ON COLUMN public.investments.date_achat IS 'Date d''achat de l''investissement';
COMMENT ON COLUMN public.investments.duree_amortissement IS 'Durée d''amortissement en mois';
COMMENT ON COLUMN public.investments.fournisseur IS 'Nom du fournisseur';
COMMENT ON COLUMN public.investments.numero_facture IS 'Numéro de facture d''achat';
COMMENT ON COLUMN public.investments.statut IS 'Statut actuel de l''investissement';
COMMENT ON COLUMN public.investments.notes IS 'Notes additionnelles sur l''investissement'; 
