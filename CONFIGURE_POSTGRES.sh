#!/bin/bash

echo "🔧 Configuration de PostgreSQL pour SEN GP"
echo "=========================================="
echo ""

# 1. Définir le mot de passe postgres
echo "📝 Définition du mot de passe pour l'utilisateur postgres..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# 2. Configurer pg_hba.conf pour permettre l'authentification par mot de passe
echo ""
echo "📝 Configuration de pg_hba.conf..."
PG_HBA="/etc/postgresql/16/main/pg_hba.conf"

# Backup du fichier original
sudo cp $PG_HBA ${PG_HBA}.backup

# Modifier la configuration pour utiliser md5 au lieu de peer
sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/' $PG_HBA
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' $PG_HBA
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            md5/' $PG_HBA

# 3. Redémarrer PostgreSQL
echo ""
echo "🔄 Redémarrage de PostgreSQL..."
sudo service postgresql restart

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "Vous pouvez maintenant démarrer le backend avec :"
echo "  cd backend && npm run dev:simple"
