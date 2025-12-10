# 📱 Guide d'accès à l'application sur iPad

## 🔍 Comment trouver l'URL de votre application

### Option 1 : Si l'application est déjà déployée sur Vercel

1. **Connectez-vous à Vercel** :
   - Allez sur [vercel.com](https://vercel.com)
   - Connectez-vous avec votre compte

2. **Trouvez votre projet** :
   - Dans votre dashboard, cherchez le projet "photo-flow-reserve" ou le nom que vous avez donné
   - Cliquez sur le projet

3. **Récupérez l'URL** :
   - L'URL de production est affichée en haut de la page du projet
   - Elle ressemble à : `https://votre-projet.vercel.app`
   - Vous pouvez aussi cliquer sur "Visit" pour ouvrir l'application

### Option 2 : URL Lovable (si disponible)

Si votre projet est hébergé sur Lovable, l'URL pourrait être :
```
https://5cceaa49-180a-49b9-a8c2-5aba958bec2d.lovableproject.com
```

⚠️ **Note** : Cette URL peut ne pas être accessible si le projet n'est pas publié publiquement.

### Option 3 : Déployer sur Vercel (si pas encore fait)

Si l'application n'est pas encore déployée, suivez ces étapes :

#### Méthode rapide (CLI) :

```bash
# 1. Installez Vercel CLI (si pas déjà fait)
npm install -g vercel

# 2. Connectez-vous
vercel login

# 3. Déployez depuis le dossier du projet
cd C:\Users\bimic\Documents\photo-flow-reserve
vercel

# 4. Suivez les instructions :
#    - Link to existing project? → N (nouveau projet)
#    - Project name? → photo-flow-reserve (ou votre choix)
#    - Directory? → ./
#    - Override settings? → N

# 5. Vercel va vous donner une URL comme : https://photo-flow-reserve.vercel.app
```

#### Méthode via GitHub (Recommandée) :

1. **Poussez votre code sur GitHub** (si pas déjà fait) :
   ```bash
   git add .
   git commit -m "Prepare for deployment"
   git push origin main
   ```

2. **Allez sur Vercel** :
   - [vercel.com](https://vercel.com) → "Add New" → "Project"
   - Importez votre repository GitHub
   - Configurez les variables d'environnement (voir ci-dessous)
   - Cliquez sur "Deploy"

3. **Variables d'environnement à configurer** :
   - `VITE_SUPABASE_URL` = votre URL Supabase
   - `VITE_SUPABASE_ANON_KEY` = votre clé anonyme Supabase
   - `VITE_GEMINI_API_KEY` = votre clé API Gemini (si utilisée)

### Option 4 : Test local sur votre réseau (pour développement)

Si vous voulez tester localement sur votre iPad :

1. **Trouvez l'adresse IP de votre ordinateur** :
   ```bash
   # Dans PowerShell Windows
   ipconfig
   # Cherchez "IPv4 Address" (ex: 192.168.1.100)
   ```

2. **Démarrez le serveur de développement** :
   ```bash
   npm run dev
   ```

3. **Sur votre iPad** :
   - Assurez-vous que l'iPad est sur le même réseau Wi-Fi
   - Ouvrez Safari et allez à : `http://192.168.1.100:3000` (remplacez par votre IP)

⚠️ **Note** : Cette méthode ne fonctionne que si votre ordinateur et votre iPad sont sur le même réseau Wi-Fi.

---

## 📲 Installation sur iPad (une fois l'URL obtenue)

1. **Ouvrez Safari** sur votre iPad (⚠️ pas Chrome ou Firefox)

2. **Tapez l'URL** de votre application dans la barre d'adresse

3. **Ajoutez à l'écran d'accueil** :
   - Appuyez sur le bouton de partage (icône carrée avec flèche vers le haut)
   - Faites défiler et sélectionnez **"Sur l'écran d'accueil"**
   - Personnalisez le nom si vous voulez (par défaut : "PhotoFlow")
   - Appuyez sur **"Ajouter"**

4. **C'est fait !** 🎉
   - L'application apparaît maintenant sur votre écran d'accueil
   - Vous pouvez l'ouvrir comme une app native
   - Elle fonctionne en mode plein écran

---

## ❓ Dépannage

### "Je ne trouve pas mon projet sur Vercel"
- Vérifiez que vous êtes connecté avec le bon compte
- Vérifiez que le projet a bien été déployé
- Essayez de déployer à nouveau avec `vercel`

### "L'URL ne fonctionne pas"
- Vérifiez que le déploiement est terminé (statut "Ready" sur Vercel)
- Vérifiez que les variables d'environnement sont bien configurées
- Consultez les logs de déploiement sur Vercel pour voir les erreurs

### "L'application ne se charge pas sur iPad"
- Vérifiez que vous utilisez Safari (pas Chrome)
- Vérifiez votre connexion internet
- Vérifiez que l'URL est correcte (https://...)

### "Je ne peux pas ajouter à l'écran d'accueil"
- Assurez-vous d'utiliser Safari (pas un autre navigateur)
- Vérifiez que vous êtes bien sur la page principale de l'application
- Essayez de rafraîchir la page (tirez vers le bas)

---

## 💡 Astuce

Une fois que vous avez l'URL de production, vous pouvez la sauvegarder quelque part pour y accéder facilement. L'URL Vercel est généralement stable et ne change pas sauf si vous supprimez le projet.

