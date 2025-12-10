-- Migration pour créer la table allocation_rules
-- Cette table stocke les règles d'allocation des revenus mensuels

CREATE TABLE allocation_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    description TEXT,
    percentage DECIMAL(5,2) DEFAULT 0,
    type VARCHAR CHECK (type IN ('percentage', 'fixed')) NOT NULL DEFAULT 'percentage',
    fixed_amount DECIMAL(12,2) DEFAULT 0,
    category VARCHAR CHECK (category IN ('loan', 'investment', 'operating', 'reserve', 'other')) NOT NULL DEFAULT 'other',
    period VARCHAR CHECK (period IN ('monthly', 'quarterly', 'semestrial', 'annual')) NOT NULL DEFAULT 'monthly',
    start_month INTEGER CHECK (start_month >= 1 AND start_month <= 12) NOT NULL DEFAULT EXTRACT(MONTH FROM now()),
    start_year INTEGER CHECK (start_year >= 2020 AND start_year <= 2030) NOT NULL DEFAULT EXTRACT(YEAR FROM now()),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Index pour améliorer les performances
CREATE INDEX idx_allocation_rules_org_id ON allocation_rules(organization_id);
CREATE INDEX idx_allocation_rules_active ON allocation_rules(active);
CREATE INDEX idx_allocation_rules_category ON allocation_rules(category);

-- RLS (Row Level Security)
ALTER TABLE allocation_rules ENABLE ROW LEVEL SECURITY;

-- Politique de sécurité : les utilisateurs ne peuvent voir que leurs propres règles
CREATE POLICY "Users can view their own allocation rules" ON allocation_rules
    FOR SELECT USING (organization_id = auth.uid());

CREATE POLICY "Users can insert their own allocation rules" ON allocation_rules
    FOR INSERT WITH CHECK (organization_id = auth.uid());

CREATE POLICY "Users can update their own allocation rules" ON allocation_rules
    FOR UPDATE USING (organization_id = auth.uid());

CREATE POLICY "Users can delete their own allocation rules" ON allocation_rules
    FOR DELETE USING (organization_id = auth.uid());

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_allocation_rules_updated_at 
    BEFORE UPDATE ON allocation_rules 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Commentaires pour la documentation
COMMENT ON TABLE allocation_rules IS 'Règles d''allocation des revenus mensuels';
COMMENT ON COLUMN allocation_rules.name IS 'Nom de la règle d''allocation';
COMMENT ON COLUMN allocation_rules.description IS 'Description de la règle';
COMMENT ON COLUMN allocation_rules.percentage IS 'Pourcentage d''allocation (0-100)';
COMMENT ON COLUMN allocation_rules.type IS 'Type d''allocation: percentage ou fixed';
COMMENT ON COLUMN allocation_rules.fixed_amount IS 'Montant fixe en FCFA si type=fixed';
COMMENT ON COLUMN allocation_rules.category IS 'Catégorie: loan, investment, operating, reserve, other';
COMMENT ON COLUMN allocation_rules.period IS 'Période d''application: monthly, quarterly, semestrial, annual';
COMMENT ON COLUMN allocation_rules.start_month IS 'Mois de début d''application (1-12)';
COMMENT ON COLUMN allocation_rules.start_year IS 'Année de début d''application';
COMMENT ON COLUMN allocation_rules.active IS 'Règle active ou non'; 