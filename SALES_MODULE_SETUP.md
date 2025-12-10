# 🛒 MODULE VENTE PHOTOFLOW - GUIDE D'INSTALLATION

Ce guide vous accompagne dans l'installation complète du module vente dans votre application PhotoFlow.

## 📋 Vue d'ensemble

Le **Module Vente** transforme PhotoFlow en une plateforme hybride **Location + Vente** :

### ✨ Fonctionnalités incluses :
- 🏪 **Catalogue produits** avec gestion des stocks
- 🛒 **Système de commandes** complet
- 💰 **Gestion des paiements** de vente
- 📊 **Statistiques de vente** intégrées
- 🏷️ **Catégories de produits** organisées
- 📦 **Gestion automatique du stock**
- 🔄 **Intégration avec le système existant**

### 🏗️ Architecture :
- **Base de données** : 8 nouvelles tables
- **Interface** : Dashboard + Gestion produits/commandes
- **Services** : API complète pour la vente
- **Types** : TypeScript pour type safety

---

## 🚀 ÉTAPES D'INSTALLATION

### 1️⃣ **Application de la migration de base de données**

```bash
# Appliquer la migration SQL du module vente
psql -h <SUPABASE_HOST> -U postgres -d postgres -f supabase/migrations/20250115_create_sales_module.sql
```

**Ou via l'interface Supabase :**
1. Aller dans **SQL Editor** de votre projet Supabase
2. Copier le contenu de `supabase/migrations/20250115_create_sales_module.sql`
3. Exécuter la requête

### 2️⃣ **Mise à jour des types TypeScript**

```bash
# Régénérer les types Supabase
npx supabase gen types typescript --project-id <YOUR_PROJECT_ID> > src/integrations/supabase/types.ts
```

### 3️⃣ **Remplacement du service temporaire**

Une fois la migration appliquée, remplacez le service temporaire :

```typescript
// Supprimer
rm src/services/sales/tempSalesService.ts

// Le vrai service sera automatiquement utilisé
// src/services/sales/productService.ts (sera créé après la migration)
```

### 4️⃣ **Test de l'installation**

1. **Redémarrer l'application** :
   ```bash
   npm run dev
   ```

2. **Accéder au module** :
   - Aller sur `/app/sales`
   - Vérifier que le dashboard s'affiche
   - Tester l'ajout d'un produit

3. **Vérification base de données** :
   ```sql
   -- Vérifier que les tables sont créées
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name LIKE '%vente%' OR table_name LIKE '%commande%';
   ```

---

## 📁 STRUCTURE DU MODULE

```
src/
├── pages/
│   └── SalesPage.tsx              # Page principale du module
├── services/
│   └── sales/
│       ├── tempSalesService.ts    # Service temporaire (à supprimer)
│       ├── productService.ts      # Service produits (après migration)
│       ├── orderService.ts        # Service commandes (après migration)
│       └── categoryService.ts     # Service catégories (après migration)
├── types/
│   └── sales.ts                   # Types TypeScript du module
└── components/
    └── sales/                     # Composants spécialisés (à créer)
        ├── ProductForm.tsx
        ├── OrderForm.tsx
        └── ProductList.tsx

supabase/migrations/
└── 20250115_create_sales_module.sql  # Migration base de données
```

---

## 🗃️ TABLES CRÉÉES

| Table | Description |
|-------|------------|
| `produits_vente` | Catalogue des produits à vendre |
| `commandes_vente` | Commandes de vente clients |
| `commande_articles` | Détail des articles par commande |
| `mouvements_stock` | Historique des mouvements de stock |
| `paiements_commande` | Paiements liés aux commandes |
| `historique_prix` | Historique des changements de prix |
| `categories_produit` | Catégories de classification |
| `produit_categories` | Relation produits-catégories |

---

## 🎯 UTILISATION DU MODULE

### **Dashboard Vente**
- Statistiques en temps réel
- Alertes stock faible
- Commandes récentes
- KPIs financiers

### **Gestion Produits**
- Catalogue complet avec images
- Gestion des stocks automatique
- Promotions et réductions
- Catégorisation flexible

### **Gestion Commandes**
- Workflow complet de commande
- Suivi des statuts
- Gestion des paiements
- Historique client

### **Intégration avec Location**
- Clients unifiés (location + vente)
- Reporting consolidé
- Interface cohérente

---

## ⚙️ CONFIGURATION

### **Variables d'environnement**
Aucune variable supplémentaire requise. Le module utilise la connexion Supabase existante.

### **Permissions**
Les politiques RLS sont automatiquement configurées pour :
- ✅ **Utilisateurs authentifiés** : Accès complet
- ✅ **Public** : Lecture seule des produits actifs
- ✅ **Organisation** : Isolation des données

---

## 🧪 DONNÉES D'EXEMPLE

La migration inclut des données d'exemple :

### **Catégories :**
- Appareils Photo
- Objectifs  
- Éclairage
- Stabilisation
- Stockage
- Accessoires
- Occasion

### **Produits :**
- Carte SD 64GB UHS-I
- Batterie Canon LP-E6N
- Filtre UV 77mm
- Sac de transport
- Trépied portable

---

## 🔧 PERSONNALISATION

### **Ajouter de nouvelles catégories :**
```sql
INSERT INTO categories_produit (nom, description, ordre_affichage) 
VALUES ('Nouvelle Catégorie', 'Description', 10);
```

### **Modifier les statuts de commande :**
```sql
-- Les statuts sont définis dans les contraintes CHECK
-- Voir la migration pour les modifier
```

### **Personnaliser les numéros de commande :**
```sql
-- Modifier la fonction generate_order_number()
-- Format actuel : CMD-YYYY-DDD-NNNN
```

---

## 🐛 DÉPANNAGE

### **Erreur "Table doesn't exist"**
```bash
# Vérifier que la migration a été appliquée
psql -h <HOST> -U postgres -c "\dt public.*vente*"
```

### **Erreur de types TypeScript**
```bash
# Régénérer les types Supabase
npx supabase gen types typescript --project-id <ID> > src/integrations/supabase/types.ts
```

### **Problème de permissions**
```sql
-- Vérifier les politiques RLS
SELECT * FROM pg_policies WHERE tablename LIKE '%vente%';
```

### **Service temporaire encore actif**
```bash
# Vérifier les imports dans SalesPage.tsx
# Remplacer tempSalesService par les vrais services
```

---

## 📈 ROADMAP

### **Phase 2 - Améliorations**
- [ ] 📱 Interface mobile optimisée
- [ ] 🔗 API publique pour e-commerce
- [ ] 📊 Analytics avancées
- [ ] 🎨 Thèmes personnalisables
- [ ] 📧 Notifications automatiques
- [ ] 🏪 Multi-boutiques

### **Phase 3 - Intégrations**
- [ ] 💳 Passerelles de paiement
- [ ] 📦 Gestion des transporteurs
- [ ] 📄 Génération de factures
- [ ] 🔄 Synchronisation inventaire
- [ ] 📱 Application mobile dédiée

---

## 🤝 SUPPORT

Pour toute question ou problème :

1. **Vérifier** que la migration est appliquée
2. **Consulter** les logs de l'application
3. **Tester** avec les données d'exemple
4. **Documenter** le problème avec capture d'écran

---

## 📝 NOTES IMPORTANTES

- ⚠️ **Sauvegarde** : Faire une sauvegarde avant migration
- 🔒 **Sécurité** : Les politiques RLS protègent les données
- 📊 **Performance** : Index automatiques pour les requêtes fréquentes
- 🔄 **Migration** : Processus réversible si nécessaire

---

**🎉 Félicitations ! Votre module vente est maintenant prêt à transformer PhotoFlow en plateforme hybride location + vente !** 