# Installation de la fonctionnalité Apporteurs d'affaires

## Vue d'ensemble

La fonctionnalité Apporteurs d'affaires permet de :
- Enregistrer des partenaires apporteurs d'affaires
- Configurer des taux de commission (pourcentage ou montant fixe)
- Lier les réservations aux apporteurs
- Calculer automatiquement les commissions
- Suivre les paiements de commissions
- Afficher des statistiques de performance

## Étapes d'installation

### 1. Exécution des migrations de base de données

La nouvelle fonctionnalité nécessite la création de nouvelles tables dans Supabase. Exécutez le script SQL suivant dans votre interface Supabase :

```sql
-- Se référer au fichier: src/migrations/create_apporteurs_tables.sql
```

Ce script va créer :
- Table `apporteurs` : Pour stocker les informations des apporteurs
- Table `commissions_apporteurs` : Pour traquer les commissions
- Colonne `apporteur_id` dans la table `reservations`
- Triggers automatiques pour calculer les commissions
- Index pour optimiser les performances

### 2. Mise à jour des types TypeScript Supabase

Après avoir créé les tables, vous devez mettre à jour vos types TypeScript Supabase :

```bash
# Générer les nouveaux types (remplacez par vos identifiants Supabase)
npx supabase gen types typescript --project-id YOUR_PROJECT_ID --schema public > src/integrations/supabase/types.ts
```

### 3. Activation de la fonctionnalité

Une fois les tables créées et les types mis à jour, décommentez le code dans le fichier `src/pages/Apporteurs.tsx` :

1. Décommentez les requêtes dans les `useQuery`
2. Décommentez les opérations CRUD dans les fonctions `handleSubmit`, `handleDelete`, `toggleStatut`
3. Décommentez les statistiques dans la section des cartes de résumé

### 4. Intégration avec les réservations

Pour lier les apporteurs aux réservations, vous devrez modifier le formulaire de création de réservations pour inclure un champ de sélection d'apporteur.

#### Exemple d'ajout dans le formulaire de réservation :

```tsx
// Ajouter dans votre composant de création de réservation
const [selectedApporteur, setSelectedApporteur] = useState('');

// Récupérer la liste des apporteurs actifs
const { data: apporteurs } = useQuery({
  queryKey: ['apporteurs-actifs'],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('apporteurs')
      .select('id, nom')
      .eq('statut', 'actif')
      .order('nom');
    
    if (error) throw error;
    return data || [];
  }
});

// Dans votre JSX de formulaire
<div className="space-y-2">
  <Label htmlFor="apporteur" className="text-sm font-medium">Apporteur d'affaires</Label>
  <Select value={selectedApporteur} onValueChange={setSelectedApporteur}>
    <SelectTrigger id="apporteur" className="bg-white">
      <SelectValue placeholder="Sélectionner un apporteur (optionnel)" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="">Aucun apporteur</SelectItem>
      {apporteurs?.map((apporteur) => (
        <SelectItem key={apporteur.id} value={apporteur.id}>
          {apporteur.nom}
        </SelectItem>
      ))}
    </SelectContent>
  </Select>
</div>

// Dans votre fonction de soumission, inclure apporteur_id
const reservationData = {
  // ... autres champs
  apporteur_id: selectedApporteur || null
};
```

## Fonctionnalités disponibles

### Gestion des apporteurs
- ✅ Création, modification, suppression d'apporteurs
- ✅ Gestion des statuts (actif/inactif)
- ✅ Configuration des taux de commission
- ✅ Types de commission : pourcentage ou montant fixe

### Calcul automatique des commissions
- ✅ Trigger automatique lors de la confirmation d'une réservation
- ✅ Calcul basé sur le type et taux de commission
- ✅ Évite les commissions en double

### Suivi des commissions
- ✅ Statuts : en_attente, paye, annule
- ✅ Historique des paiements
- ✅ Statistiques par apporteur

### Interface utilisateur
- ✅ Page dédiée accessible via le menu principal
- ✅ Formulaires de création/modification en modal
- ✅ Tableau avec actions (éditer, supprimer, changer statut)
- ✅ Cartes de statistiques globales
- ✅ Design cohérent avec le reste de l'application

## Navigation

L'onglet "Apporteurs" est maintenant accessible dans le menu principal de l'application avec l'icône ❤️ (HandHeart).

## Prochaines étapes

1. Exécuter les migrations SQL
2. Mettre à jour les types TypeScript
3. Décommenter le code dans `Apporteurs.tsx`
4. Tester la fonctionnalité
5. Intégrer avec le formulaire de réservations
6. Former les utilisateurs sur la nouvelle fonctionnalité

## Support

Si vous rencontrez des problèmes lors de l'installation, vérifiez :
- Les permissions Supabase
- La syntaxe SQL dans votre environnement
- Les types TypeScript générés
- Les erreurs dans la console du navigateur 