import type { Job } from 'bullmq';

export type TaskPayload = {
  type: string;
  data?: Record<string, unknown>;
};

export const processTask = async (job: Job<TaskPayload>): Promise<unknown> => {
  switch (job.data.type) {
    case 'ping':
      return { ok: true, message: 'pong' };
    default:
      // Placeholder behavior so the worker is useful before app-specific tasks are added.
      return {
        ok: true,
        message: `Processed task type: ${job.data.type}`,
        data: job.data.data ?? null,
      };
  }
};
