# 🏗️ ARCHITECTURE BACKEND - SEN GP

## 📋 Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Stack Technologique](#stack-technologique)
3. [Architecture Système](#architecture-système)
4. [Base de Données](#base-de-données)
5. [APIs REST](#apis-rest)
6. [Services & Modules](#services--modules)
7. [Sécurité](#sécurité)
8. [Paiements & Transactions](#paiements--transactions)
9. [Notifications](#notifications)
10. [Déploiement](#déploiement)

---

## 🎯 Vue d'ensemble

### Entités Principales
- **Utilisateurs** : Expéditeurs, Gros Porteurs (GP), Administrateurs
- **Missions** : Colis à transporter
- **Trajets** : Voyages des GP
- **Paiements** : Transactions financières
- **Réclamations** : Support et litiges
- **Notifications** : Communication en temps réel

### Flux Métier Principal

```
1. Expéditeur crée une demande d'envoi
2. GP déclare un trajet
3. Matching automatique ou manuel
4. GP accepte la mission
5. Récupération du colis
6. Transport et suivi en temps réel
7. Livraison
8. Confirmation et paiement
9. Évaluation mutuelle
```

---

## 🛠️ Stack Technologique

### Backend
```yaml
Langage: Node.js (TypeScript)
Framework: Express.js ou NestJS
API: RESTful + GraphQL (optionnel)
Temps réel: Socket.io ou WebSockets
```

### Base de Données
```yaml
Base Principale: PostgreSQL
Cache: Redis
Recherche: Elasticsearch (optionnel)
Stockage Fichiers: AWS S3 / Cloudinary
```

### Infrastructure
```yaml
Cloud: AWS / Google Cloud / Azure
Conteneurisation: Docker
Orchestration: Kubernetes (production)
CI/CD: GitHub Actions / GitLab CI
```

### Services Tiers
```yaml
Paiements:
  - Wave API (Sénégal)
  - Orange Money API
  - Free Money API
  - Stripe (international)

SMS/Email:
  - Twilio
  - SendGrid

Géolocalisation:
  - Google Maps API
  - Mapbox

Stockage:
  - AWS S3
  - Cloudinary (images)
```

---

## 🏛️ Architecture Système

### Architecture Microservices (Recommandée)

```
┌─────────────────────────────────────────────────────────┐
│                    API GATEWAY                           │
│              (Kong / NGINX / AWS API Gateway)            │
└─────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Auth        │   │   Users       │   │   Missions    │
│   Service     │   │   Service     │   │   Service     │
└───────────────┘   └───────────────┘   └───────────────┘
        ↓                   ↓                   ↓
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Payments    │   │   Notifications│   │  Tracking     │
│   Service     │   │   Service      │   │  Service      │
└───────────────┘   └───────────────┘   └───────────────┘
        ↓                   ↓                   ↓
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Claims      │   │   Analytics   │   │   Admin       │
│   Service     │   │   Service     │   │   Service     │
└───────────────┘   └───────────────┘   └───────────────┘
                            ↓
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  PostgreSQL   │   │    Redis      │   │   AWS S3      │
│   Database    │   │    Cache      │   │   Storage     │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Architecture Monolithique Modulaire (Alternative)

```
┌─────────────────────────────────────────────────────────┐
│                   SEN GP API SERVER                      │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Auth    │  │  Users   │  │ Missions │             │
│  │  Module  │  │  Module  │  │  Module  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Payments │  │ Tracking │  │  Claims  │             │
│  │  Module  │  │  Module  │  │  Module  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Notif   │  │Analytics │  │  Admin   │             │
│  │  Module  │  │  Module  │  │  Module  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

---

## 💾 Base de Données

### Schéma PostgreSQL

#### Table: users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('expediteur', 'gp', 'admin') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    profile_photo_url VARCHAR(500),

    -- Statut du compte
    status ENUM('pending', 'verified', 'suspended', 'deleted') DEFAULT 'pending',
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,

    -- Vérification
    identity_document_type VARCHAR(50), -- CNI, Passeport, etc.
    identity_document_url VARCHAR(500),
    identity_verified_at TIMESTAMP,
    verified_by UUID REFERENCES users(id),

    -- Localisation
    country VARCHAR(100),
    city VARCHAR(100),
    address TEXT,

    -- Rating
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,

    -- Soft delete
    deleted_at TIMESTAMP,

    CONSTRAINT check_rating CHECK (average_rating >= 0 AND average_rating <= 5)
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);
```

#### Table: gp_profiles (Profil spécifique GP)
```sql
CREATE TABLE gp_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Informations professionnelles
    company_name VARCHAR(255),
    license_number VARCHAR(100),
    license_document_url VARCHAR(500),

    -- Statistiques
    total_missions_completed INTEGER DEFAULT 0,
    total_earnings DECIMAL(15,2) DEFAULT 0.00,
    success_rate DECIMAL(5,2) DEFAULT 0.00,

    -- Disponibilité
    is_available BOOLEAN DEFAULT TRUE,
    max_package_weight DECIMAL(8,2), -- en kg

    -- Capacité
    available_space_description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Table: expediteur_profiles (Profil spécifique Expéditeur)
```sql
CREATE TABLE expediteur_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Statistiques
    total_shipments INTEGER DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0.00,

    -- Préférences
    preferred_payment_method VARCHAR(50),
    default_pickup_address TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Table: trips (Trajets des GP)
```sql
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_code VARCHAR(50) UNIQUE NOT NULL, -- TRJ-2025-001
    gp_id UUID NOT NULL REFERENCES users(id),

    -- Itinéraire
    departure_country VARCHAR(100) NOT NULL,
    departure_city VARCHAR(100) NOT NULL,
    departure_airport_code VARCHAR(10),

    arrival_country VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    arrival_airport_code VARCHAR(10),

    -- Dates
    departure_date TIMESTAMP NOT NULL,
    arrival_date TIMESTAMP NOT NULL,

    -- Vol
    flight_number VARCHAR(50),
    airline VARCHAR(100),

    -- Capacité
    available_weight DECIMAL(8,2) NOT NULL, -- kg disponible
    max_packages INTEGER DEFAULT 3,
    current_packages INTEGER DEFAULT 0,

    -- Statut
    status ENUM('draft', 'published', 'active', 'completed', 'cancelled') DEFAULT 'draft',

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_dates CHECK (departure_date < arrival_date)
);

-- Indexes
CREATE INDEX idx_trips_gp ON trips(gp_id);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_departure ON trips(departure_date);
CREATE INDEX idx_trips_route ON trips(departure_city, arrival_city);
```

#### Table: missions
```sql
CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_code VARCHAR(50) UNIQUE NOT NULL, -- MIS-2025-001

    -- Acteurs
    expediteur_id UUID NOT NULL REFERENCES users(id),
    gp_id UUID REFERENCES users(id),
    trip_id UUID REFERENCES trips(id),

    -- Itinéraire
    departure_country VARCHAR(100) NOT NULL,
    departure_city VARCHAR(100) NOT NULL,
    pickup_address TEXT NOT NULL,

    arrival_country VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    delivery_address TEXT NOT NULL,

    -- Colis
    package_weight DECIMAL(8,2) NOT NULL,
    package_length DECIMAL(8,2),
    package_width DECIMAL(8,2),
    package_height DECIMAL(8,2),
    package_description TEXT,
    package_value DECIMAL(15,2), -- Valeur déclarée

    -- Photos
    package_photos JSONB, -- Array d'URLs

    -- Dates
    desired_departure_date DATE NOT NULL,
    desired_arrival_date DATE,
    actual_pickup_date TIMESTAMP,
    actual_delivery_date TIMESTAMP,

    -- Prix
    offered_price DECIMAL(15,2) NOT NULL,
    final_price DECIMAL(15,2),
    is_price_negotiable BOOLEAN DEFAULT FALSE,

    -- Statut
    status ENUM(
        'pending',        -- En attente de GP
        'matched',        -- GP trouvé
        'accepted',       -- GP a accepté
        'picked_up',      -- Colis récupéré
        'in_transit',     -- En transit
        'in_customs',     -- En douane
        'out_for_delivery', -- En livraison
        'delivered',      -- Livré
        'cancelled',      -- Annulé
        'disputed'        -- Litige
    ) DEFAULT 'pending',

    -- QR Code
    qr_code_url VARCHAR(500),
    qr_code_data TEXT,

    -- Assurance
    is_insured BOOLEAN DEFAULT TRUE,
    insurance_cost DECIMAL(10,2),

    -- Suivi
    tracking_number VARCHAR(100) UNIQUE,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,

    CONSTRAINT check_weight CHECK (package_weight > 0),
    CONSTRAINT check_price CHECK (offered_price > 0)
);

-- Indexes
CREATE INDEX idx_missions_expediteur ON missions(expediteur_id);
CREATE INDEX idx_missions_gp ON missions(gp_id);
CREATE INDEX idx_missions_trip ON missions(trip_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_tracking ON missions(tracking_number);
CREATE INDEX idx_missions_code ON missions(mission_code);
```

#### Table: mission_tracking (Suivi détaillé)
```sql
CREATE TABLE mission_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_id UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,

    status VARCHAR(50) NOT NULL,
    location VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    description TEXT,
    created_by UUID REFERENCES users(id),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_tracking_mission ON mission_tracking(mission_id);
CREATE INDEX idx_tracking_created ON mission_tracking(created_at);
```

#### Table: payments
```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_code VARCHAR(50) UNIQUE NOT NULL, -- PAY-2025-001

    -- Transaction
    mission_id UUID REFERENCES missions(id),
    payer_id UUID NOT NULL REFERENCES users(id),
    payee_id UUID REFERENCES users(id),

    -- Montants
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'FCFA',
    commission DECIMAL(15,2) DEFAULT 0.00, -- Commission SEN GP
    net_amount DECIMAL(15,2) NOT NULL, -- Montant après commission

    -- Méthode de paiement
    payment_method ENUM('wave', 'orange_money', 'free_money', 'card', 'bank_transfer') NOT NULL,
    payment_provider VARCHAR(100),

    -- Références externes
    external_transaction_id VARCHAR(255),
    external_reference VARCHAR(255),

    -- Statut
    status ENUM('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled') DEFAULT 'pending',

    -- Type
    transaction_type ENUM('mission_payment', 'withdrawal', 'refund', 'commission', 'bonus') NOT NULL,

    -- Métadonnées
    payment_details JSONB,
    failure_reason TEXT,

    -- Dates
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    completed_at TIMESTAMP,

    CONSTRAINT check_amount CHECK (amount > 0)
);

-- Indexes
CREATE INDEX idx_payments_mission ON payments(mission_id);
CREATE INDEX idx_payments_payer ON payments(payer_id);
CREATE INDEX idx_payments_payee ON payments(payee_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_code ON payments(payment_code);
```

#### Table: withdrawals (Retraits des GP)
```sql
CREATE TABLE withdrawals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    withdrawal_code VARCHAR(50) UNIQUE NOT NULL,

    gp_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'FCFA',

    -- Méthode
    withdrawal_method ENUM('wave', 'orange_money', 'free_money', 'bank_transfer') NOT NULL,
    account_number VARCHAR(255) NOT NULL,
    account_name VARCHAR(255),

    -- Statut
    status ENUM('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled') DEFAULT 'pending',

    -- Validation
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    rejection_reason TEXT,

    -- Transaction
    payment_id UUID REFERENCES payments(id),
    external_reference VARCHAR(255),

    -- Dates
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    completed_at TIMESTAMP,

    CONSTRAINT check_withdrawal_amount CHECK (amount > 0)
);

-- Indexes
CREATE INDEX idx_withdrawals_gp ON withdrawals(gp_id);
CREATE INDEX idx_withdrawals_status ON withdrawals(status);
```

#### Table: claims (Réclamations)
```sql
CREATE TABLE claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    claim_code VARCHAR(50) UNIQUE NOT NULL, -- REC-001

    mission_id UUID NOT NULL REFERENCES missions(id),
    claimant_id UUID NOT NULL REFERENCES users(id), -- Celui qui réclame

    -- Type de réclamation
    claim_type ENUM(
        'damaged_package',
        'lost_package',
        'delayed_delivery',
        'wrong_delivery',
        'tracking_issue',
        'payment_issue',
        'other'
    ) NOT NULL,

    -- Détails
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    evidence_urls JSONB, -- Photos, documents

    -- Statut
    status ENUM('open', 'in_progress', 'resolved', 'rejected', 'closed') DEFAULT 'open',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',

    -- Traitement
    assigned_to UUID REFERENCES users(id), -- Admin assigné
    resolution TEXT,
    compensation_amount DECIMAL(15,2),

    -- Dates
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,

    -- SLA
    response_deadline TIMESTAMP,
    resolution_deadline TIMESTAMP
);

-- Indexes
CREATE INDEX idx_claims_mission ON claims(mission_id);
CREATE INDEX idx_claims_claimant ON claims(claimant_id);
CREATE INDEX idx_claims_status ON claims(status);
CREATE INDEX idx_claims_priority ON claims(priority);
CREATE INDEX idx_claims_assigned ON claims(assigned_to);
```

#### Table: reviews (Évaluations)
```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_id UUID NOT NULL REFERENCES missions(id),

    reviewer_id UUID NOT NULL REFERENCES users(id), -- Qui note
    reviewee_id UUID NOT NULL REFERENCES users(id), -- Qui est noté

    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,

    -- Type d'évaluation
    review_type ENUM('expediteur_to_gp', 'gp_to_expediteur') NOT NULL,

    -- Critères détaillés (optionnel)
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    package_condition_rating INTEGER CHECK (package_condition_rating >= 1 AND package_condition_rating <= 5),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(mission_id, reviewer_id) -- Une seule review par mission et par reviewer
);

-- Indexes
CREATE INDEX idx_reviews_mission ON reviews(mission_id);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);
CREATE INDEX idx_reviews_reviewee ON reviews(reviewee_id);
```

#### Table: notifications
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Type de notification
    notification_type ENUM(
        'mission_matched',
        'mission_accepted',
        'mission_pickup',
        'mission_transit',
        'mission_delivered',
        'payment_received',
        'claim_created',
        'claim_resolved',
        'review_received',
        'account_verified',
        'system_alert'
    ) NOT NULL,

    -- Contenu
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500), -- Lien vers l'action

    -- Métadonnées
    metadata JSONB, -- Données additionnelles

    -- Statut
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,

    -- Canaux
    sent_via_push BOOLEAN DEFAULT FALSE,
    sent_via_email BOOLEAN DEFAULT FALSE,
    sent_via_sms BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at);
```

#### Table: wallet_balances (Portefeuille virtuel GP)
```sql
CREATE TABLE wallet_balances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    available_balance DECIMAL(15,2) DEFAULT 0.00,
    pending_balance DECIMAL(15,2) DEFAULT 0.00, -- En attente de validation
    total_earned DECIMAL(15,2) DEFAULT 0.00,
    total_withdrawn DECIMAL(15,2) DEFAULT 0.00,

    currency VARCHAR(10) DEFAULT 'FCFA',

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_available_balance CHECK (available_balance >= 0),
    CONSTRAINT check_pending_balance CHECK (pending_balance >= 0)
);
```

#### Table: admin_logs (Logs d'activité admin)
```sql
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES users(id),

    action VARCHAR(100) NOT NULL, -- 'user_verified', 'mission_approved', etc.
    entity_type VARCHAR(50) NOT NULL, -- 'user', 'mission', 'payment', etc.
    entity_id UUID,

    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,

    metadata JSONB,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index
CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_entity ON admin_logs(entity_type, entity_id);
CREATE INDEX idx_admin_logs_created ON admin_logs(created_at);
```

---

## 🔌 APIs REST

### Structure des Endpoints

```
/api/v1
  ├── /auth
  │   ├── POST   /register
  │   ├── POST   /login
  │   ├── POST   /logout
  │   ├── POST   /refresh-token
  │   ├── POST   /forgot-password
  │   ├── POST   /reset-password
  │   ├── POST   /verify-email
  │   └── POST   /verify-phone
  │
  ├── /users
  │   ├── GET    /me
  │   ├── PUT    /me
  │   ├── POST   /me/avatar
  │   ├── GET    /:id
  │   ├── PUT    /:id/verify
  │   └── DELETE /:id
  │
  ├── /expediteurs
  │   ├── GET    /profile
  │   ├── PUT    /profile
  │   └── GET    /stats
  │
  ├── /gp
  │   ├── GET    /profile
  │   ├── PUT    /profile
  │   ├── GET    /stats
  │   └── GET    /earnings
  │
  ├── /trips
  │   ├── GET    /               # Liste des trajets
  │   ├── POST   /               # Créer un trajet
  │   ├── GET    /:id            # Détails d'un trajet
  │   ├── PUT    /:id            # Modifier un trajet
  │   ├── DELETE /:id            # Annuler un trajet
  │   ├── GET    /my-trips       # Mes trajets
  │   └── GET    /search         # Rechercher trajets
  │
  ├── /missions
  │   ├── GET    /               # Liste des missions
  │   ├── POST   /               # Créer une mission
  │   ├── GET    /:id            # Détails d'une mission
  │   ├── PUT    /:id            # Modifier une mission
  │   ├── DELETE /:id            # Annuler une mission
  │   ├── POST   /:id/accept     # GP accepte mission
  │   ├── POST   /:id/pickup     # Marquer comme récupéré
  │   ├── POST   /:id/deliver    # Marquer comme livré
  │   ├── GET    /:id/tracking   # Suivi détaillé
  │   ├── POST   /:id/qr-code    # Générer QR code
  │   ├── GET    /search         # Rechercher missions
  │   ├── GET    /my-missions    # Mes missions
  │   └── POST   /match          # Matcher mission avec trajet
  │
  ├── /payments
  │   ├── GET    /               # Liste des paiements
  │   ├── POST   /               # Initier paiement
  │   ├── GET    /:id            # Détails paiement
  │   ├── POST   /webhook        # Webhook providers
  │   ├── GET    /methods        # Méthodes disponibles
  │   └── POST   /verify         # Vérifier paiement
  │
  ├── /withdrawals
  │   ├── GET    /               # Liste des retraits
  │   ├── POST   /               # Demander retrait
  │   ├── GET    /:id            # Détails retrait
  │   ├── POST   /:id/approve    # Approuver (admin)
  │   ├── POST   /:id/reject     # Rejeter (admin)
  │   └── GET    /pending        # Retraits en attente
  │
  ├── /claims
  │   ├── GET    /               # Liste des réclamations
  │   ├── POST   /               # Créer réclamation
  │   ├── GET    /:id            # Détails réclamation
  │   ├── PUT    /:id            # Modifier réclamation
  │   ├── POST   /:id/assign     # Assigner à admin
  │   ├── POST   /:id/resolve    # Résoudre
  │   └── POST   /:id/message    # Ajouter message
  │
  ├── /reviews
  │   ├── GET    /               # Liste des avis
  │   ├── POST   /               # Créer avis
  │   ├── GET    /:id            # Détails avis
  │   ├── GET    /user/:userId   # Avis d'un utilisateur
  │   └── GET    /mission/:missionId # Avis d'une mission
  │
  ├── /notifications
  │   ├── GET    /               # Mes notifications
  │   ├── PUT    /:id/read       # Marquer comme lu
  │   ├── PUT    /read-all       # Tout marquer lu
  │   ├── DELETE /:id            # Supprimer notification
  │   └── GET    /unread-count   # Nombre non lues
  │
  ├── /tracking
  │   ├── GET    /:trackingNumber # Suivre par numéro
  │   ├── POST   /qr-scan         # Scanner QR code
  │   └── GET    /mission/:id     # Historique complet
  │
  ├── /admin
  │   ├── /users
  │   │   ├── GET    /           # Tous les utilisateurs
  │   │   ├── GET    /:id        # Détails utilisateur
  │   │   ├── PUT    /:id        # Modifier utilisateur
  │   │   ├── POST   /:id/verify # Vérifier compte
  │   │   ├── POST   /:id/suspend # Suspendre compte
  │   │   └── DELETE /:id        # Supprimer compte
  │   │
  │   ├── /missions
  │   │   ├── GET    /           # Toutes les missions
  │   │   ├── GET    /:id        # Détails mission
  │   │   ├── POST   /:id/approve # Approuver mission
  │   │   └── POST   /:id/cancel  # Annuler mission
  │   │
  │   ├── /payments
  │   │   ├── GET    /           # Tous les paiements
  │   │   └── GET    /stats      # Statistiques paiements
  │   │
  │   ├── /claims
  │   │   ├── GET    /           # Toutes les réclamations
  │   │   └── GET    /urgent     # Réclamations urgentes
  │   │
  │   └── /stats
  │       ├── GET    /overview   # Vue d'ensemble
  │       ├── GET    /users      # Stats utilisateurs
  │       ├── GET    /missions   # Stats missions
  │       ├── GET    /revenue    # Stats revenus
  │       └── POST   /report     # Générer rapport
  │
  └── /health
      ├── GET    /               # Health check
      └── GET    /metrics        # Métriques système
```

### Exemples de Requêtes

#### 1. Créer une mission (Expéditeur)
```http
POST /api/v1/missions
Authorization: Bearer {token}
Content-Type: application/json

{
  "departure_country": "Sénégal",
  "departure_city": "Dakar",
  "pickup_address": "Rue 10, Almadies",
  "arrival_country": "France",
  "arrival_city": "Paris",
  "delivery_address": "15 Rue de la Paix, 75002 Paris",
  "package_weight": 3.5,
  "package_length": 30,
  "package_width": 25,
  "package_height": 15,
  "package_description": "Vêtements et documents",
  "package_value": 50000,
  "desired_departure_date": "2025-10-25",
  "offered_price": 65000,
  "is_price_negotiable": true
}
```

#### 2. GP accepte une mission
```http
POST /api/v1/missions/:missionId/accept
Authorization: Bearer {token}
Content-Type: application/json

{
  "trip_id": "uuid-du-trajet",
  "estimated_pickup_date": "2025-10-24T14:00:00Z",
  "estimated_delivery_date": "2025-10-26T10:00:00Z"
}
```

#### 3. Initier un paiement
```http
POST /api/v1/payments
Authorization: Bearer {token}
Content-Type: application/json

{
  "mission_id": "uuid-mission",
  "amount": 65000,
  "payment_method": "wave",
  "phone_number": "+221771234567"
}
```

#### 4. Créer une réclamation
```http
POST /api/v1/claims
Authorization: Bearer {token}
Content-Type: application/json

{
  "mission_id": "uuid-mission",
  "claim_type": "damaged_package",
  "title": "Colis endommagé à la réception",
  "description": "L'emballage était déchiré et certains articles sont cassés",
  "evidence_urls": [
    "https://s3.amazonaws.com/sengp/evidence/photo1.jpg",
    "https://s3.amazonaws.com/sengp/evidence/photo2.jpg"
  ],
  "priority": "high"
}
```

---

## ⚙️ Services & Modules

### 1. Auth Service
```typescript
// Responsabilités:
- Inscription (Expéditeur / GP)
- Connexion / Déconnexion
- Gestion des tokens JWT
- Refresh tokens
- Vérification email/téléphone
- Réinitialisation mot de passe
- OAuth social (Google, Facebook) - optionnel
```

### 2. User Service
```typescript
// Responsabilités:
- CRUD utilisateurs
- Gestion des profils
- Upload photos/documents
- Vérification d'identité
- Statistiques utilisateur
- Historique activités
```

### 3. Mission Service
```typescript
// Responsabilités:
- CRUD missions
- Matching missions ↔ trajets
- Workflow statuts
- Génération QR codes
- Calcul des prix
- Validation des données
- Algorithme de matching intelligent
```

### 4. Trip Service
```typescript
// Responsabilités:
- CRUD trajets
- Gestion capacités
- Publication trajets
- Recherche trajets disponibles
- Association missions ↔ trajets
```

### 5. Payment Service
```typescript
// Responsabilités:
- Intégration Wave API
- Intégration Orange Money
- Intégration Free Money
- Gestion webhooks
- Calcul commissions (ex: 10%)
- Remboursements
- Historique transactions
- Réconciliation bancaire
```

### 6. Withdrawal Service
```typescript
// Responsabilités:
- Demandes de retrait GP
- Validation des montants
- Workflow approbation
- Transferts vers comptes mobiles
- Suivi des retraits
```

### 7. Tracking Service
```typescript
// Responsabilités:
- Suivi temps réel
- Géolocalisation
- Historique positions
- Notifications automatiques
- Intégration Google Maps
- Estimation temps livraison
```

### 8. Notification Service
```typescript
// Responsabilités:
- Push notifications (FCM)
- Emails (SendGrid)
- SMS (Twilio)
- Notifications in-app
- Templates de messages
- Préférences utilisateur
```

### 9. Claim Service
```typescript
// Responsabilités:
- Gestion réclamations
- Workflow de traitement
- Attribution aux admins
- Système de priorités
- SLA monitoring
- Résolution et compensation
```

### 10. Review Service
```typescript
// Responsabilités:
- Création avis
- Calcul ratings moyens
- Modération commentaires
- Statistiques réputation
```

### 11. Analytics Service
```typescript
// Responsabilités:
- Collecte métriques
- Génération rapports
- Dashboard statistiques
- KPIs plateforme
- Analyses prédictives
```

### 12. Storage Service
```typescript
// Responsabilités:
- Upload fichiers S3
- Compression images
- Génération thumbnails
- CDN management
- Nettoyage fichiers obsolètes
```

---

## 🔐 Sécurité

### Authentification & Autorisation

```typescript
// JWT Structure
{
  "sub": "user-uuid",
  "email": "user@example.com",
  "role": "gp", // expediteur, gp, admin
  "iat": 1635789600,
  "exp": 1635876000
}

// Middleware d'autorisation
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('gp', 'admin')
async getGPStats() { ... }
```

### Sécurité des Données

1. **Encryption**
   - Mots de passe : bcrypt (12 rounds)
   - Données sensibles : AES-256
   - Communications : HTTPS/TLS 1.3

2. **Validation**
   - Validation inputs (Joi, class-validator)
   - Sanitization XSS
   - SQL injection prevention (ORM paramétrisé)
   - CSRF protection

3. **Rate Limiting**
   ```typescript
   // Login: 5 tentatives / 15 min
   // API: 100 requêtes / minute
   // Upload: 10 fichiers / heure
   ```

4. **Audit & Logs**
   - Tous les accès admin loggés
   - Tentatives de connexion suspectes
   - Modifications sensibles tracées
   - Retention logs : 90 jours

---

## 💳 Paiements & Transactions

### Flow Paiement Mission

```
1. Expéditeur crée mission
2. Système calcule prix total (mission + commission + assurance)
3. Expéditeur initie paiement
4. Redirection vers Wave/Orange Money/etc.
5. Provider traite paiement
6. Webhook confirmation reçu
7. Montant mis en escrow (compte séquestre)
8. GP livre le colis
9. Expéditeur confirme réception
10. Montant libéré vers GP (montant - commission)
11. Système génère reçu
```

### Calcul Commission

```typescript
interface PriceBreakdown {
  missionPrice: number;      // Prix de base
  platformCommission: number; // 10% du prix
  insuranceFee: number;      // 2% de la valeur déclarée
  totalPrice: number;        // Total à payer par expéditeur
  gpEarning: number;         // Ce que reçoit le GP
}

// Exemple:
// Mission: 65,000 FCFA
// Commission (10%): 6,500 FCFA
// Assurance (2% de 50,000): 1,000 FCFA
// Total expéditeur: 72,500 FCFA
// GP reçoit: 65,000 FCFA
// SEN GP garde: 7,500 FCFA
```

### Intégrations Providers

#### Wave API
```typescript
interface WavePaymentRequest {
  amount: number;
  currency: 'XOF'; // FCFA
  customer_phone: string;
  merchant_reference: string;
  callback_url: string;
}
```

#### Orange Money
```typescript
interface OrangeMoneyRequest {
  amount: number;
  currency: 'XOF';
  msisdn: string; // Numéro de téléphone
  reference: string;
  return_url: string;
}
```

---

## 🔔 Notifications

### Types de Notifications

```typescript
enum NotificationType {
  // Missions
  MISSION_MATCHED = 'mission_matched',
  MISSION_ACCEPTED = 'mission_accepted',
  MISSION_PICKUP = 'mission_pickup',
  MISSION_IN_TRANSIT = 'mission_transit',
  MISSION_DELIVERED = 'mission_delivered',

  // Paiements
  PAYMENT_RECEIVED = 'payment_received',
  PAYMENT_SENT = 'payment_sent',
  WITHDRAWAL_APPROVED = 'withdrawal_approved',

  // Réclamations
  CLAIM_CREATED = 'claim_created',
  CLAIM_RESOLVED = 'claim_resolved',

  // Système
  ACCOUNT_VERIFIED = 'account_verified',
  REVIEW_RECEIVED = 'review_received',
  SYSTEM_ALERT = 'system_alert'
}
```

### Canaux de Notification

1. **Push Notifications** (Firebase Cloud Messaging)
   - Instantanées
   - Événements critiques
   - Mises à jour statut

2. **Email** (SendGrid)
   - Confirmations
   - Récapitulatifs
   - Rapports

3. **SMS** (Twilio)
   - Codes de vérification
   - Alertes urgentes
   - Confirmations critiques

4. **In-App**
   - Toutes les notifications
   - Historique complet
   - Centre de notifications

---

## 🚀 Déploiement

### Infrastructure Recommandée (AWS)

```yaml
Production:
  - EC2 / ECS Fargate: Application servers
  - RDS PostgreSQL: Database (Multi-AZ)
  - ElastiCache Redis: Caching & sessions
  - S3: File storage
  - CloudFront: CDN
  - Route 53: DNS
  - ELB: Load balancer
  - CloudWatch: Monitoring
  - SNS/SQS: Message queues
  - Lambda: Background jobs

Staging:
  - Configuration similaire mais scaled down
  - Base de données isolée

Development:
  - Docker Compose local
  - PostgreSQL local
  - Redis local
```

### CI/CD Pipeline

```yaml
GitHub Actions:

  on_push_to_develop:
    - Run tests
    - Run linter
    - Build Docker image
    - Deploy to Staging
    - Run integration tests

  on_push_to_main:
    - Run full test suite
    - Security scan
    - Build production image
    - Deploy to Production
    - Run smoke tests
    - Notify team
```

### Environnements

```
Development → Staging → Production

- Development: Développement local
- Staging: Tests avant prod (clone de prod)
- Production: Environnement live
```

### Monitoring & Alertes

```yaml
Metrics:
  - CPU/Memory usage
  - Request latency
  - Error rates
  - Database performance
  - API response times

Logs:
  - Application logs (Winston)
  - Access logs
  - Error logs
  - Audit logs

Alerting:
  - Slack notifications
  - Email alerts
  - PagerDuty (incidents critiques)
```

---

## 📊 Performance & Scalabilité

### Optimisations

1. **Database**
   - Indexes appropriés
   - Connection pooling
   - Query optimization
   - Read replicas pour scaling lecture

2. **Caching**
   - Redis pour sessions
   - Cache des profils utilisateurs
   - Cache des trajets populaires
   - CDN pour assets statiques

3. **API**
   - Pagination (limit/offset)
   - Compression gzip
   - Rate limiting
   - API versioning

4. **Background Jobs**
   - Queue pour emails
   - Queue pour notifications
   - Cron jobs pour rapports
   - Async processing pour uploads

---

## 🧪 Tests

### Stratégie de Tests

```typescript
1. Unit Tests
   - Services
   - Helpers
   - Utilities
   - Coverage > 80%

2. Integration Tests
   - API endpoints
   - Database operations
   - External services (mocked)

3. E2E Tests
   - User flows complets
   - Critical paths
   - Payment flows

4. Load Tests
   - Performance testing
   - Stress testing
   - Scalability testing
```

---

## 📝 Documentation API

### Tools
- **Swagger/OpenAPI**: Documentation interactive
- **Postman Collections**: Collection de requêtes
- **README détaillé**: Setup et architecture

---

## 🔄 Webhooks

### Webhooks Sortants
```typescript
// Notifier partenaires externes
POST https://partner.com/webhook
{
  "event": "mission.completed",
  "mission_id": "uuid",
  "timestamp": "2025-10-21T10:00:00Z",
  "data": { ... }
}
```

### Webhooks Entrants
```typescript
// Recevoir notifications providers de paiement
POST /api/v1/payments/webhook/wave
POST /api/v1/payments/webhook/orange-money
POST /api/v1/payments/webhook/stripe
```

---

## 🎯 Recommandations Finales

### Phase 1 (MVP - 2-3 mois)
- ✅ Auth & Users
- ✅ Missions (CRUD basique)
- ✅ Paiements Wave/Orange Money
- ✅ Notifications basiques
- ✅ Admin dashboard simple

### Phase 2 (3-4 mois)
- ✅ Trajets GP
- ✅ Matching intelligent
- ✅ Tracking temps réel
- ✅ Réclamations
- ✅ Reviews

### Phase 3 (4-6 mois)
- ✅ Analytics avancés
- ✅ App mobile native
- ✅ Optimisations performance
- ✅ Features premium
- ✅ Expansion internationale

---

## 📞 Support & Maintenance

### Équipe Recommandée
```
- 2 Backend Developers
- 1 Frontend Developer
- 1 Mobile Developer
- 1 DevOps Engineer
- 1 QA Engineer
- 1 Product Manager
```

### Budget Infrastructure (Estimé/Mois)
```
- Hosting (AWS): $300-500
- Databases: $200-300
- CDN & Storage: $50-100
- SMS/Email: $100-200
- Monitoring: $50-100
- Total: ~$700-1200/mois
```

---

**🎉 Cette architecture est prête pour un déploiement en production et peut supporter des milliers d'utilisateurs simultanés !**
