#!/bin/bash

echo "🚀 DÉMARRAGE COMPLET - SEN GP"
echo "=============================="
echo ""

# Vérifier PostgreSQL
echo "📊 Vérification PostgreSQL..."
if pg_isready -q; then
    echo "   ✅ PostgreSQL fonctionne"
else
    echo "   ❌ PostgreSQL n'est pas démarré"
    echo "   Démarrage..."
    sudo service postgresql start
fi

# Vérifier Redis
echo ""
echo "🔴 Vérification Redis..."
if redis-cli ping > /dev/null 2>&1; then
    echo "   ✅ Redis fonctionne"
else
    echo "   ⚠️  Redis n'est pas démarré (optionnel)"
fi

# Configurer la base de données
echo ""
echo "🗄️  Configuration de la base de données..."
if sudo -u postgres psql -d sengp_db -c "SELECT 1 FROM users LIMIT 1" > /dev/null 2>&1; then
    echo "   ✅ Tables déjà créées"
else
    echo "   📝 Création des tables..."
    sudo -u postgres psql -d sengp_db -f backend/src/migrations/001_initial_schema.sql
fi

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "📡 Démarrage du backend..."
echo "   URL: http://localhost:5000"
echo ""
echo "💡 Dans un autre terminal, lancez le frontend :"
echo "   npx http-server www -p 8100"
echo ""
echo "=============================================="
echo ""

# Démarrer le backend
cd backend
npm run dev:simple
