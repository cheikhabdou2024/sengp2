-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM types
CREATE TYPE user_type AS ENUM ('expediteur', 'gp', 'admin');
CREATE TYPE user_status AS ENUM ('pending', 'verified', 'suspended', 'deleted');
CREATE TYPE trip_status AS ENUM ('draft', 'published', 'active', 'completed', 'cancelled');
CREATE TYPE mission_status AS ENUM ('pending', 'matched', 'accepted', 'picked_up', 'in_transit', 'in_customs', 'out_for_delivery', 'delivered', 'cancelled', 'disputed');
CREATE TYPE payment_method AS ENUM ('wave', 'orange_money', 'free_money', 'card', 'bank_transfer');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled');
CREATE TYPE transaction_type AS ENUM ('mission_payment', 'withdrawal', 'refund', 'commission', 'bonus');
CREATE TYPE withdrawal_status AS ENUM ('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled');
CREATE TYPE claim_type AS ENUM ('damaged_package', 'lost_package', 'delayed_delivery', 'wrong_delivery', 'tracking_issue', 'payment_issue', 'other');
CREATE TYPE claim_status AS ENUM ('open', 'in_progress', 'resolved', 'rejected', 'closed');
CREATE TYPE claim_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE notification_type AS ENUM ('mission_matched', 'mission_accepted', 'mission_pickup', 'mission_transit', 'mission_delivered', 'payment_received', 'claim_created', 'claim_resolved', 'review_received', 'account_verified', 'system_alert');

-- Table: users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type user_type NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    profile_photo_url VARCHAR(500),
    status user_status DEFAULT 'pending',
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    identity_document_type VARCHAR(50),
    identity_document_url VARCHAR(500),
    identity_verified_at TIMESTAMP,
    verified_by UUID REFERENCES users(id),
    country VARCHAR(100),
    city VARCHAR(100),
    address TEXT,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_rating CHECK (average_rating >= 0 AND average_rating <= 5)
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);

-- Table: gp_profiles
CREATE TABLE gp_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(255),
    license_number VARCHAR(100),
    license_document_url VARCHAR(500),
    total_missions_completed INTEGER DEFAULT 0,
    total_earnings DECIMAL(15,2) DEFAULT 0.00,
    success_rate DECIMAL(5,2) DEFAULT 0.00,
    is_available BOOLEAN DEFAULT TRUE,
    max_package_weight DECIMAL(8,2),
    available_space_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: expediteur_profiles
CREATE TABLE expediteur_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_shipments INTEGER DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0.00,
    preferred_payment_method VARCHAR(50),
    default_pickup_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: trips
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_code VARCHAR(50) UNIQUE NOT NULL,
    gp_id UUID NOT NULL REFERENCES users(id),
    departure_country VARCHAR(100) NOT NULL,
    departure_city VARCHAR(100) NOT NULL,
    departure_airport_code VARCHAR(10),
    arrival_country VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    arrival_airport_code VARCHAR(10),
    departure_date TIMESTAMP NOT NULL,
    arrival_date TIMESTAMP NOT NULL,
    flight_number VARCHAR(50),
    airline VARCHAR(100),
    available_weight DECIMAL(8,2) NOT NULL,
    max_packages INTEGER DEFAULT 3,
    current_packages INTEGER DEFAULT 0,
    status trip_status DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (departure_date < arrival_date)
);

CREATE INDEX idx_trips_gp ON trips(gp_id);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_departure ON trips(departure_date);
CREATE INDEX idx_trips_route ON trips(departure_city, arrival_city);

-- Table: missions
CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_code VARCHAR(50) UNIQUE NOT NULL,
    expediteur_id UUID NOT NULL REFERENCES users(id),
    gp_id UUID REFERENCES users(id),
    trip_id UUID REFERENCES trips(id),
    departure_country VARCHAR(100) NOT NULL,
    departure_city VARCHAR(100) NOT NULL,
    pickup_address TEXT NOT NULL,
    arrival_country VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    delivery_address TEXT NOT NULL,
    package_weight DECIMAL(8,2) NOT NULL,
    package_length DECIMAL(8,2),
    package_width DECIMAL(8,2),
    package_height DECIMAL(8,2),
    package_description TEXT,
    package_value DECIMAL(15,2),
    package_photos JSONB,
    desired_departure_date DATE NOT NULL,
    desired_arrival_date DATE,
    actual_pickup_date TIMESTAMP,
    actual_delivery_date TIMESTAMP,
    offered_price DECIMAL(15,2) NOT NULL,
    final_price DECIMAL(15,2),
    is_price_negotiable BOOLEAN DEFAULT FALSE,
    status mission_status DEFAULT 'pending',
    qr_code_url VARCHAR(500),
    qr_code_data TEXT,
    is_insured BOOLEAN DEFAULT TRUE,
    insurance_cost DECIMAL(10,2),
    tracking_number VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    CONSTRAINT check_weight CHECK (package_weight > 0),
    CONSTRAINT check_price CHECK (offered_price > 0)
);

CREATE INDEX idx_missions_expediteur ON missions(expediteur_id);
CREATE INDEX idx_missions_gp ON missions(gp_id);
CREATE INDEX idx_missions_trip ON missions(trip_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_tracking ON missions(tracking_number);
CREATE INDEX idx_missions_code ON missions(mission_code);

-- Table: mission_tracking
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

CREATE INDEX idx_tracking_mission ON mission_tracking(mission_id);
CREATE INDEX idx_tracking_created ON mission_tracking(created_at);

-- Table: payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_code VARCHAR(50) UNIQUE NOT NULL,
    mission_id UUID REFERENCES missions(id),
    payer_id UUID NOT NULL REFERENCES users(id),
    payee_id UUID REFERENCES users(id),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'FCFA',
    commission DECIMAL(15,2) DEFAULT 0.00,
    net_amount DECIMAL(15,2) NOT NULL,
    payment_method payment_method NOT NULL,
    payment_provider VARCHAR(100),
    external_transaction_id VARCHAR(255),
    external_reference VARCHAR(255),
    status payment_status DEFAULT 'pending',
    transaction_type transaction_type NOT NULL,
    payment_details JSONB,
    failure_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    completed_at TIMESTAMP,
    CONSTRAINT check_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_mission ON payments(mission_id);
CREATE INDEX idx_payments_payer ON payments(payer_id);
CREATE INDEX idx_payments_payee ON payments(payee_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_code ON payments(payment_code);

-- Table: withdrawals
CREATE TABLE withdrawals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    withdrawal_code VARCHAR(50) UNIQUE NOT NULL,
    gp_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'FCFA',
    withdrawal_method payment_method NOT NULL,
    account_number VARCHAR(255) NOT NULL,
    account_name VARCHAR(255),
    status withdrawal_status DEFAULT 'pending',
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    payment_id UUID REFERENCES payments(id),
    external_reference VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    completed_at TIMESTAMP,
    CONSTRAINT check_withdrawal_amount CHECK (amount > 0)
);

CREATE INDEX idx_withdrawals_gp ON withdrawals(gp_id);
CREATE INDEX idx_withdrawals_status ON withdrawals(status);

-- Table: claims
CREATE TABLE claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    claim_code VARCHAR(50) UNIQUE NOT NULL,
    mission_id UUID NOT NULL REFERENCES missions(id),
    claimant_id UUID NOT NULL REFERENCES users(id),
    claim_type claim_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    evidence_urls JSONB,
    status claim_status DEFAULT 'open',
    priority claim_priority DEFAULT 'medium',
    assigned_to UUID REFERENCES users(id),
    resolution TEXT,
    compensation_amount DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    response_deadline TIMESTAMP,
    resolution_deadline TIMESTAMP
);

CREATE INDEX idx_claims_mission ON claims(mission_id);
CREATE INDEX idx_claims_claimant ON claims(claimant_id);
CREATE INDEX idx_claims_status ON claims(status);
CREATE INDEX idx_claims_priority ON claims(priority);
CREATE INDEX idx_claims_assigned ON claims(assigned_to);

-- Table: reviews
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mission_id UUID NOT NULL REFERENCES missions(id),
    reviewer_id UUID NOT NULL REFERENCES users(id),
    reviewee_id UUID NOT NULL REFERENCES users(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_type VARCHAR(50) NOT NULL,
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    package_condition_rating INTEGER CHECK (package_condition_rating >= 1 AND package_condition_rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(mission_id, reviewer_id)
);

CREATE INDEX idx_reviews_mission ON reviews(mission_id);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);
CREATE INDEX idx_reviews_reviewee ON reviews(reviewee_id);

-- Table: notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500),
    metadata JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    sent_via_push BOOLEAN DEFAULT FALSE,
    sent_via_email BOOLEAN DEFAULT FALSE,
    sent_via_sms BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at);

-- Table: wallet_balances
CREATE TABLE wallet_balances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    available_balance DECIMAL(15,2) DEFAULT 0.00,
    pending_balance DECIMAL(15,2) DEFAULT 0.00,
    total_earned DECIMAL(15,2) DEFAULT 0.00,
    total_withdrawn DECIMAL(15,2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'FCFA',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_available_balance CHECK (available_balance >= 0),
    CONSTRAINT check_pending_balance CHECK (pending_balance >= 0)
);

-- Table: admin_logs
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_entity ON admin_logs(entity_type, entity_id);
CREATE INDEX idx_admin_logs_created ON admin_logs(created_at);

-- Create update trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gp_profiles_updated_at BEFORE UPDATE ON gp_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expediteur_profiles_updated_at BEFORE UPDATE ON expediteur_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trips_updated_at BEFORE UPDATE ON trips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_missions_updated_at BEFORE UPDATE ON missions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_claims_updated_at BEFORE UPDATE ON claims
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
