import { Worker } from 'bullmq';

import { queueName, redisConnection, workerConcurrency } from './config.js';
import { processTask, type TaskPayload } from './processor.js';

const worker = new Worker<TaskPayload>(queueName, processTask, {
  connection: redisConnection,
  concurrency: workerConcurrency,
});

worker.on('ready', () => {
  console.log(
    `[worker] ready queue=${queueName} concurrency=${workerConcurrency}`
  );
});

worker.on('active', (job) => {
  console.log(`[worker] started id=${job.id} name=${job.name}`);
});

worker.on('completed', (job, result) => {
  console.log(
    `[worker] completed id=${job.id} result=${JSON.stringify(result)}`
  );
});

worker.on('failed', (job, error) => {
  const id = job?.id ?? 'unknown';
  console.error(`[worker] failed id=${id} error=${error.message}`);
});

const shutdown = async (signal: string): Promise<void> => {
  console.log(`[worker] received ${signal}, shutting down`);
  await worker.close();
  process.exit(0);
};

process.on('SIGINT', () => {
  void shutdown('SIGINT');
});

process.on('SIGTERM', () => {
  void shutdown('SIGTERM');
});
