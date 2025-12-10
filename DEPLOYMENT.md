# 🚀 Guide de déploiement PhotoFlow

## Variables d'environnement requises

Avant de déployer, assurez-vous de configurer ces variables d'environnement :

```
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_GEMINI_API_KEY=your_gemini_api_key
```

## Option 1: Déploiement avec Vercel (Recommandé)

### Via GitHub (Automatique)
1. Poussez votre code sur GitHub
2. Allez sur [vercel.com](https://vercel.com)
3. "Import Project" → Sélectionnez votre repository
4. Configurez les variables d'environnement dans les settings
5. Deploy !

### Via CLI
```bash
npm install -g vercel
vercel login
vercel
```

## Option 2: Déploiement avec Netlify

### Via Drag & Drop
1. Buildez localement : `npm run build`
2. Allez sur [netlify.com](https://netlify.com)
3. Glissez le dossier `dist` sur Netlify
4. Configurez les variables d'environnement

### Via GitHub
1. Connectez votre repository GitHub
2. Configuration de build :
   - Build command: `npm run build`
   - Publish directory: `dist`

## Option 3: Railway

1. Allez sur [railway.app](https://railway.app)
2. "Deploy from GitHub"
3. Sélectionnez votre repository
4. Configurez les variables d'environnement

## Configuration Supabase pour la production

1. Dans votre dashboard Supabase :
   - Allez dans Settings → API
   - Ajoutez votre domaine de production dans "Site URL"
   - Configurez les redirect URLs pour l'authentification

2. Politiques RLS (Row Level Security) :
   - Vérifiez que toutes vos tables ont les bonnes politiques
   - Testez l'accès avec votre URL de production

## Post-déploiement

1. **Testez toutes les fonctionnalités** :
   - Authentification
   - CRUD operations
   - AI Assistant
   - Génération de PDF

2. **Configurez un domaine personnalisé** (optionnel)

3. **Monitoring** :
   - Surveillez les erreurs dans les logs
   - Configurez des alertes

## Dépannage

### Erreurs courantes :
- **404 sur les routes** : Vérifiez la configuration SPA dans `vercel.json`
- **Variables d'environnement** : Assurez-vous qu'elles sont préfixées par `VITE_`
- **CORS Supabase** : Ajoutez votre domaine dans les settings Supabase

### Support
- Vercel: [docs.vercel.com](https://docs.vercel.com)
- Netlify: [docs.netlify.com](https://docs.netlify.com)
- Supabase: [docs.supabase.com](https://docs.supabase.com) 