import rateLimit from 'express-rate-limit';

export class RateLimitMiddleware {
  /**
   * General API rate limiter
   * 100 requests per 15 minutes
   */
  static general = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    message: {
      success: false,
      error: 'Too many requests, please try again later',
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  /**
   * Auth rate limiter (stricter)
   * 5 requests per 15 minutes
   */
  static auth = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5,
    message: {
      success: false,
      error: 'Too many authentication attempts, please try again later',
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  /**
   * File upload rate limiter
   * 10 requests per hour
   */
  static upload = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 10,
    message: {
      success: false,
      error: 'Too many upload attempts, please try again later',
    },
    standardHeaders: true,
    legacyHeaders: false,
  });
}
