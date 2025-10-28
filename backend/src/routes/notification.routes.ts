import { Router } from 'express';
import { AuthMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// All notification routes require authentication
router.use(AuthMiddleware.verifyToken);

// TODO: Implement notification routes
// GET / - Get user's notifications
// PUT /:id/read - Mark as read
// PUT /read-all - Mark all as read
// DELETE /:id - Delete notification
// GET /unread-count - Get unread count

export default router;
