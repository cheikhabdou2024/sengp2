import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/database';
import { User, UserType, TokenPayload } from '../types';
import { Helpers } from '../utils/helpers';
import logger from '../utils/logger';

export class AuthService {
  /**
   * Register a new user
   */
  static async register(data: {
    email: string;
    phone: string;
    password: string;
    user_type: UserType;
    first_name: string;
    last_name: string;
    country?: string;
    city?: string;
  }): Promise<{ user: Partial<User>; token: string }> {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // Check if email already exists
      const emailCheck = await client.query(
        'SELECT id FROM users WHERE email = $1',
        [data.email]
      );

      if (emailCheck.rows.length > 0) {
        throw new Error('Email already registered');
      }

      // Check if phone already exists
      const phoneCheck = await client.query(
        'SELECT id FROM users WHERE phone = $1',
        [data.phone]
      );

      if (phoneCheck.rows.length > 0) {
        throw new Error('Phone number already registered');
      }

      // Hash password
      const saltRounds = parseInt(process.env.BCRYPT_ROUNDS || '12');
      const password_hash = await bcrypt.hash(data.password, saltRounds);

      // Insert user
      const userResult = await client.query(
        `INSERT INTO users (
          email, phone, password_hash, user_type, first_name, last_name, country, city
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, email, phone, user_type, first_name, last_name, country, city, status, created_at`,
        [
          data.email,
          data.phone,
          password_hash,
          data.user_type,
          data.first_name,
          data.last_name,
          data.country,
          data.city,
        ]
      );

      const user = userResult.rows[0];

      // Create profile based on user type
      if (data.user_type === UserType.GP) {
        await client.query(
          'INSERT INTO gp_profiles (user_id) VALUES ($1)',
          [user.id]
        );
        await client.query(
          'INSERT INTO wallet_balances (user_id) VALUES ($1)',
          [user.id]
        );
      } else if (data.user_type === UserType.EXPEDITEUR) {
        await client.query(
          'INSERT INTO expediteur_profiles (user_id) VALUES ($1)',
          [user.id]
        );
      }

      await client.query('COMMIT');

      // Generate JWT token
      const token = this.generateToken(user);

      logger.info(`New user registered: ${user.email} (${user.user_type})`);

      return { user, token };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Login user
   */
  static async login(data: {
    email: string;
    password: string;
  }): Promise<{ user: Partial<User>; token: string }> {
    const result = await pool.query(
      `SELECT id, email, phone, password_hash, user_type, first_name, last_name,
              status, is_email_verified, is_phone_verified, profile_photo_url
       FROM users WHERE email = $1 AND deleted_at IS NULL`,
      [data.email]
    );

    if (result.rows.length === 0) {
      throw new Error('Invalid credentials');
    }

    const user = result.rows[0];

    // Check if user is suspended
    if (user.status === 'suspended') {
      throw new Error('Account is suspended');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(data.password, user.password_hash);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    // Update last login
    await pool.query(
      'UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE id = $1',
      [user.id]
    );

    // Remove password from response
    delete user.password_hash;

    // Generate JWT token
    const token = this.generateToken(user);

    logger.info(`User logged in: ${user.email}`);

    return { user, token };
  }

  /**
   * Generate JWT token
   */
  private static generateToken(user: Partial<User>): string {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      throw new Error('JWT_SECRET is not defined');
    }

    const payload = {
      sub: user.id!,
      email: user.email!,
      role: user.user_type!,
    };

    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    return jwt.sign(payload, secret, { expiresIn } as jwt.SignOptions);
  }

  /**
   * Verify email
   */
  static async verifyEmail(userId: string): Promise<void> {
    await pool.query(
      'UPDATE users SET is_email_verified = TRUE WHERE id = $1',
      [userId]
    );
    logger.info(`Email verified for user: ${userId}`);
  }

  /**
   * Verify phone
   */
  static async verifyPhone(userId: string): Promise<void> {
    await pool.query(
      'UPDATE users SET is_phone_verified = TRUE WHERE id = $1',
      [userId]
    );
    logger.info(`Phone verified for user: ${userId}`);
  }

  /**
   * Change password
   */
  static async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string
  ): Promise<void> {
    const result = await pool.query(
      'SELECT password_hash FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      throw new Error('User not found');
    }

    const user = result.rows[0];

    // Verify old password
    const isPasswordValid = await bcrypt.compare(oldPassword, user.password_hash);
    if (!isPasswordValid) {
      throw new Error('Invalid current password');
    }

    // Hash new password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS || '12');
    const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2',
      [newPasswordHash, userId]
    );

    logger.info(`Password changed for user: ${userId}`);
  }

  /**
   * Request password reset
   */
  static async requestPasswordReset(email: string): Promise<string> {
    const result = await pool.query(
      'SELECT id, first_name FROM users WHERE email = $1 AND deleted_at IS NULL',
      [email]
    );

    if (result.rows.length === 0) {
      // Don't reveal if email exists
      return 'If the email exists, a reset link will be sent';
    }

    const user = result.rows[0];

    // Generate reset token (valid for 1 hour)
    const resetToken = Helpers.generateVerificationCode(6);

    // TODO: Store reset token in Redis with expiration
    // TODO: Send reset email

    logger.info(`Password reset requested for: ${email}`);

    return resetToken; // In production, don't return this
  }
}
