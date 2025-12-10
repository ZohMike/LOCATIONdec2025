# Guide de dépannage - Ajout de clients avec photos

## Problème
Impossible d'ajouter un client lorsqu'une photo de pièce d'identité est jointe.

## Diagnostic

### Étape 1: Vérifier la console du navigateur
1. Ouvrez les outils de développement (F12)
2. Allez dans l'onglet "Console"
3. Essayez d'ajouter un client avec une photo
4. Notez tous les messages d'erreur

### Étape 2: Utiliser les outils de diagnostic intégrés
1. Ouvrez le formulaire d'ajout de client
2. Sélectionnez une photo de pièce d'identité
3. Cliquez sur le bouton "🔍 Diagnostic" (visible uniquement en mode développement)
4. Vérifiez les résultats dans la console

### Étape 3: Tests manuels

#### Test 1: Client sans photo
Essayez d'ajouter un client sans photo pour vérifier si le problème vient de la base de données ou du stockage.

#### Test 2: Vérification du bucket Supabase
1. Connectez-vous à votre dashboard Supabase
2. Allez dans "Storage"
3. Vérifiez que le bucket `client_docs` existe
4. Vérifiez les permissions du bucket

## Solutions possibles

### Solution 1: Recréer le bucket client_docs
```sql
-- Dans l'éditeur SQL de Supabase
INSERT INTO storage.buckets (id, name, public)
VALUES ('client_docs', 'Client Documents', true);

-- Ajouter les politiques RLS
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
```

### Solution 2: Vérifier les variables d'environnement
Assurez-vous que les variables suivantes sont correctement configurées dans votre fichier `.env` :
```
VITE_SUPABASE_URL=votre_url_supabase
VITE_SUPABASE_ANON_KEY=votre_clé_anonyme
```

### Solution 3: Vérifier les permissions utilisateur
L'utilisateur doit être authentifié pour pouvoir uploader des fichiers.

### Solution 4: Taille et format de fichier
- Taille maximum : 5MB
- Formats acceptés : JPEG, PNG, WEBP, GIF

## Messages d'erreur courants

### "Bucket not found"
- Le bucket `client_docs` n'existe pas
- Exécutez la migration ou créez le bucket manuellement

### "Permission denied"
- L'utilisateur n'est pas authentifié
- Les politiques RLS ne sont pas correctement configurées

### "File too large"
- Le fichier dépasse 5MB
- Réduisez la taille du fichier

### "Invalid file type"
- Le format de fichier n'est pas supporté
- Utilisez JPEG, PNG, WEBP ou GIF

## Logs de débogage

Les logs suivants sont ajoutés pour faciliter le diagnostic :
- `Starting client creation process...`
- `Uploading ID card photo...`
- `Available buckets:`
- `Upload successful:`
- `Generated public URL:`
- `Client created successfully:`

## Contact
Si le problème persiste après avoir suivi ce guide, vérifiez :
1. La configuration Supabase
2. Les permissions de l'utilisateur
3. La connectivité réseau
4. Les logs du serveur Supabase 