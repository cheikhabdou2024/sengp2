# 🔗 Connexion Frontend-Backend SEN GP

Ce document explique comment le frontend est connecté au backend et comment utiliser l'application complète.

## 📁 Structure du Projet

```
sengp/
├── backend/                 # API Backend (Node.js + TypeScript)
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── routes/
│   │   └── ...
│   └── package.json
│
├── www/                     # Frontend (HTML + JavaScript)
│   ├── js/                 # Scripts JavaScript
│   │   ├── config.js       # Configuration
│   │   ├── api.js          # Communication avec l'API
│   │   ├── auth.js         # Gestion authentification
│   │   ├── utils.js        # Utilitaires
│   │   ├── login.js        # Page connexion
│   │   ├── register.js     # Page inscription
│   │   └── missions.js     # Gestion des missions
│   ├── connexion.html
│   ├── inscrire.html
│   ├── creenvoi.html
│   └── ...
│
└── capacitor.config.json    # Configuration Capacitor (Mobile)
```

## 🚀 Démarrage Rapide

### 1. Démarrer le Backend

```bash
# Dans le dossier backend
cd backend

# Installer les dépendances (première fois)
npm install

# Créer la base de données PostgreSQL
psql -U postgres
CREATE DATABASE sengp_db;
\c sengp_db
\i src/migrations/001_initial_schema.sql

# Créer le fichier .env (copier depuis .env.example)
cp .env.example .env

# Modifier .env avec vos paramètres
# Assurez-vous que:
# - DB_NAME=sengp_db
# - DB_USER=postgres
# - DB_PASSWORD=votre_mot_de_passe
# - JWT_SECRET=votre-secret-jwt

# Démarrer Redis
redis-server
# ou avec Docker: docker run --name redis -p 6379:6379 -d redis

# Démarrer le serveur backend
npm run dev
```

Le backend sera disponible sur **http://localhost:5000**

### 2. Démarrer le Frontend

```bash
# Dans le dossier racine du projet
cd sengp

# Servir le dossier www (plusieurs options):

# Option 1: Avec http-server (recommandé)
npx http-server www -p 8100

# Option 2: Avec Python
python -m http.server 8100 --directory www

# Option 3: Avec PHP
cd www && php -S localhost:8100

# Option 4: Avec Live Server (VS Code extension)
# Clic droit sur www/index.html > "Open with Live Server"
```

Le frontend sera disponible sur **http://localhost:8100**

## 📡 Comment ça fonctionne ?

### Architecture de la Communication

```
┌─────────────────┐         HTTP/JSON         ┌─────────────────┐
│                 │  ◄────────────────────►   │                 │
│   Frontend      │                            │    Backend      │
│  (HTML/JS)      │   API REST Endpoints       │   (Node.js)     │
│  Port: 8100     │                            │   Port: 5000    │
│                 │                            │                 │
└─────────────────┘                            └────────┬────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │   PostgreSQL    │
                                               │   + Redis       │
                                               └─────────────────┘
```

### Flux d'Authentification

1. **Inscription**
   ```javascript
   // Frontend (inscrire.html + register.js)
   const userData = {
     email: "user@example.com",
     password: "motdepasse123",
     user_type: "expediteur",
     ...
   };

   const response = await api.register(userData);
   ```

   ```
   POST http://localhost:5000/api/v1/auth/register
   → Backend crée l'utilisateur dans PostgreSQL
   → Retourne { user: {...}, token: "JWT..." }
   → Frontend sauvegarde le token dans localStorage
   → Redirection vers le dashboard
   ```

2. **Connexion**
   ```javascript
   // Frontend (connexion.html + login.js)
   const response = await api.login({ email, password });
   ```

   ```
   POST http://localhost:5000/api/v1/auth/login
   → Backend vérifie les credentials
   → Retourne { user: {...}, token: "JWT..." }
   → Frontend sauvegarde le token
   → Redirection selon le type d'utilisateur
   ```

3. **Requêtes Protégées**
   ```javascript
   // Toutes les requêtes suivantes incluent le token
   Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
   ```

### Flux de Création de Mission

```javascript
// Frontend (creenvoi.html + missions.js)
const missionData = {
  departure_city: "Dakar",
  arrival_city: "Paris",
  package_weight: 3.5,
  offered_price: 65000,
  ...
};

const mission = await missionsManager.createMission(missionData);
```

```
POST http://localhost:5000/api/v1/missions
Authorization: Bearer {token}

→ Backend valide les données
→ Crée la mission dans PostgreSQL
→ Génère un tracking_number
→ Retourne la mission créée avec son ID
→ Frontend affiche la confirmation
```

## 🔧 Configuration

### Configuration Backend (backend/.env)

```env
# URL de l'API (utilisée par le frontend)
API_URL=http://localhost:5000/api/v1

# Base de données
DB_NAME=sengp_db
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe

# JWT
JWT_SECRET=votre-secret-jwt-tres-securise
JWT_EXPIRES_IN=24h

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
```

### Configuration Frontend (www/js/config.js)

```javascript
const CONFIG = {
  API_URL: 'http://localhost:5000/api/v1',  // URL du backend

  STORAGE_KEYS: {
    TOKEN: 'sengp_token',
    USER: 'sengp_user'
  }
};
```

## 📝 Utilisation de l'API depuis le Frontend

### Exemple 1: Connexion

```javascript
// Dans n'importe quel fichier JS du frontend
try {
  const response = await api.login({
    email: 'user@example.com',
    password: 'motdepasse123'
  });

  if (response.success) {
    console.log('Connecté:', response.data.user);
    // Token automatiquement sauvegardé
    Auth.redirectToDashboard();
  }
} catch (error) {
  Utils.showError(error.message);
}
```

### Exemple 2: Créer une Mission

```javascript
try {
  const mission = await missionsManager.createMission({
    departure_city: 'Dakar',
    arrival_city: 'Paris',
    package_weight: 5.0,
    offered_price: 75000,
    desired_departure_date: '2025-11-01',
    ...
  });

  console.log('Mission créée:', mission);
  Utils.showSuccess('Mission créée avec succès !');
} catch (error) {
  Utils.handleAPIError(error);
}
```

### Exemple 3: Charger Mes Missions

```javascript
try {
  const response = await missionsManager.loadMyMissions('pending');

  missionsManager.renderMissionsList(
    response.data,
    'missions-container'
  );
} catch (error) {
  Utils.handleAPIError(error);
}
```

## 🔐 Sécurité

### Stockage du Token

Le token JWT est stocké dans `localStorage`:

```javascript
// Sauvegarde automatique lors de la connexion/inscription
localStorage.setItem('sengp_token', token);

// Récupération automatique pour chaque requête
const token = localStorage.getItem('sengp_token');

// Suppression lors de la déconnexion
localStorage.removeItem('sengp_token');
```

### Protection des Pages

```javascript
// Dans auth.js - Protection automatique des pages
document.addEventListener('DOMContentLoaded', () => {
  const publicPages = ['index.html', 'connexion.html', 'inscrire.html'];
  const currentPage = window.location.pathname.split('/').pop();

  if (!publicPages.includes(currentPage) && !Auth.isAuthenticated()) {
    window.location.href = 'connexion.html';
  }
});
```

## 🎯 Pages Connectées

### ✅ Pages Déjà Connectées

1. **connexion.html** → Backend Auth
   - Formulaire connecté à `/api/v1/auth/login`
   - Stockage du token
   - Redirection automatique

2. **inscrire.html** → Backend Auth
   - Formulaire connecté à `/api/v1/auth/register`
   - Création de profil GP/Expéditeur
   - Redirection après inscription

### 🔄 Pages à Connecter (TODO)

3. **creenvoi.html** → Créer des missions
4. **dashexpediteur.html** → Dashboard expéditeur
5. **dashgp.html** → Dashboard GP
6. **missions.html** → Liste des missions
7. **suivi.html** → Suivi des colis
8. **notifications.html** → Notifications
9. **profile.html** → Profil utilisateur

## 🐛 Dépannage

### Le frontend ne se connecte pas au backend

**Erreur**: `Failed to fetch` ou `Network request failed`

**Solutions**:
1. Vérifier que le backend est démarré sur `http://localhost:5000`
2. Vérifier que CORS est activé dans le backend
3. Vérifier l'URL dans `www/js/config.js`

```bash
# Tester le backend directement
curl http://localhost:5000/health

# Devrait retourner:
# {"success":true,"message":"Server is running","timestamp":"..."}
```

### Token expiré

**Erreur**: `401 Unauthorized` ou `Token expired`

**Solution**: Se reconnecter

```javascript
// Le frontend gère automatiquement:
if (error.message.includes('401')) {
  Utils.showError('Session expirée. Veuillez vous reconnecter.');
  api.logout();
}
```

### CORS Error

**Erreur**: `Access to fetch at ... has been blocked by CORS policy`

**Solution**: Vérifier la configuration CORS dans `backend/src/app.ts`:

```typescript
app.use(cors({
  origin: 'http://localhost:8100',  // URL du frontend
  credentials: true,
}));
```

## 🧪 Tester la Connexion

### Test 1: Health Check Backend

```bash
curl http://localhost:5000/health
```

### Test 2: Inscription via API

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "phone": "+221771234567",
    "password": "motdepasse123",
    "user_type": "expediteur",
    "first_name": "Test",
    "last_name": "User",
    "country": "Sénégal",
    "city": "Dakar"
  }'
```

### Test 3: Connexion via API

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "motdepasse123"
  }'
```

### Test 4: Via le Frontend

1. Ouvrir http://localhost:8100
2. Aller sur "S'inscrire"
3. Remplir le formulaire
4. Vérifier la console du navigateur (F12)
5. Si succès → redirection vers le dashboard

## 📊 Monitoring

### Logs Backend

```bash
# Voir les logs en temps réel
tail -f backend/logs/combined.log
```

### Logs Frontend (Console Navigateur)

Ouvrir la console (F12) et vérifier:
- Les requêtes API (onglet Network)
- Les erreurs JavaScript (onglet Console)
- Le localStorage (onglet Application)

## 🎉 Résumé

Le frontend et le backend sont **maintenant connectés** !

✅ Authentification fonctionnelle
✅ Communication API établie
✅ Stockage des tokens
✅ Gestion des erreurs
✅ Protection des routes

**Prochaines étapes**:
- Connecter les autres pages (dashboard, missions, etc.)
- Ajouter le service de paiements
- Implémenter les notifications en temps réel
- Tester sur mobile avec Capacitor

---

**Bon développement ! 🚀**
