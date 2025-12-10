-- ================================
-- SYSTÈME SAAS MULTI-TENANT
-- ================================

-- Table des plans d'abonnement
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10, 2) NOT NULL,
    price_yearly DECIMAL(10, 2),
    max_users INTEGER NOT NULL DEFAULT 1,
    max_equipment INTEGER NOT NULL DEFAULT 10,
    max_clients INTEGER NOT NULL DEFAULT 50,
    max_reservations_per_month INTEGER NOT NULL DEFAULT 100,
    features JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Table des organisations (tenants)
CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    address TEXT,
    website TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Table des abonnements
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
    status TEXT NOT NULL DEFAULT 'trial' CHECK (status IN ('trial', 'active', 'past_due', 'canceled', 'paused')),
    billing_cycle TEXT NOT NULL DEFAULT 'monthly' CHECK (billing_cycle IN ('monthly', 'yearly')),
    start_date DATE NOT NULL,
    end_date DATE,
    trial_end_date DATE,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'XOF',
    stripe_subscription_id TEXT,
    stripe_customer_id TEXT,
    next_billing_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Table des paiements
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subscription_id UUID NOT NULL REFERENCES public.subscriptions(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'XOF',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'succeeded', 'failed', 'refunded')),
    payment_method TEXT,
    stripe_payment_intent_id TEXT,
    failure_reason TEXT,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Table des invitations d'utilisateurs
CREATE TABLE IF NOT EXISTS public.user_invitations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'agent',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'expired')),
    invited_by UUID REFERENCES auth.users(id),
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    accepted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Modifier la table profiles pour ajouter organization_id
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_organization_owner BOOLEAN DEFAULT false;

-- Modifier les tables existantes pour ajouter organization_id
ALTER TABLE public.materiels ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id);
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id);
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id);
ALTER TABLE public.paiements ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id);
ALTER TABLE public.entretiens ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id);

-- Table des limitations d'usage
CREATE TABLE IF NOT EXISTS public.usage_limits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    month_year TEXT NOT NULL, -- Format: YYYY-MM
    users_count INTEGER DEFAULT 0,
    equipment_count INTEGER DEFAULT 0,
    clients_count INTEGER DEFAULT 0,
    reservations_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(organization_id, month_year)
);

-- Table des fonctionnalités activées par organisation
CREATE TABLE IF NOT EXISTS public.organization_features (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    feature_name TEXT NOT NULL,
    is_enabled BOOLEAN DEFAULT true,
    config JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(organization_id, feature_name)
);

-- Insérer les plans de base
INSERT INTO public.subscription_plans (name, description, price_monthly, price_yearly, max_users, max_equipment, max_clients, max_reservations_per_month, features) VALUES
('Essai Gratuit', 'Plan d''essai pour découvrir PhotoFlow', 0, 0, 1, 5, 10, 20, '{"support": "email", "storage": "1GB"}'),
('Starter', 'Parfait pour les petites entreprises', 15000, 150000, 3, 25, 100, 200, '{"support": "email", "storage": "5GB", "custom_branding": false}'),
('Professional', 'Idéal pour les entreprises en croissance', 35000, 350000, 10, 100, 500, 1000, '{"support": "priority", "storage": "20GB", "custom_branding": true, "advanced_reporting": true}'),
('Enterprise', 'Solution complète pour les grandes entreprises', 75000, 750000, 99999, 99999, 99999, 99999, '{"support": "phone", "storage": "unlimited", "custom_branding": true, "advanced_reporting": true, "api_access": true, "white_label": true}');

-- Politiques RLS
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_features ENABLE ROW LEVEL SECURITY;

-- Politiques pour subscription_plans (lecture pour tous les utilisateurs authentifiés)
CREATE POLICY "Allow authenticated users to read subscription plans" ON public.subscription_plans
    FOR SELECT USING (auth.role() = 'authenticated');

-- Politiques pour organizations
CREATE POLICY "Users can read their organization" ON public.organizations
    FOR SELECT USING (
        id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

CREATE POLICY "Organization owners can update their organization" ON public.organizations
    FOR UPDATE USING (
        id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid() AND is_organization_owner = true
        )
    );

-- Politiques pour subscriptions
CREATE POLICY "Users can read their organization subscription" ON public.subscriptions
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Politiques pour user_invitations
CREATE POLICY "Users can read invitations for their organization" ON public.user_invitations
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Politiques pour usage_limits
CREATE POLICY "Users can read their organization usage" ON public.usage_limits
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Politiques pour organization_features
CREATE POLICY "Users can read their organization features" ON public.organization_features
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Mise à jour des politiques existantes pour inclure organization_id

-- Politiques pour materiels
DROP POLICY IF EXISTS "Users can only see their own equipment" ON public.materiels;
CREATE POLICY "Users can only see their organization equipment" ON public.materiels
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Politiques pour clients
DROP POLICY IF EXISTS "Users can only see their own clients" ON public.clients;
CREATE POLICY "Users can only see their organization clients" ON public.clients
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Politiques pour reservations
DROP POLICY IF EXISTS "Users can only see their own reservations" ON public.reservations;
CREATE POLICY "Users can only see their organization reservations" ON public.reservations
    FOR SELECT USING (
        organization_id IN (
            SELECT organization_id FROM public.profiles 
            WHERE id = auth.uid()
        )
    );

-- Triggers pour updated_at
CREATE TRIGGER update_subscription_plans_updated_at
BEFORE UPDATE ON public.subscription_plans
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_organizations_updated_at
BEFORE UPDATE ON public.organizations
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_subscriptions_updated_at
BEFORE UPDATE ON public.subscriptions
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_usage_limits_updated_at
BEFORE UPDATE ON public.usage_limits
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- Fonctions utilitaires

-- Fonction pour vérifier les limites d'usage
CREATE OR REPLACE FUNCTION check_usage_limit(
    org_id UUID,
    limit_type TEXT,
    current_count INTEGER
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    plan_limit INTEGER;
    org_plan_id UUID;
BEGIN
    -- Récupérer le plan de l'organisation
    SELECT s.plan_id INTO org_plan_id
    FROM subscriptions s
    WHERE s.organization_id = org_id 
    AND s.status = 'active'
    ORDER BY s.created_at DESC
    LIMIT 1;
    
    IF org_plan_id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Récupérer la limite selon le type
    CASE limit_type
        WHEN 'users' THEN
            SELECT max_users INTO plan_limit FROM subscription_plans WHERE id = org_plan_id;
        WHEN 'equipment' THEN
            SELECT max_equipment INTO plan_limit FROM subscription_plans WHERE id = org_plan_id;
        WHEN 'clients' THEN
            SELECT max_clients INTO plan_limit FROM subscription_plans WHERE id = org_plan_id;
        WHEN 'reservations' THEN
            SELECT max_reservations_per_month INTO plan_limit FROM subscription_plans WHERE id = org_plan_id;
        ELSE
            RETURN false;
    END CASE;
    
    RETURN current_count < plan_limit;
END;
$$;

-- Fonction pour créer une organisation avec un abonnement d'essai
CREATE OR REPLACE FUNCTION create_organization_with_trial(
    org_name TEXT,
    org_slug TEXT,
    user_id UUID
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_org_id UUID;
    trial_plan_id UUID;
    trial_end DATE;
BEGIN
    -- Créer l'organisation
    INSERT INTO public.organizations (name, slug)
    VALUES (org_name, org_slug)
    RETURNING id INTO new_org_id;
    
    -- Récupérer le plan d'essai
    SELECT id INTO trial_plan_id 
    FROM public.subscription_plans 
    WHERE name = 'Essai Gratuit'
    LIMIT 1;
    
    -- Définir la fin de l'essai (30 jours)
    trial_end := CURRENT_DATE + INTERVAL '30 days';
    
    -- Créer l'abonnement d'essai
    INSERT INTO public.subscriptions (
        organization_id, 
        plan_id, 
        status, 
        start_date, 
        trial_end_date, 
        amount
    ) VALUES (
        new_org_id, 
        trial_plan_id, 
        'trial', 
        CURRENT_DATE, 
        trial_end, 
        0
    );
    
    -- Mettre à jour le profil utilisateur
    UPDATE public.profiles 
    SET organization_id = new_org_id, is_organization_owner = true
    WHERE id = user_id;
    
    RETURN new_org_id;
END;
$$; 