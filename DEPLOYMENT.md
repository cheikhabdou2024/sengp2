# 🚀 SEN GP - Guide de Déploiement

Ce guide vous explique comment déployer l'application SEN GP (frontend + backend + database) sur **Render.com**.

## 📋 Prérequis

1. **Compte GitHub**
   - Créez un compte sur [GitHub](https://github.com) si vous n'en avez pas
   - Poussez votre code sur un repository GitHub

2. **Compte Render**
   - Créez un compte gratuit sur [Render.com](https://render.com)
   - Connectez votre compte GitHub à Render

## 🔧 Préparation du Projet

### 1. Initialiser Git et pousser le code

```bash
# Initialiser le repository git (si pas déjà fait)
git init

# Ajouter tous les fichiers
git add .

# Créer le premier commit
git commit -m "Initial commit - SEN GP Application"

# Ajouter le remote GitHub (remplacez par votre repo)
git remote add origin https://github.com/votre-username/sengp.git

# Pousser le code
git push -u origin main
```

### 2. Créer un fichier .gitignore

Créez un fichier `.gitignore` à la racine si ce n'est pas déjà fait :

```
# Dependencies
node_modules/
backend/node_modules/

# Environment variables
.env
backend/.env
*.env.local

# Build outputs
dist/
backend/dist/
www/
build/

# Logs
logs/
*.log
backend/logs/

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
```

## 🌐 Déploiement sur Render

### Option 1 : Déploiement automatique avec render.yaml (Recommandé)

1. **Pousser le code sur GitHub** avec le fichier `render.yaml` inclus

2. **Aller sur Render Dashboard**
   - Visitez [dashboard.render.com](https://dashboard.render.com)
   - Cliquez sur "New" → "Blueprint"

3. **Connecter le Repository**
   - Sélectionnez votre repository GitHub `sengp`
   - Render détectera automatiquement le fichier `render.yaml`

4. **Configurer les variables d'environnement**
   - Les variables de base sont déjà définies dans `render.yaml`
   - Ajoutez les variables optionnelles si nécessaire :
     - `EMAIL_HOST`, `EMAIL_USER`, `EMAIL_PASSWORD` (pour les emails)
     - `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` (pour les SMS)

5. **Déployer**
   - Cliquez sur "Apply"
   - Render va :
     - Créer une base de données PostgreSQL gratuite
     - Créer le service web
     - Builder l'application
     - Démarrer le serveur

6. **Attendre le déploiement**
   - Le premier déploiement prend 5-10 minutes
   - Surveillez les logs en temps réel

7. **Accéder à votre application**
   - URL : `https://sengp-api.onrender.com`
   - API : `https://sengp-api.onrender.com/api/v1`

### Option 2 : Déploiement manuel

#### Étape 1 : Créer la base de données PostgreSQL

1. Sur le Dashboard Render, cliquez sur "New" → "PostgreSQL"
2. Configurez :
   - **Name** : `sengp-db`
   - **Database** : `sengp_production`
   - **User** : (généré automatiquement)
   - **Region** : Choisissez la région la plus proche (ex: Frankfurt pour l'Europe)
   - **Plan** : Free
3. Cliquez sur "Create Database"
4. **Copiez la connection string** (Internal Database URL)

#### Étape 2 : Créer le Web Service

1. Cliquez sur "New" → "Web Service"
2. Connectez votre repository GitHub
3. Configurez :
   - **Name** : `sengp-api`
   - **Environment** : Node
   - **Region** : Même région que la database
   - **Branch** : `main`
   - **Root Directory** : (laisser vide)
   - **Build Command** : `npm run build:all`
   - **Start Command** : `cd backend && npm start`
   - **Plan** : Free

4. **Variables d'environnement** (Advanced → Environment Variables) :

```
NODE_ENV=production
PORT=10000
API_VERSION=v1
DATABASE_URL=[Collez l'Internal Database URL copiée]
JWT_SECRET=[Générez une clé secrète aléatoire]
JWT_REFRESH_SECRET=[Générez une autre clé secrète]
FRONTEND_URL=https://sengp-api.onrender.com
BCRYPT_ROUNDS=10
```

**Pour générer des clés secrètes** :
```bash
# Sur Linux/Mac
openssl rand -base64 32

# Sur Windows (PowerShell)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

5. Cliquez sur "Create Web Service"

#### Étape 3 : Configurer le Health Check

1. Dans les paramètres du service web
2. Allez dans "Health & Alerts"
3. Configurez :
   - **Health Check Path** : `/health`
   - **Health Check Interval** : 60 seconds

## 🔒 Configuration Post-Déploiement

### 1. Vérifier que l'API fonctionne

Ouvrez votre navigateur et visitez :
- `https://sengp-api.onrender.com/` - Devrait afficher les infos de l'API
- `https://sengp-api.onrender.com/health` - Devrait retourner le statut de santé
- `https://sengp-api.onrender.com/api/v1/auth/login` - Devrait afficher la page de connexion

### 2. Tester l'inscription

```bash
curl -X POST https://sengp-api.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "first_name": "Test",
    "last_name": "User",
    "phone": "+221771234567",
    "user_type": "expediteur"
  }'
```

### 3. Configurer un domaine personnalisé (Optionnel)

1. Dans les paramètres du service web
2. Allez dans "Settings" → "Custom Domain"
3. Ajoutez votre domaine (ex: `app.sengp.com`)
4. Configurez les DNS selon les instructions de Render

## 📊 Monitoring et Logs

### Voir les logs en temps réel

1. Dans le Dashboard Render
2. Cliquez sur votre service `sengp-api`
3. Allez dans l'onglet "Logs"
4. Les logs s'affichent en temps réel

### Métriques disponibles

- **CPU Usage**
- **Memory Usage**
- **Request Count**
- **Response Time**

## 🔄 Mises à Jour et Redéploiements

### Déploiement automatique

Render redéploie automatiquement à chaque `git push` sur la branche `main`.

```bash
# Faire des modifications
git add .
git commit -m "Update: description des changements"
git push origin main

# Render redéploie automatiquement
```

### Déploiement manuel

1. Dans le Dashboard Render
2. Cliquez sur votre service
3. Cliquez sur "Manual Deploy" → "Deploy latest commit"

### Rollback

1. Dans le Dashboard Render
2. Allez dans "Events"
3. Trouvez le déploiement précédent
4. Cliquez sur "Rollback"

## 🐛 Troubleshooting

### Le build échoue

**Vérifiez** :
- Les dépendances dans `package.json` et `backend/package.json`
- Les erreurs TypeScript dans les logs
- Que `npm run build:all` fonctionne en local

**Solution** :
```bash
# Tester le build en local
npm run build:all
```

### L'application ne démarre pas

**Vérifiez** :
- Que `DATABASE_URL` est correctement configuré
- Les logs d'erreur dans Render
- Que toutes les variables d'environnement requises sont définies

### Erreur de connexion à la base de données

**Vérifiez** :
- Que vous utilisez l'**Internal Database URL** (pas l'External)
- Que la database et le web service sont dans la **même région**
- Les logs de connexion

### L'application est lente (Free Tier)

Le plan gratuit de Render :
- **500MB RAM** (peut être limité)
- **Spin down après 15 min d'inactivité**
- Le premier accès après inactivité prend 30-60 secondes

**Solutions** :
- Upgrader vers un plan payant (7$/mois)
- Utiliser un service de ping (ex: UptimeRobot) pour garder l'app active
- Optimiser les requêtes SQL

## 💰 Coûts

### Plan Gratuit
- **PostgreSQL** : Gratuit (256MB RAM, 1GB stockage)
- **Web Service** : Gratuit (500MB RAM, spin down après 15min)
- **Limitations** : 750h/mois, SSL inclus

### Plans Payants
- **Starter** : 7$/mois (plus de RAM, pas de spin down)
- **Standard** : 25$/mois (scaling horizontal)
- **PostgreSQL Pro** : 7$/mois (1GB RAM, 10GB stockage)

## 🔐 Sécurité

### Variables d'environnement sensibles

**Ne jamais commit** :
- `.env`
- Clés API
- Secrets JWT
- Mots de passe

### SSL/TLS

Render fournit automatiquement :
- **Certificat SSL gratuit** (Let's Encrypt)
- **HTTPS par défaut**
- **Renouvellement automatique**

### CORS

Le backend est configuré pour accepter uniquement :
- L'URL de production définie dans `FRONTEND_URL`
- Vous pouvez ajouter plusieurs origines séparées par des virgules

## 📱 Connexion Mobile (Capacitor)

Pour connecter vos apps mobiles iOS/Android à l'API en production :

1. **Modifier les URLs** dans vos fichiers HTML :
```javascript
const API_BASE_URL = 'https://sengp-api.onrender.com/api/v1';
```

2. **Rebuilder l'app** :
```bash
npm run build
npm run cap:sync
```

3. **Ouvrir dans Xcode/Android Studio** et tester

## 🎉 Félicitations !

Votre application SEN GP est maintenant déployée et accessible publiquement !

**URLs utiles** :
- 🌍 Application : `https://sengp-api.onrender.com`
- 🔌 API : `https://sengp-api.onrender.com/api/v1`
- 💚 Health : `https://sengp-api.onrender.com/health`
- 📊 Dashboard : `https://dashboard.render.com`

## 📞 Support

- **Documentation Render** : [render.com/docs](https://render.com/docs)
- **Community** : [community.render.com](https://community.render.com)
- **Status** : [status.render.com](https://status.render.com)

---

**Bonne chance avec votre déploiement ! 🚀🇸🇳**
