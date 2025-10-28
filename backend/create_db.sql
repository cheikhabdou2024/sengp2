-- Créer la base de données SEN GP
CREATE DATABASE sengp_db
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Message de confirmation
SELECT 'Base de données sengp_db créée avec succès!' as message;
