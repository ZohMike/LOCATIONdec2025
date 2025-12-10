-- ================================
-- EXTENSION MODULE VENTE - TYPES DE BUSINESS
-- Migration pour ajouter le support multi-business
-- Date: 2025-01-15
-- ================================

-- ================================
-- 1. TABLE DES TYPES DE BUSINESS
-- ================================
CREATE TABLE IF NOT EXISTS public.business_types (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    code VARCHAR(20) NOT NULL UNIQUE, -- photo, friperie, electronique, etc.
    couleur_theme VARCHAR(7) DEFAULT '#10B981', -- Couleur hexa pour l'interface
    icone VARCHAR(50) DEFAULT 'Store', -- Nom de l'icône Lucide
    
    -- Configuration des champs produits
    champs_requis JSONB DEFAULT '[]', -- ["taille", "couleur", "marque"]
    champs_optionnels JSONB DEFAULT '[]', -- ["garantie_mois", "modele"]
    
    -- Templates de catégories par défaut
    categories_template JSONB DEFAULT '[]',
    
    -- Configuration business
    gestion_stock BOOLEAN DEFAULT true,
    gestion_tailles BOOLEAN DEFAULT false,
    gestion_couleurs BOOLEAN DEFAULT false,
    gestion_garantie BOOLEAN DEFAULT false,
    
    -- Métadonnées
    actif BOOLEAN DEFAULT true,
    ordre_affichage INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ================================
-- 2. AJOUT DU TYPE DE BUSINESS AUX ORGANISATIONS
-- ================================
ALTER TABLE public.organizations 
ADD COLUMN IF NOT EXISTS business_type_id UUID REFERENCES public.business_types(id),
ADD COLUMN IF NOT EXISTS business_config JSONB DEFAULT '{}';

-- ================================
-- 3. AJOUT DU TYPE DE BUSINESS AUX CATÉGORIES
-- ================================
ALTER TABLE public.categories_produit 
ADD COLUMN IF NOT EXISTS business_type_id UUID REFERENCES public.business_types(id);

-- ================================
-- 4. AJOUT DE CHAMPS DYNAMIQUES AUX PRODUITS
-- ================================
ALTER TABLE public.produits_vente 
ADD COLUMN IF NOT EXISTS business_type_id UUID REFERENCES public.business_types(id),
ADD COLUMN IF NOT EXISTS taille VARCHAR(50),
ADD COLUMN IF NOT EXISTS couleur_principale VARCHAR(50),
ADD COLUMN IF NOT EXISTS etat_produit VARCHAR(20) DEFAULT 'neuf' CHECK (etat_produit IN ('neuf', 'occasion', 'reconditionne', 'defectueux')),
ADD COLUMN IF NOT EXISTS caracteristiques JSONB DEFAULT '{}', -- Champs dynamiques selon le type
ADD COLUMN IF NOT EXISTS notes_etat TEXT; -- Pour produits d'occasion

-- ================================
-- 5. INDEX POUR PERFORMANCES
-- ================================
CREATE INDEX IF NOT EXISTS idx_business_types_code ON public.business_types(code);
CREATE INDEX IF NOT EXISTS idx_organizations_business_type ON public.organizations(business_type_id);
CREATE INDEX IF NOT EXISTS idx_categories_business_type ON public.categories_produit(business_type_id);
CREATE INDEX IF NOT EXISTS idx_produits_business_type ON public.produits_vente(business_type_id);
CREATE INDEX IF NOT EXISTS idx_produits_etat ON public.produits_vente(etat_produit);

-- ================================
-- 6. TRIGGERS POUR MISE À JOUR AUTO
-- ================================
CREATE TRIGGER update_business_types_updated_at 
    BEFORE UPDATE ON public.business_types 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ================================
-- 7. POLITIQUES RLS
-- ================================
ALTER TABLE public.business_types ENABLE ROW LEVEL SECURITY;

-- Politique pour les types de business (lecture publique, écriture admin)
CREATE POLICY "Allow public read access to business_types" ON public.business_types
    FOR SELECT
    USING (actif = true);

CREATE POLICY "Allow authenticated users to manage business_types" ON public.business_types
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ================================
-- 8. TYPES DE BUSINESS PRÉDÉFINIS
-- ================================

-- Type 1: Location Photo (original PhotoFlow)
INSERT INTO public.business_types (
    nom, description, code, couleur_theme, icone,
    champs_requis, champs_optionnels, categories_template,
    gestion_stock, gestion_tailles, gestion_couleurs, gestion_garantie
) VALUES (
    'Location Équipements Photo',
    'Gestion de location d''équipements photographiques professionnels',
    'photo_location',
    '#3B82F6',
    'Camera',
    '["marque", "type"]',
    '["garantie_mois", "poids", "dimensions_cm"]',
    '[
        {"nom": "Appareils Photo", "description": "Appareils photo reflex, mirrorless"},
        {"nom": "Objectifs", "description": "Objectifs pour tous types d''appareils"},
        {"nom": "Éclairage", "description": "Flashs, softbox, réflecteurs"},
        {"nom": "Stabilisation", "description": "Trépieds, steadicam, gimbal"},
        {"nom": "Stockage", "description": "Cartes mémoire, disques durs"},
        {"nom": "Accessoires", "description": "Batteries, chargeurs, filtres"}
    ]',
    true, false, false, true
);

-- Type 2: Friperie / Mode
INSERT INTO public.business_types (
    nom, description, code, couleur_theme, icone,
    champs_requis, champs_optionnels, categories_template,
    gestion_stock, gestion_tailles, gestion_couleurs, gestion_garantie
) VALUES (
    'Friperie & Mode',
    'Vente de vêtements, chaussures et accessoires de mode',
    'friperie',
    '#EC4899',
    'Shirt',
    '["taille", "couleur_principale", "etat_produit"]',
    '["marque", "notes_etat"]',
    '[
        {"nom": "Vêtements Femme", "description": "Robes, pantalons, tops, vestes femme"},
        {"nom": "Vêtements Homme", "description": "Pantalons, chemises, vestes homme"},
        {"nom": "Chaussures", "description": "Chaussures pour tous styles"},
        {"nom": "Accessoires", "description": "Sacs, bijoux, ceintures, chapeaux"},
        {"nom": "Enfants", "description": "Vêtements et chaussures enfant"},
        {"nom": "Sport", "description": "Vêtements et équipements de sport"},
        {"nom": "Occasion Premium", "description": "Pièces de créateurs et vintage"}
    ]',
    true, true, true, false
);

-- Type 3: Électronique
INSERT INTO public.business_types (
    nom, description, code, couleur_theme, icone,
    champs_requis, champs_optionnels, categories_template,
    gestion_stock, gestion_tailles, gestion_couleurs, gestion_garantie
) VALUES (
    'Électronique & High-Tech',
    'Vente d''appareils électroniques et high-tech',
    'electronique',
    '#6366F1',
    'Smartphone',
    '["marque", "garantie_mois", "etat_produit"]',
    '["couleur_principale", "notes_etat"]',
    '[
        {"nom": "Smartphones", "description": "Téléphones intelligents de toutes marques"},
        {"nom": "Ordinateurs", "description": "PC, Mac, laptops, tablettes"},
        {"nom": "Audio/Vidéo", "description": "Écouteurs, enceintes, casques"},
        {"nom": "Gaming", "description": "Consoles, jeux, accessoires gaming"},
        {"nom": "Maison Connectée", "description": "Objets connectés, domotique"},
        {"nom": "Accessoires", "description": "Coques, chargeurs, cables"},
        {"nom": "Occasion Certifiée", "description": "Appareils reconditionnés garantis"}
    ]',
    true, false, true, true
);

-- Type 4: Librairie / Papeterie
INSERT INTO public.business_types (
    nom, description, code, couleur_theme, icone,
    champs_requis, champs_optionnels, categories_template,
    gestion_stock, gestion_tailles, gestion_couleurs, gestion_garantie
) VALUES (
    'Librairie & Papeterie',
    'Vente de livres, fournitures scolaires et bureau',
    'librairie',
    '#10B981',
    'BookOpen',
    '["type"]',
    '["couleur_principale"]',
    '[
        {"nom": "Livres", "description": "Romans, essais, BD, manuels"},
        {"nom": "Fournitures Scolaires", "description": "Cahiers, stylos, calculatrices"},
        {"nom": "Bureau", "description": "Matériel de bureau professionnel"},
        {"nom": "Art & Créativité", "description": "Matériel de dessin, peinture"},
        {"nom": "Jeux & Loisirs", "description": "Jeux de société, puzzles"},
        {"nom": "Informatique", "description": "Logiciels, accessoires PC"}
    ]',
    true, false, false, false
);

-- Type 5: Beauté & Cosmétiques
INSERT INTO public.business_types (
    nom, description, code, couleur_theme, icone,
    champs_requis, champs_optionnels, categories_template,
    gestion_stock, gestion_tailles, gestion_couleurs, gestion_garantie
) VALUES (
    'Beauté & Cosmétiques',
    'Produits de beauté, cosmétiques et soins',
    'beaute',
    '#F59E0B',
    'Sparkles',
    '["marque", "couleur_principale"]',
    '["notes_etat"]',
    '[
        {"nom": "Maquillage", "description": "Rouge à lèvres, fond de teint, mascara"},
        {"nom": "Soins Visage", "description": "Crèmes, sérums, nettoyants"},
        {"nom": "Soins Corps", "description": "Lotions, gels douche, parfums"},
        {"nom": "Cheveux", "description": "Shampoings, masques, accessoires"},
        {"nom": "Ongles", "description": "Vernis, outils manucure"},
        {"nom": "Accessoires", "description": "Pinceaux, éponges, miroirs"}
    ]',
    true, false, true, false
);

-- Type 6: Sport & Fitness
INSERT INTO public.business_types (
    nom, description, code, couleur_theme, icone,
    champs_requis, champs_optionnels, categories_template,
    gestion_stock, gestion_tailles, gestion_couleurs, gestion_garantie
) VALUES (
    'Sport & Fitness',
    'Équipements sportifs et fitness',
    'sport',
    '#EF4444',
    'Dumbbell',
    '["taille", "etat_produit"]',
    '["marque", "couleur_principale", "poids", "notes_etat"]',
    '[
        {"nom": "Fitness", "description": "Haltères, tapis, équipements fitness"},
        {"nom": "Vêtements Sport", "description": "Tenues de sport pour tous sports"},
        {"nom": "Chaussures Sport", "description": "Baskets, chaussures spécialisées"},
        {"nom": "Sports Collectifs", "description": "Ballons, équipements équipe"},
        {"nom": "Sports Individuels", "description": "Tennis, natation, course"},
        {"nom": "Outdoor", "description": "Randonnée, camping, vélo"}
    ]',
    true, true, true, false
);

-- ================================
-- 9. MISE À JOUR DES CATÉGORIES EXISTANTES
-- ================================

-- Associer les catégories photo existantes au type photo_location
UPDATE public.categories_produit 
SET business_type_id = (SELECT id FROM public.business_types WHERE code = 'photo_location')
WHERE nom IN ('Appareils Photo', 'Objectifs', 'Éclairage', 'Stabilisation', 'Stockage', 'Accessoires', 'Occasion');

-- ================================
-- 10. FONCTIONS UTILITAIRES
-- ================================

-- Fonction pour initialiser un business type pour une organisation
CREATE OR REPLACE FUNCTION initialize_business_type(
    org_id UUID,
    business_type_code VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    bt_record public.business_types;
    category_template JSONB;
    category JSONB;
BEGIN
    -- Récupérer le type de business
    SELECT * INTO bt_record 
    FROM public.business_types 
    WHERE code = business_type_code;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Type de business non trouvé: %', business_type_code;
    END IF;
    
    -- Mettre à jour l'organisation
    UPDATE public.organizations 
    SET business_type_id = bt_record.id,
        business_config = bt_record.categories_template
    WHERE id = org_id;
    
    -- Créer les catégories par défaut
    FOR category IN SELECT * FROM jsonb_array_elements(bt_record.categories_template)
    LOOP
        INSERT INTO public.categories_produit (
            nom, description, business_type_id, organization_id, ordre_affichage
        ) VALUES (
            category->>'nom',
            category->>'description', 
            bt_record.id,
            org_id,
            (category->>'ordre_affichage')::INTEGER
        ) ON CONFLICT DO NOTHING;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================
-- 11. VUES UTILES
-- ================================

-- Vue pour les produits avec informations business type
CREATE OR REPLACE VIEW public.produits_avec_business AS
SELECT 
    p.*,
    bt.nom as business_type_nom,
    bt.code as business_type_code,
    bt.couleur_theme as business_couleur,
    bt.gestion_tailles,
    bt.gestion_couleurs,
    bt.gestion_garantie
FROM public.produits_vente p
LEFT JOIN public.business_types bt ON p.business_type_id = bt.id;

-- Vue pour les catégories avec business type
CREATE OR REPLACE VIEW public.categories_avec_business AS
SELECT 
    c.*,
    bt.nom as business_type_nom,
    bt.code as business_type_code,
    bt.couleur_theme as business_couleur
FROM public.categories_produit c
LEFT JOIN public.business_types bt ON c.business_type_id = bt.id;

COMMENT ON TABLE public.business_types IS 'Types de business supportés par la plateforme (photo, friperie, électronique, etc.)';
COMMENT ON FUNCTION initialize_business_type IS 'Initialise un type de business pour une organisation avec ses catégories par défaut'; 