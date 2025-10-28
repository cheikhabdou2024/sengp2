import { Router } from 'express';
import { AuthMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// All claim routes require authentication
router.use(AuthMiddleware.verifyToken);

// TODO: Implement claim routes
// GET / - List claims
// POST / - Create claim
// GET /:id - Get claim details
// PUT /:id - Update claim
// POST /:id/resolve - Resolve claim (admin)

export default router;
