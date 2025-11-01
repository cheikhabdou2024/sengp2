#!/bin/bash

echo "🗄️  Configuration de la base de données SEN GP"
echo "=============================================="
echo ""

# Créer la base de données si elle n'existe pas
echo "📊 Création de la base de données..."
sudo -u postgres psql -c "CREATE DATABASE sengp_db;" 2>/dev/null || echo "Base sengp_db existe déjà ✓"

# Exécuter les migrations
echo ""
echo "🔄 Exécution des migrations SQL..."
sudo -u postgres psql -d sengp_db -f backend/src/migrations/001_initial_schema.sql

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "Vous pouvez maintenant démarrer le backend avec :"
echo "  cd backend && npm run dev:simple"
