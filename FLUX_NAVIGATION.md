# 🗺️ Flux de Navigation - SEN GP Application

## 📱 Architecture Complète de l'Application

### 🎯 **FLUX PRINCIPAL - Parcours Utilisateur Complet**

```
┌─────────────────────────────────────────────────────────────────┐
│                     ONBOARDING & AUTHENTIFICATION                │
└─────────────────────────────────────────────────────────────────┘

1️⃣ index.html (Onboarding)
   │
   ├─ Screen 1: Onboarding 1 - Présentation
   ├─ Screen 2: Onboarding 2 - Suivi en temps réel
   ├─ Screen 3: Onboarding 3 - Gains potentiels
   └─ Screen 4: Choix du profil (Expéditeur / GP)
      │
      ├─ Clic "Expéditeur" → Continue
      │  └─→ inscrire.html?type=sender
      │
      ├─ Clic "Gros Porteur (GP)" → Continue
      │  └─→ inscrire.html?type=carrier
      │
      └─ Lien "Se connecter"
         └─→ connexion.html

┌─────────────────────────────────────────────────────────────────┐
│                          INSCRIPTION                             │
└─────────────────────────────────────────────────────────────────┘

2️⃣ inscrire.html
   │
   ├─ Bouton "← Retour"
   │  └─→ index.html
   │
   ├─ Lien "Se connecter"
   │  └─→ connexion.html
   │
   └─ Formulaire soumis (validation réussie)
      └─→ ⏱️ 1.5s → connexion.html

┌─────────────────────────────────────────────────────────────────┐
│                           CONNEXION                              │
└─────────────────────────────────────────────────────────────────┘

3️⃣ connexion.html
   │
   ├─ Lien "S'inscrire"
   │  └─→ index.html
   │
   ├─ Lien "Mot de passe oublié ?"
   │  └─→ oublie.html
   │
   ├─ Connexion réussie (formulaire)
   │  └─→ ⏱️ 1.5s → dashexpediteur.html
   │
   └─ Connexion sociale (Google/Facebook)
      └─→ ⏱️ 1.5s → dashexpediteur.html

┌─────────────────────────────────────────────────────────────────┐
│                    MOT DE PASSE OUBLIÉ                          │
└─────────────────────────────────────────────────────────────────┘

4️⃣ oublie.html
   │
   └─ (Récupération de mot de passe)

┌─────────────────────────────────────────────────────────────────┐
│                    DASHBOARD EXPÉDITEUR                          │
└─────────────────────────────────────────────────────────────────┘

5️⃣ dashexpediteur.html
   │
   ├─ Bouton "📦 Créer un envoi"
   │  └─→ creenvoi.html
   │
   ├─ Clic sur un envoi récent
   │  └─→ (Détails de l'envoi)
   │
   └─ Bottom Navigation Bar (5 onglets)
      ├─ 🏠 Accueil (actif)
      ├─ 📍 Suivi
      ├─ ➕ Nouveau
      ├─ 💬 Messages
      └─ 👤 Profil

┌─────────────────────────────────────────────────────────────────┐
│                    CRÉATION D'ENVOI (Multi-étapes)               │
└─────────────────────────────────────────────────────────────────┘

6️⃣ creenvoi.html
   │
   ├─ Bouton "← Retour" (Étape 1)
   │  └─→ dashexpediteur.html
   │
   ├─ Bouton "← Retour" (Autres étapes)
   │  └─→ Étape précédente
   │
   └─ Processus de création (4 étapes)
      │
      ├─ Étape 1: 🌍 Destination
      │  └─ Sélection pays de départ/arrivée
      │
      ├─ Étape 2: 👤 Sélection GP
      │  └─ Choix du Gros Porteur
      │
      ├─ Étape 3: 📦 Détails du colis
      │  └─ Informations du colis
      │
      └─ Étape 4: 💳 Paiement
         └─ Confirmation paiement
            └─→ ⏱️ 2s → paiement.html

┌─────────────────────────────────────────────────────────────────┐
│                    CONFIRMATION D'ENVOI                          │
└─────────────────────────────────────────────────────────────────┘

7️⃣ paiement.html
   │
   ├─ ✅ Envoi confirmé
   ├─ 📱 QR Code généré
   ├─ 🔢 Numéro de suivi unique
   │
   ├─ Bouton "📥 Télécharger le QR Code"
   │  └─→ (Téléchargement QR)
   │
   ├─ Bouton "📤 Partager le suivi"
   │  └─→ (Partage du numéro)
   │
   └─ Bouton "🏠 Retour au tableau de bord"
      └─→ dashexpediteur.html ✅
```

---

## 🔄 **Flux Secondaires**

### 📱 Navigation Bottom Bar (dashexpediteur.html)
```
🏠 Accueil    → Page actuelle
📍 Suivi      → (Suivi des colis)
➕ Nouveau    → creenvoi.html
💬 Messages   → (Messagerie)
👤 Profil     → (Profil utilisateur)
```

---

## 📊 **Résumé des Connexions**

| Depuis | Action | Vers |
|--------|--------|------|
| `index.html` | Bouton "Continuer" (Expéditeur) | `inscrire.html?type=sender` |
| `index.html` | Bouton "Continuer" (GP) | `inscrire.html?type=carrier` |
| `index.html` | Lien "Se connecter" | `connexion.html` |
| `inscrire.html` | Bouton "Retour" | `index.html` |
| `inscrire.html` | Lien "Se connecter" | `connexion.html` |
| `inscrire.html` | Formulaire soumis | `connexion.html` (1.5s) |
| `connexion.html` | Lien "S'inscrire" | `index.html` |
| `connexion.html` | Lien "Mot de passe oublié" | `oublie.html` |
| `connexion.html` | Connexion réussie | `dashexpediteur.html` (1.5s) |
| `dashexpediteur.html` | Bouton "Créer un envoi" | `creenvoi.html` |
| `creenvoi.html` | Bouton "Retour" (Étape 1) | `dashexpediteur.html` |
| `creenvoi.html` | Paiement confirmé | `paiement.html` (2s) |
| `paiement.html` | Bouton "Retour au dashboard" | `dashexpediteur.html` |

---

## ✅ **Statut de l'Application**

### 🎨 **Design & Responsive**
- ✅ Tous les écrans sont responsive
- ✅ Adapté pour tous les devices Android (320px - 768px+)
- ✅ Support orientation portrait & paysage
- ✅ Support devices avec notch (safe-area-inset)
- ✅ Bottom navbar optimisée et centrée

### 🔗 **Navigation**
- ✅ Flux d'onboarding complet (4 écrans)
- ✅ Inscription fonctionnelle
- ✅ Connexion fonctionnelle
- ✅ Dashboard interactif
- ✅ Création d'envoi multi-étapes
- ✅ Confirmation avec QR code

### 🚀 **Fonctionnalités**
- ✅ Animations fluides
- ✅ Transitions entre écrans
- ✅ Validation de formulaires
- ✅ Génération de QR codes
- ✅ Numéros de suivi uniques
- ✅ Partage natif (Web Share API)

---

## 📝 **Notes Importantes**

1. **Toutes les sources d'images sont maintenues** dans le dossier `im/`
2. **Aucun emoji ajouté** sauf ceux déjà présents
3. **Navigation bidirectionnelle** sur tous les écrans
4. **Délais de redirection** pour une meilleure UX (1.5s - 2s)
5. **Feedback visuel** sur toutes les actions utilisateur

---

**Application développée pour Android** 📱
**Framework:** HTML5 + CSS3 + Vanilla JavaScript
**Date:** Octobre 2025
