import { Response } from 'express';
import { MissionService } from '../services/mission.service';
import { ResponseUtil } from '../utils/response';
import { AuthRequest, UserType } from '../types';
import logger from '../utils/logger';

export class MissionController {
  /**
   * Create new mission
   * POST /api/v1/missions
   */
  static async create(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        ResponseUtil.unauthorized(res);
        return;
      }

      if (req.user.user_type !== UserType.EXPEDITEUR) {
        ResponseUtil.forbidden(res, 'Only expediteurs can create missions');
        return;
      }

      const mission = await MissionService.create(req.body, req.user.id);

      ResponseUtil.created(res, mission, 'Mission created successfully');
    } catch (error: any) {
      logger.error('Mission creation error:', error);
      ResponseUtil.badRequest(res, error.message || 'Mission creation failed');
    }
  }

  /**
   * Get mission by ID
   * GET /api/v1/missions/:id
   */
  static async getById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const mission = await MissionService.getById(req.params.id);

      if (!mission) {
        ResponseUtil.notFound(res, 'Mission not found');
        return;
      }

      ResponseUtil.success(res, mission);
    } catch (error: any) {
      logger.error('Get mission error:', error);
      ResponseUtil.badRequest(res, error.message || 'Failed to get mission');
    }
  }

  /**
   * Get all missions with filters
   * GET /api/v1/missions
   */
  static async getAll(req: AuthRequest, res: Response): Promise<void> {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const status = req.query.status as any;
      const departure_city = req.query.departure_city as string;
      const arrival_city = req.query.arrival_city as string;

      const result = await MissionService.getAll({
        page,
        limit,
        status,
        departure_city,
        arrival_city,
      });

      ResponseUtil.success(res, result.data, undefined, result.pagination);
    } catch (error: any) {
      logger.error('Get missions error:', error);
      ResponseUtil.badRequest(res, error.message || 'Failed to get missions');
    }
  }

  /**
   * Get user's missions
   * GET /api/v1/missions/my-missions
   */
  static async getMyMissions(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        ResponseUtil.unauthorized(res);
        return;
      }

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const status = req.query.status as any;

      const filters: any = { page, limit, status };

      if (req.user.user_type === UserType.EXPEDITEUR) {
        filters.expediteur_id = req.user.id;
      } else if (req.user.user_type === UserType.GP) {
        filters.gp_id = req.user.id;
      } else {
        ResponseUtil.forbidden(res, 'Invalid user type');
        return;
      }

      const result = await MissionService.getAll(filters);

      ResponseUtil.success(res, result.data, undefined, result.pagination);
    } catch (error: any) {
      logger.error('Get my missions error:', error);
      ResponseUtil.badRequest(res, error.message || 'Failed to get missions');
    }
  }

  /**
   * Update mission
   * PUT /api/v1/missions/:id
   */
  static async update(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        ResponseUtil.unauthorized(res);
        return;
      }

      const mission = await MissionService.update(req.params.id, req.body);

      ResponseUtil.success(res, mission, 'Mission updated successfully');
    } catch (error: any) {
      logger.error('Update mission error:', error);

      if (error.message === 'Mission not found') {
        ResponseUtil.notFound(res, error.message);
        return;
      }

      ResponseUtil.badRequest(res, error.message || 'Update failed');
    }
  }

  /**
   * Accept mission (GP)
   * POST /api/v1/missions/:id/accept
   */
  static async accept(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        ResponseUtil.unauthorized(res);
        return;
      }

      if (req.user.user_type !== UserType.GP) {
        ResponseUtil.forbidden(res, 'Only GPs can accept missions');
        return;
      }

      const { trip_id } = req.body;
      const mission = await MissionService.accept(req.params.id, req.user.id, trip_id);

      ResponseUtil.success(res, mission, 'Mission accepted successfully');
    } catch (error: any) {
      logger.error('Accept mission error:', error);

      if (error.message.includes('not available')) {
        ResponseUtil.conflict(res, error.message);
        return;
      }

      ResponseUtil.badRequest(res, error.message || 'Accept failed');
    }
  }

  /**
   * Update mission status
   * POST /api/v1/missions/:id/status
   */
  static async updateStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        ResponseUtil.unauthorized(res);
        return;
      }

      const { status } = req.body;
      const mission = await MissionService.updateStatus(
        req.params.id,
        status,
        req.user.id
      );

      ResponseUtil.success(res, mission, 'Status updated successfully');
    } catch (error: any) {
      logger.error('Update status error:', error);
      ResponseUtil.badRequest(res, error.message || 'Status update failed');
    }
  }

  /**
   * Generate QR Code
   * POST /api/v1/missions/:id/qr-code
   */
  static async generateQRCode(req: AuthRequest, res: Response): Promise<void> {
    try {
      const qrCodeUrl = await MissionService.generateQRCode(req.params.id);

      ResponseUtil.success(res, { qr_code_url: qrCodeUrl }, 'QR Code generated');
    } catch (error: any) {
      logger.error('Generate QR code error:', error);
      ResponseUtil.badRequest(res, error.message || 'QR Code generation failed');
    }
  }

  /**
   * Get tracking history
   * GET /api/v1/missions/:id/tracking
   */
  static async getTracking(req: AuthRequest, res: Response): Promise<void> {
    try {
      const tracking = await MissionService.getTrackingHistory(req.params.id);

      ResponseUtil.success(res, tracking);
    } catch (error: any) {
      logger.error('Get tracking error:', error);
      ResponseUtil.badRequest(res, error.message || 'Failed to get tracking');
    }
  }

  /**
   * Track by tracking number
   * GET /api/v1/tracking/:trackingNumber
   */
  static async trackByNumber(req: AuthRequest, res: Response): Promise<void> {
    try {
      const result = await MissionService.trackByNumber(req.params.trackingNumber);

      if (!result) {
        ResponseUtil.notFound(res, 'Tracking number not found');
        return;
      }

      ResponseUtil.success(res, result);
    } catch (error: any) {
      logger.error('Track by number error:', error);
      ResponseUtil.badRequest(res, error.message || 'Tracking failed');
    }
  }
}
