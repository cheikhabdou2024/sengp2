# 🚀 GUIDE DE DÉMARRAGE RAPIDE - SEN GP

## ✅ Ce qui a été fait

### Backend ✨
- ✅ API REST complète avec Express + TypeScript
- ✅ Authentification JWT (login/register)
- ✅ Service de gestion des missions
- ✅ Base de données PostgreSQL configurée
- ✅ Migrations SQL créées
- ✅ Middlewares de sécurité (CORS, Helmet, Rate Limiting)
- ✅ Gestion des erreurs et logging

### Frontend ✨
- ✅ Module API (api.js) pour communiquer avec le backend
- ✅ Module Auth (auth.js) pour gérer l'authentification
- ✅ Module Utils (utils.js) pour les utilitaires
- ✅ Module Missions (missions.js) pour gérer les colis
- ✅ Page de connexion connectée au backend
- ✅ Page d'inscription connectée au backend
- ✅ Stockage sécurisé des tokens JWT
- ✅ Protection automatique des routes

### Configuration Mobile ✨
- ✅ Capacitor configuré pour Android et iOS
- ✅ Fichiers de configuration pour les stores
- ✅ Permissions et metadata configurées

---

## 🎯 DÉMARRER L'APPLICATION (3 étapes)

### ÉTAPE 1: Démarrer la Base de Données

```bash
# Démarrer PostgreSQL
# Sur Windows (WSL):
sudo service postgresql start

# Créer la base de données
psql -U postgres
CREATE DATABASE sengp_db;
\q

# Exécuter les migrations
psql -U postgres -d sengp_db -f backend/src/migrations/001_initial_schema.sql

# Démarrer Redis (dans un nouveau terminal)
redis-server
# OU avec Docker:
docker run --name sengp-redis -p 6379:6379 -d redis
```

### ÉTAPE 2: Démarrer le Backend

```bash
# Aller dans le dossier backend
cd backend

# Installer les dépendances (première fois seulement)
npm install

# Créer le fichier .env (première fois seulement)
cp .env.example .env

# IMPORTANT: Éditer le fichier .env et configurer:
# - DB_PASSWORD=votre_mot_de_passe_postgres
# - JWT_SECRET=un-secret-tres-securise-aleatoire

# Démarrer le serveur backend
npm run dev
```

**✅ Le backend est prêt quand vous voyez:**
```
✅ Database connected successfully
✅ Redis connected successfully
🚀 Server is running on port 5000
```

### ÉTAPE 3: Démarrer le Frontend

```bash
# Dans un NOUVEAU terminal, à la racine du projet
cd /mnt/c/Users/abdou/Desktop/sengp

# Servir le dossier www
npx http-server www -p 8100
```

**✅ Le frontend est prêt quand vous voyez:**
```
Available on:
  http://localhost:8100
```

---

## 🧪 TESTER L'APPLICATION

### Test 1: Vérifier le Backend

Ouvrir un navigateur et aller sur:
```
http://localhost:5000/health
```

Vous devriez voir:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-10-27T...",
  "uptime": 12.345
}
```

### Test 2: Ouvrir le Frontend

Ouvrir un navigateur et aller sur:
```
http://localhost:8100
```

### Test 3: Créer un Compte

1. Cliquer sur **"Créer un compte"**
2. Choisir **"Expéditeur"** (pour envoyer des colis)
3. Remplir le formulaire:
   - Prénom: **Amadou**
   - Nom: **Diop**
   - Email: **amadou@example.com**
   - Téléphone: **+221771234567**
   - Mot de passe: **Test1234**
   - Pays: **Sénégal**
   - Ville: **Dakar**
4. Cliquer sur **"S'inscrire"**

**✅ Si succès:**
- Message "Inscription réussie !"
- Redirection automatique vers le dashboard expéditeur

### Test 4: Se Connecter

1. Cliquer sur **"Se connecter"**
2. Email: **amadou@example.com**
3. Mot de passe: **Test1234**
4. Cliquer sur **"Se connecter"**

**✅ Si succès:**
- Message "Connexion réussie !"
- Redirection vers votre dashboard

### Test 5: Vérifier dans la Console

Ouvrir la console du navigateur (F12) et taper:
```javascript
// Vérifier le token
localStorage.getItem('sengp_token')
// Devrait afficher: "eyJhbGciOiJIUzI1NiIs..."

// Vérifier l'utilisateur
JSON.parse(localStorage.getItem('sengp_user'))
// Devrait afficher: {id: "...", email: "amadou@example.com", ...}

// Tester une requête API
api.getMyMissions().then(console.log)
```

---

## 📱 TESTER SUR MOBILE (Capacitor)

### Sur Android

```bash
# Synchroniser les fichiers
npm run cap:sync

# Ouvrir Android Studio
npm run cap:android

# Dans Android Studio:
# 1. Attendez que Gradle finisse de synchroniser
# 2. Connectez un appareil Android ou démarrez un émulateur
# 3. Cliquez sur "Run" (▶️)
```

### Sur iOS (Mac uniquement)

```bash
# Synchroniser les fichiers
npm run cap:sync

# Ouvrir Xcode
npm run cap:ios

# Dans Xcode:
# 1. Sélectionnez votre équipe de développement
# 2. Sélectionnez un simulateur iPhone
# 3. Cliquez sur "Run" (▶️)
```

---

## 🔧 DÉPANNAGE

### ❌ "Failed to fetch" / "Network request failed"

**Problème**: Le frontend ne peut pas contacter le backend

**Solutions**:
1. Vérifiez que le backend est démarré (`http://localhost:5000/health`)
2. Vérifiez que l'URL est correcte dans `www/js/config.js`
3. Désactivez les bloqueurs de publicités
4. Vérifiez la console pour plus de détails (F12)

### ❌ "Database connection failed"

**Problème**: PostgreSQL n'est pas démarré ou mal configuré

**Solutions**:
```bash
# Vérifier si PostgreSQL fonctionne
sudo service postgresql status

# Démarrer PostgreSQL
sudo service postgresql start

# Tester la connexion
psql -U postgres -c "SELECT version();"
```

### ❌ "Redis connection failed"

**Problème**: Redis n'est pas démarré

**Solutions**:
```bash
# Vérifier si Redis fonctionne
redis-cli ping
# Devrait retourner: PONG

# Si non, démarrer Redis
redis-server

# OU avec Docker
docker start sengp-redis
```

### ❌ "Email already registered"

**Problème**: L'email existe déjà dans la base

**Solutions**:
- Utilisez un autre email
- OU supprimez l'utilisateur existant:
```sql
psql -U postgres -d sengp_db
DELETE FROM users WHERE email = 'amadou@example.com';
```

---

## 📊 VÉRIFIER QUE TOUT FONCTIONNE

### ✅ Checklist

- [ ] PostgreSQL démarre sans erreur
- [ ] Redis démarre sans erreur
- [ ] Backend démarre sur port 5000
- [ ] `/health` retourne un JSON
- [ ] Frontend se charge sur port 8100
- [ ] L'inscription fonctionne
- [ ] La connexion fonctionne
- [ ] Le token est sauvegardé dans localStorage
- [ ] Les routes sont protégées (redirection si non connecté)

---

## 📁 STRUCTURE FINALE

```
sengp/
├── backend/                          # API Backend
│   ├── src/
│   │   ├── config/                  # Configuration (DB, Redis)
│   │   ├── controllers/             # Contrôleurs (auth, missions)
│   │   ├── services/                # Logique métier
│   │   ├── middlewares/             # Auth, validation, erreurs
│   │   ├── routes/                  # Routes API
│   │   ├── types/                   # Types TypeScript
│   │   ├── utils/                   # Utilitaires
│   │   ├── validators/              # Validateurs
│   │   ├── migrations/              # Migrations SQL
│   │   ├── app.ts                   # Configuration Express
│   │   └── server.ts                # Point d'entrée
│   ├── .env                         # Variables d'environnement
│   ├── package.json
│   └── tsconfig.json
│
├── www/                              # Frontend
│   ├── js/                          # Scripts JavaScript
│   │   ├── config.js               # Configuration API
│   │   ├── api.js                  # Module API
│   │   ├── auth.js                 # Authentification
│   │   ├── utils.js                # Utilitaires
│   │   ├── login.js                # Page connexion
│   │   ├── register.js             # Page inscription
│   │   └── missions.js             # Gestion missions
│   ├── connexion.html              ✅ CONNECTÉ
│   ├── inscrire.html               ✅ CONNECTÉ
│   ├── dashexpediteur.html         🔄 À connecter
│   ├── dashgp.html                 🔄 À connecter
│   ├── creenvoi.html               🔄 À connecter
│   └── ...
│
├── android/                          # Application Android
├── ios/                              # Application iOS
├── capacitor.config.json             # Config Capacitor
├── FRONTEND_BACKEND_CONNECTION.md    # Documentation détaillée
└── DEMARRAGE_RAPIDE.md              # Ce fichier
```

---

## 🎯 PROCHAINES ÉTAPES

### Pages à Connecter

1. **creenvoi.html** - Créer une mission
2. **dashexpediteur.html** - Dashboard expéditeur avec liste des missions
3. **dashgp.html** - Dashboard GP avec missions disponibles
4. **missions.html** - Liste complète des missions
5. **suivi.html** - Suivi d'un colis par tracking number
6. **profile.html** - Profil utilisateur
7. **notifications.html** - Notifications

### Fonctionnalités à Implémenter

1. ✅ Authentification (login/register)
2. ✅ Création de missions
3. 🔄 Acceptation de missions (GP)
4. 🔄 Mise à jour statut
5. 🔄 Suivi en temps réel
6. 🔄 Paiements (Wave, Orange Money)
7. 🔄 Notifications push
8. 🔄 Réclamations
9. 🔄 Évaluations

---

## 💡 ASTUCES

### Commandes Rapides

```bash
# Tout redémarrer rapidement
cd backend && npm run dev &
cd .. && npx http-server www -p 8100

# Voir les logs en temps réel
tail -f backend/logs/combined.log

# Tester une route API rapidement
curl http://localhost:5000/health

# Nettoyer la base de données
psql -U postgres -d sengp_db -c "TRUNCATE users, missions CASCADE;"
```

### Outils de Développement

- **Postman** / **Insomnia**: Tester les API
- **pgAdmin**: Interface graphique pour PostgreSQL
- **Redis Commander**: Interface graphique pour Redis
- **Chrome DevTools**: Déboguer le frontend (F12)

---

## 📞 BESOIN D'AIDE ?

1. **Consulter la documentation détaillée**: `FRONTEND_BACKEND_CONNECTION.md`
2. **Vérifier l'architecture backend**: `BACKEND_ARCHITECTURE.md`
3. **Consulter les logs**: `backend/logs/combined.log`
4. **Vérifier la console**: F12 dans le navigateur

---

**🎉 Félicitations ! Votre application SEN GP est maintenant opérationnelle !**

Bon développement ! 🚀
