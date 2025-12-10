-- ================================
-- MODULE VENTE PHOTOFLOW
-- Migration pour ajouter la fonctionnalité vente
-- Date: 2025-01-15
-- ================================

-- ================================
-- 1. TABLE DES PRODUITS À VENDRE
-- ================================
CREATE TABLE IF NOT EXISTS public.produits_vente (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    marque VARCHAR(100),
    type VARCHAR(100),
    prix_vente DECIMAL(10, 2) NOT NULL,
    prix_achat DECIMAL(10, 2),
    stock_actuel INTEGER NOT NULL DEFAULT 0,
    stock_minimum INTEGER NOT NULL DEFAULT 0,
    stock_maximum INTEGER,
    sku VARCHAR(50) UNIQUE,
    code_barre VARCHAR(100),
    image_url TEXT,
    images JSONB DEFAULT '[]',
    specifications JSONB DEFAULT '{}',
    garantie_mois INTEGER,
    poids DECIMAL(8, 2),
    dimensions_cm VARCHAR(50),
    couleur VARCHAR(50),
    statut VARCHAR(20) NOT NULL DEFAULT 'actif' CHECK (statut IN ('actif', 'inactif', 'rupture', 'discontinue')),
    meta_title VARCHAR(255),
    meta_description TEXT,
    tags JSONB DEFAULT '[]',
    promotion_actuelle DECIMAL(5, 2) DEFAULT 0, -- pourcentage de réduction
    date_promotion_debut DATE,
    date_promotion_fin DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    organization_id UUID REFERENCES public.organizations(id)
);

-- ================================
-- 2. TABLE DES COMMANDES DE VENTE
-- ================================
CREATE TABLE IF NOT EXISTS public.commandes_vente (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    numero_commande VARCHAR(50) UNIQUE NOT NULL,
    client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
    -- Informations client public (si pas de compte client)
    client_public_nom VARCHAR(255),
    client_public_email VARCHAR(255),
    client_public_telephone VARCHAR(20),
    client_public_adresse TEXT,
    -- Totaux de la commande
    sous_total DECIMAL(10, 2) NOT NULL,
    remise DECIMAL(10, 2) DEFAULT 0,
    frais_livraison DECIMAL(10, 2) DEFAULT 0,
    taxes DECIMAL(10, 2) DEFAULT 0,
    total_final DECIMAL(10, 2) NOT NULL,
    -- Statuts et dates
    statut_commande VARCHAR(20) NOT NULL DEFAULT 'en_attente' 
        CHECK (statut_commande IN ('en_attente', 'confirmee', 'preparee', 'expediee', 'livree', 'annulee', 'retournee')),
    statut_paiement VARCHAR(20) NOT NULL DEFAULT 'en_attente' 
        CHECK (statut_paiement IN ('en_attente', 'paye', 'partiellement_paye', 'rembourse', 'echec')),
    date_commande TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    date_confirmation TIMESTAMP WITH TIME ZONE,
    date_expedition TIMESTAMP WITH TIME ZONE,
    date_livraison TIMESTAMP WITH TIME ZONE,
    -- Livraison
    type_livraison VARCHAR(20) DEFAULT 'retrait' CHECK (type_livraison IN ('retrait', 'livraison', 'expedition')),
    adresse_livraison TEXT,
    transporteur VARCHAR(100),
    numero_suivi VARCHAR(100),
    -- Autres informations
    source VARCHAR(50) DEFAULT 'boutique', -- boutique, website, phone, etc.
    notes_internes TEXT,
    notes_client TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    organization_id UUID REFERENCES public.organizations(id)
);

-- ================================
-- 3. ARTICLES DE COMMANDE
-- ================================
CREATE TABLE IF NOT EXISTS public.commande_articles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    commande_id UUID NOT NULL REFERENCES public.commandes_vente(id) ON DELETE CASCADE,
    produit_id UUID NOT NULL REFERENCES public.produits_vente(id) ON DELETE RESTRICT,
    quantite INTEGER NOT NULL CHECK (quantite > 0),
    prix_unitaire DECIMAL(10, 2) NOT NULL,
    prix_unitaire_original DECIMAL(10, 2), -- prix avant réduction
    remise_article DECIMAL(10, 2) DEFAULT 0,
    total_ligne DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ================================
-- 4. MOUVEMENTS DE STOCK
-- ================================
CREATE TABLE IF NOT EXISTS public.mouvements_stock (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    produit_id UUID NOT NULL REFERENCES public.produits_vente(id) ON DELETE CASCADE,
    type_mouvement VARCHAR(20) NOT NULL CHECK (type_mouvement IN ('entree', 'sortie', 'ajustement', 'transfert')),
    quantite INTEGER NOT NULL,
    stock_avant INTEGER NOT NULL,
    stock_apres INTEGER NOT NULL,
    motif VARCHAR(100),
    reference_externe VARCHAR(100), -- commande_id, facture fournisseur, etc.
    utilisateur_id UUID REFERENCES auth.users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    organization_id UUID REFERENCES public.organizations(id)
);

-- ================================
-- 5. PAIEMENTS DE COMMANDES
-- ================================
CREATE TABLE IF NOT EXISTS public.paiements_commande (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    commande_id UUID NOT NULL REFERENCES public.commandes_vente(id) ON DELETE CASCADE,
    montant DECIMAL(10, 2) NOT NULL,
    mode_paiement VARCHAR(20) NOT NULL CHECK (mode_paiement IN ('especes', 'carte', 'virement', 'cheque', 'mobile_money')),
    statut VARCHAR(20) NOT NULL DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'confirme', 'echec', 'rembourse')),
    numero_transaction VARCHAR(100),
    date_paiement TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    organization_id UUID REFERENCES public.organizations(id)
);

-- ================================
-- 6. HISTORIQUE DES PRIX
-- ================================
CREATE TABLE IF NOT EXISTS public.historique_prix (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    produit_id UUID NOT NULL REFERENCES public.produits_vente(id) ON DELETE CASCADE,
    ancien_prix DECIMAL(10, 2) NOT NULL,
    nouveau_prix DECIMAL(10, 2) NOT NULL,
    date_changement TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    motif VARCHAR(255),
    utilisateur_id UUID REFERENCES auth.users(id),
    organization_id UUID REFERENCES public.organizations(id)
);

-- ================================
-- 7. CATÉGORIES DE PRODUITS
-- ================================
CREATE TABLE IF NOT EXISTS public.categories_produit (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.categories_produit(id) ON DELETE SET NULL,
    image_url TEXT,
    actif BOOLEAN DEFAULT true,
    ordre_affichage INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    organization_id UUID REFERENCES public.organizations(id)
);

-- Relation produits-catégories (many-to-many)
CREATE TABLE IF NOT EXISTS public.produit_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    produit_id UUID NOT NULL REFERENCES public.produits_vente(id) ON DELETE CASCADE,
    categorie_id UUID NOT NULL REFERENCES public.categories_produit(id) ON DELETE CASCADE,
    UNIQUE(produit_id, categorie_id)
);

-- ================================
-- INDEXES POUR PERFORMANCES
-- ================================
CREATE INDEX IF NOT EXISTS idx_produits_vente_statut ON public.produits_vente(statut);
CREATE INDEX IF NOT EXISTS idx_produits_vente_type ON public.produits_vente(type);
CREATE INDEX IF NOT EXISTS idx_produits_vente_stock ON public.produits_vente(stock_actuel);
CREATE INDEX IF NOT EXISTS idx_produits_vente_prix ON public.produits_vente(prix_vente);
CREATE INDEX IF NOT EXISTS idx_produits_vente_promotion ON public.produits_vente(promotion_actuelle, date_promotion_debut, date_promotion_fin);

CREATE INDEX IF NOT EXISTS idx_commandes_vente_numero ON public.commandes_vente(numero_commande);
CREATE INDEX IF NOT EXISTS idx_commandes_vente_client ON public.commandes_vente(client_id);
CREATE INDEX IF NOT EXISTS idx_commandes_vente_statut ON public.commandes_vente(statut_commande);
CREATE INDEX IF NOT EXISTS idx_commandes_vente_date ON public.commandes_vente(date_commande);

CREATE INDEX IF NOT EXISTS idx_commande_articles_commande ON public.commande_articles(commande_id);
CREATE INDEX IF NOT EXISTS idx_commande_articles_produit ON public.commande_articles(produit_id);

CREATE INDEX IF NOT EXISTS idx_mouvements_stock_produit ON public.mouvements_stock(produit_id);
CREATE INDEX IF NOT EXISTS idx_mouvements_stock_date ON public.mouvements_stock(created_at);
CREATE INDEX IF NOT EXISTS idx_mouvements_stock_type ON public.mouvements_stock(type_mouvement);

CREATE INDEX IF NOT EXISTS idx_paiements_commande_commande ON public.paiements_commande(commande_id);
CREATE INDEX IF NOT EXISTS idx_paiements_commande_statut ON public.paiements_commande(statut);

CREATE INDEX IF NOT EXISTS idx_categories_produit_parent ON public.categories_produit(parent_id);

-- ================================
-- TRIGGERS POUR MISE À JOUR AUTO
-- ================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_produits_vente_updated_at 
    BEFORE UPDATE ON public.produits_vente 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_commandes_vente_updated_at 
    BEFORE UPDATE ON public.commandes_vente 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ================================
-- FONCTIONS AUTOMATIQUES
-- ================================

-- Fonction pour générer automatiquement le numéro de commande
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.numero_commande IS NULL THEN
        NEW.numero_commande = 'CMD-' || to_char(NOW(), 'YYYY') || '-' || 
                              LPAD(EXTRACT(DOY FROM NOW())::text, 3, '0') || '-' ||
                              LPAD(nextval('order_sequence')::text, 4, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer la séquence pour les numéros de commande
CREATE SEQUENCE IF NOT EXISTS order_sequence START 1;

-- Trigger pour générer le numéro de commande
CREATE TRIGGER generate_order_number_trigger
    BEFORE INSERT ON public.commandes_vente
    FOR EACH ROW
    EXECUTE FUNCTION generate_order_number();

-- Fonction pour mettre à jour le stock automatiquement
CREATE OR REPLACE FUNCTION update_stock_after_order()
RETURNS TRIGGER AS $$
BEGIN
    -- Lors d'un ajout d'article (nouvelle commande)
    IF TG_OP = 'INSERT' THEN
        -- Vérifier si on a assez de stock
        IF (SELECT stock_actuel FROM produits_vente WHERE id = NEW.produit_id) < NEW.quantite THEN
            RAISE EXCEPTION 'Stock insuffisant pour le produit %', NEW.produit_id;
        END IF;
        
        -- Réserver le stock (décrémenter)
        UPDATE produits_vente 
        SET stock_actuel = stock_actuel - NEW.quantite 
        WHERE id = NEW.produit_id;
        
        -- Enregistrer le mouvement de stock
        INSERT INTO mouvements_stock (produit_id, type_mouvement, quantite, stock_avant, stock_apres, motif, reference_externe)
        SELECT 
            NEW.produit_id,
            'sortie',
            NEW.quantite,
            stock_actuel + NEW.quantite,
            stock_actuel,
            'Vente - Commande',
            NEW.commande_id::text
        FROM produits_vente WHERE id = NEW.produit_id;
        
        RETURN NEW;
    END IF;
    
    -- Lors d'une suppression d'article (annulation)
    IF TG_OP = 'DELETE' THEN
        -- Remettre le stock
        UPDATE produits_vente 
        SET stock_actuel = stock_actuel + OLD.quantite 
        WHERE id = OLD.produit_id;
        
        -- Enregistrer le mouvement de stock
        INSERT INTO mouvements_stock (produit_id, type_mouvement, quantite, stock_avant, stock_apres, motif, reference_externe)
        SELECT 
            OLD.produit_id,
            'entree',
            OLD.quantite,
            stock_actuel - OLD.quantite,
            stock_actuel,
            'Annulation vente',
            OLD.commande_id::text
        FROM produits_vente WHERE id = OLD.produit_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour la gestion automatique du stock
CREATE TRIGGER manage_stock_trigger
    AFTER INSERT OR DELETE ON public.commande_articles
    FOR EACH ROW
    EXECUTE FUNCTION update_stock_after_order();

-- ================================
-- POLITIQUES RLS (ROW LEVEL SECURITY)
-- ================================
ALTER TABLE public.produits_vente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commandes_vente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commande_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mouvements_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.paiements_commande ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historique_prix ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories_produit ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produit_categories ENABLE ROW LEVEL SECURITY;

-- Politiques d'accès pour les utilisateurs authentifiés
CREATE POLICY "Allow authenticated users full access to produits_vente" ON public.produits_vente
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to commandes_vente" ON public.commandes_vente
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to commande_articles" ON public.commande_articles
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to mouvements_stock" ON public.mouvements_stock
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to paiements_commande" ON public.paiements_commande
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to historique_prix" ON public.historique_prix
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to categories_produit" ON public.categories_produit
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users full access to produit_categories" ON public.produit_categories
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Politiques pour l'accès public aux produits (lecture seule)
CREATE POLICY "Allow public read access to active produits_vente" ON public.produits_vente
    FOR SELECT
    USING (statut = 'actif');

CREATE POLICY "Allow public read access to categories_produit" ON public.categories_produit
    FOR SELECT
    USING (actif = true);

-- ================================
-- DONNÉES D'EXEMPLE POUR TESTS
-- ================================

-- Catégories par défaut
INSERT INTO public.categories_produit (nom, description, ordre_affichage) VALUES
('Appareils Photo', 'Appareils photo reflex, mirrorless et compacts', 1),
('Objectifs', 'Objectifs pour tous types d''appareils', 2),
('Éclairage', 'Flashs, softbox, réflecteurs', 3),
('Stabilisation', 'Trépieds, steadicam, gimbal', 4),
('Stockage', 'Cartes mémoire, disques durs', 5),
('Accessoires', 'Batteries, chargeurs, filtres', 6),
('Occasion', 'Matériel d''occasion en parfait état', 7);

-- Produits d'exemple
INSERT INTO public.produits_vente (nom, description, marque, type, prix_vente, prix_achat, stock_actuel, stock_minimum, sku) VALUES
('Carte SD 64GB UHS-I', 'Carte mémoire haute vitesse pour appareils photo', 'SanDisk', 'Stockage', 25000, 18000, 50, 10, 'SD-64GB-001'),
('Batterie Canon LP-E6N', 'Batterie rechargeable pour Canon 5D/6D/7D', 'Canon', 'Accessoire', 35000, 25000, 25, 5, 'BAT-LPE6N-001'),
('Filtre UV 77mm', 'Filtre de protection UV diamètre 77mm', 'Hoya', 'Accessoire', 15000, 10000, 30, 5, 'FIL-UV77-001'),
('Sac de transport', 'Sac professionnel pour matériel photo', 'Lowepro', 'Accessoire', 45000, 30000, 15, 3, 'SAC-TRANS-001'),
('Trépied portable', 'Trépied léger en carbone', 'Manfrotto', 'Stabilisation', 85000, 60000, 8, 2, 'TRIP-CARB-001');

COMMENT ON TABLE public.produits_vente IS 'Catalogue des produits disponibles à la vente';
COMMENT ON TABLE public.commandes_vente IS 'Commandes de vente des clients';
COMMENT ON TABLE public.commande_articles IS 'Détail des articles commandés';
COMMENT ON TABLE public.mouvements_stock IS 'Historique des mouvements de stock';
COMMENT ON TABLE public.categories_produit IS 'Catégories de classification des produits'; 