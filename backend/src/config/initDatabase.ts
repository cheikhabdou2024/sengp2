import pool from './database';
import logger from '../utils/logger';
import fs from 'fs';
import path from 'path';

/**
 * Initialize database tables if they don't exist
 */
export async function initDatabase(): Promise<void> {
  try {
    // Check if tables exist
    const result = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'users'
      );
    `);

    const tablesExist = result.rows[0].exists;

    if (!tablesExist) {
      logger.info('📊 Tables not found. Creating database schema...');

      // Read SQL migration file
      const sqlPath = path.join(__dirname, '../migrations/001_initial_schema.sql');
      const sql = fs.readFileSync(sqlPath, 'utf8');

      // Execute SQL
      await pool.query(sql);

      logger.info('✅ Database schema created successfully!');
    } else {
      logger.info('✅ Database tables already exist');
    }
  } catch (error) {
    logger.error('❌ Error initializing database:', error);

    // Don't throw error, just log it
    // The app can still start, migrations can be run manually
    logger.warn('⚠️  Please run migrations manually:');
    logger.warn('   sudo -u postgres psql -d sengp_db -f backend/src/migrations/001_initial_schema.sql');
  }
}
