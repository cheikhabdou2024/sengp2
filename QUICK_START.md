# 🚀 SEN GP - Guide de Démarrage Rapide

## 📦 Installation en 5 minutes

### Prérequis
- Node.js 18+ installé
- PostgreSQL 14+ installé
- Git installé

### 1. Cloner le projet

```bash
git clone https://github.com/votre-username/sengp.git
cd sengp
```

### 2. Installer les dépendances

```bash
# Root (frontend)
npm install

# Backend
cd backend
npm install
cd ..
```

### 3. Configurer la base de données

```bash
# Créer la base de données PostgreSQL
psql -U postgres
```

Dans le shell PostgreSQL :
```sql
CREATE DATABASE sengp_dev;
\q
```

### 4. Configurer l'environnement

```bash
# Copier le fichier d'exemple
cp backend/.env.example backend/.env
```

Éditez `backend/.env` et configurez :
```env
DATABASE_URL=postgresql://postgres:votre_password@localhost:5432/sengp_dev
JWT_SECRET=votre_secret_jwt_très_sécurisé
JWT_REFRESH_SECRET=votre_autre_secret_très_sécurisé
```

### 5. Lancer l'application

#### Développement - Deux terminaux

**Terminal 1 - Backend** :
```bash
npm run dev:backend
```

**Terminal 2 - Frontend** :
```bash
npm run dev:frontend
```

L'application sera accessible sur :
- 🎨 Frontend : http://localhost:8100
- 🔌 API : http://localhost:5000/api/v1

### 6. Tester l'application

1. Ouvrez http://localhost:8100
2. Cliquez sur "S'inscrire"
3. Créez un compte expéditeur ou GP
4. Connectez-vous et explorez !

## 📱 Commandes utiles

```bash
# Build frontend
npm run build

# Build tout (frontend + backend)
npm run build:all

# Lancer backend en mode dev
npm run dev:backend

# Lancer frontend en mode dev
npm run dev:frontend

# Backend - Migrations
cd backend
npm run migrate:up    # Appliquer les migrations
npm run migrate:down  # Annuler la dernière migration
npm run migrate:create nom_migration  # Créer une nouvelle migration

# Tests
cd backend
npm test
npm run test:watch

# Linting
cd backend
npm run lint
npm run format
```

## 🔧 Configuration des services optionnels

### Email (Nodemailer)

Dans `backend/.env` :
```env
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=votre_email@gmail.com
EMAIL_PASSWORD=votre_mot_de_passe_app
EMAIL_FROM=noreply@sengp.com
```

### SMS (Twilio)

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890
```

### Redis (Cache)

```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
```

## 🐛 Résolution des problèmes courants

### Erreur : "Cannot connect to database"

**Solution** :
1. Vérifiez que PostgreSQL est démarré
2. Vérifiez les credentials dans `.env`
3. Vérifiez que la database existe

```bash
# Démarrer PostgreSQL (Linux)
sudo service postgresql start

# Démarrer PostgreSQL (Mac)
brew services start postgresql

# Vérifier la connexion
psql -U postgres -d sengp_dev
```

### Erreur : "Port 5000 is already in use"

**Solution** :
```bash
# Linux/Mac - Trouver le processus
lsof -i :5000
kill -9 PID

# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Erreur : "TypeScript compilation errors"

**Solution** :
```bash
cd backend
npm install
npm run build
```

### Frontend ne se connecte pas au backend

**Solution** :
1. Vérifiez que le backend est démarré sur le port 5000
2. Vérifiez les URLs dans les fichiers HTML :
```javascript
const API_BASE_URL = 'http://localhost:5000/api/v1';
```

## 📱 Mobile (Capacitor)

### Synchroniser avec iOS/Android

```bash
# Installer Capacitor CLI (si pas déjà fait)
npm install

# Synchroniser les assets
npm run cap:sync

# Ouvrir dans Xcode
npm run cap:ios

# Ouvrir dans Android Studio
npm run cap:android
```

### Prérequis mobile
- **iOS** : Xcode 14+, macOS
- **Android** : Android Studio, JDK 11+

## 🌍 Déploiement

Voir le guide complet dans [DEPLOYMENT.md](./DEPLOYMENT.md)

### Déploiement rapide sur Render

1. Poussez le code sur GitHub
2. Créez un compte sur [Render.com](https://render.com)
3. Connectez votre repository
4. Render détectera `render.yaml` et déploiera automatiquement

## 📚 Documentation

- **API Documentation** : http://localhost:5000/ (quand le backend est lancé)
- **Structure du projet** : Voir `backend/src/` pour l'architecture
- **Routes API** : Voir `backend/src/routes/`
- **Services** : Voir `backend/src/services/`

## 🎯 Fonctionnalités principales

### Pour les Expéditeurs
- ✅ Créer un envoi de colis
- ✅ Suivre les colis en temps réel
- ✅ Gérer les réclamations
- ✅ Consulter les notifications
- ✅ Payer en ligne (Wave, Orange Money, etc.)

### Pour les GPs (Voyageurs)
- ✅ Créer un trajet avec billet d'avion
- ✅ Voir les missions correspondantes
- ✅ Accepter des missions
- ✅ Suivre les livraisons
- ✅ Consulter les gains

## 🤝 Contribution

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 License

MIT License - voir le fichier [LICENSE](LICENSE) pour plus de détails

## 👥 Support

- 📧 Email : support@sengp.com
- 💬 Discord : [Rejoindre](https://discord.gg/sengp)
- 🐦 Twitter : [@SEN_GP](https://twitter.com/SEN_GP)

---

**Bon développement ! 🇸🇳🚀**
