import { Router } from 'express';
import { AuthMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// All trip routes require authentication
router.use(AuthMiddleware.verifyToken);

// TODO: Implement trip routes
// GET / - List trips
// POST / - Create trip (GP only)
// GET /:id - Get trip by ID
// PUT /:id - Update trip
// DELETE /:id - Cancel trip
// GET /search - Search trips

export default router;
