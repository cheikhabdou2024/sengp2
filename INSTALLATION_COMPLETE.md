# 🚀 INSTALLATION COMPLÈTE - SEN GP

## ⚡ COMMANDE RAPIDE (TOUT EN UNE)

Copiez et collez cette commande dans votre terminal pour tout installer automatiquement :

```bash
cd /mnt/c/Users/abdou/Desktop/sengp && ./SETUP_DATABASE.sh && cd backend && npm run dev:simple
```

---

## 📋 OU ÉTAPE PAR ÉTAPE :

### ÉTAPE 1 : Exécuter les migrations SQL

```bash
cd /mnt/c/Users/abdou/Desktop/sengp
./SETUP_DATABASE.sh
```

**Ce script va :**
- ✅ Créer la base `sengp_db` (si pas déjà fait)
- ✅ Créer toutes les tables (users, missions, payments, etc.)
- ✅ Créer les index et triggers
- ✅ Configurer les types ENUM

### ÉTAPE 2 : Démarrer le backend

```bash
cd backend
npm run dev:simple
```

**Vous devriez voir :**
```
✅ Database connected successfully
✅ Redis connected successfully
🚀 Server is running on port 5000
📡 API Base URL: http://localhost:5000/api/v1
```

### ÉTAPE 3 : Démarrer le frontend (dans un AUTRE terminal)

```bash
cd /mnt/c/Users/abdou/Desktop/sengp
npx http-server www -p 8100
```

### ÉTAPE 4 : Tester !

Ouvrez votre navigateur :
- **Frontend** : http://localhost:8100
- **Backend Health** : http://localhost:5000/health

---

## ✅ VÉRIFICATION

### État actuel :
- ✅ PostgreSQL démarré
- ✅ Redis démarré
- ✅ Base `sengp_db` créée
- ✅ Dépendances npm installées
- ✅ Fichier .env créé
- 🔄 Migrations SQL à exécuter
- 🔄 Backend à démarrer

---

## 🔧 SI PROBLÈME

### Erreur : "relation users does not exist"
**Solution** : Les migrations ne sont pas exécutées
```bash
./SETUP_DATABASE.sh
```

### Erreur : "password authentication failed"
**Solutions** :
```bash
# Option 1 : Avec le mot de passe
PGPASSWORD=votre_mot_de_passe ./SETUP_DATABASE.sh

# Option 2 : Sans mot de passe (peer auth)
sudo -u postgres psql -d sengp_db -f backend/src/migrations/001_initial_schema.sql

# Option 3 : Manuellement
psql -U postgres -d sengp_db
# Ensuite coller le contenu de backend/src/migrations/001_initial_schema.sql
```

### Backend ne démarre pas
```bash
# Vérifier les logs
cat backend/logs/combined.log

# Vérifier PostgreSQL
pg_isready

# Vérifier Redis
redis-cli ping
```

---

## 📦 FICHIERS CRÉÉS

- ✅ `backend/package.json` - Configuration npm
- ✅ `backend/.env` - Variables d'environnement
- ✅ `backend/src/` - Code source complet
- ✅ `www/js/` - Scripts frontend connectés
- ✅ `SETUP_DATABASE.sh` - Script d'installation DB
- ✅ `FRONTEND_BACKEND_CONNECTION.md` - Documentation
- ✅ `DEMARRAGE_RAPIDE.md` - Guide rapide

---

**🎯 Prêt à démarrer ! Exécutez juste : `./SETUP_DATABASE.sh`**
