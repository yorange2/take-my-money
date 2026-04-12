import type { ConnectionOptions } from 'bullmq';

const parsePort = (value: string | undefined, fallback: number): number => {
  if (!value) {
    return fallback;
  }

  const parsed = Number.parseInt(value, 10);
  return Number.isNaN(parsed) ? fallback : parsed;
};

const parseBool = (value: string | undefined): boolean => {
  if (!value) {
    return false;
  }

  return ['1', 'true', 'yes', 'on'].includes(value.toLowerCase());
};

export const queueName = process.env.BULLMQ_QUEUE_NAME ?? 'task-queue';

export const workerConcurrency = parsePort(
  process.env.BULLMQ_WORKER_CONCURRENCY,
  5
);

export const redisConnection: ConnectionOptions = {
  host: process.env.REDIS_HOST ?? '127.0.0.1',
  port: parsePort(process.env.REDIS_PORT, 6379),
  username: process.env.REDIS_USERNAME,
  password: process.env.REDIS_PASSWORD,
  db: parsePort(process.env.REDIS_DB, 0),
  maxRetriesPerRequest: null,
  tls: parseBool(process.env.REDIS_TLS) ? {} : undefined,
};
