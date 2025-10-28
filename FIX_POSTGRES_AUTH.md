# 🔧 Correction de l'authentification PostgreSQL

## Problème
Le backend ne peut pas se connecter à PostgreSQL car l'authentification échoue.

## Solution - Exécutez ces commandes une par une

### 1. Définir le mot de passe postgres
```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

### 2. Configurer pg_hba.conf
```bash
# Backup
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup

# Modifier pour utiliser md5 au lieu de peer
sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/' /etc/postgresql/16/main/pg_hba.conf

sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' /etc/postgresql/16/main/pg_hba.conf

sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            md5/' /etc/postgresql/16/main/pg_hba.conf
```

### 3. Redémarrer PostgreSQL
```bash
sudo service postgresql restart
```

### 4. Démarrer le backend
```bash
cd /mnt/c/Users/abdou/Desktop/sengp/backend
npm run dev:simple
```

## Alternative: Exécuter tout en une commande
```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" && \
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup && \
sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/' /etc/postgresql/16/main/pg_hba.conf && \
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' /etc/postgresql/16/main/pg_hba.conf && \
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            md5/' /etc/postgresql/16/main/pg_hba.conf && \
sudo service postgresql restart
```

## Vérification
Après avoir exécuté ces commandes, testez la connexion :
```bash
psql -h localhost -U postgres -d sengp_db -c "SELECT 1;"
```
(Entrez "postgres" comme mot de passe quand demandé)

## Puis démarrez le backend
```bash
cd /mnt/c/Users/abdou/Desktop/sengp/backend
npm run dev:simple
```
