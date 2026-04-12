import { Queue } from 'bullmq';

import { queueName, redisConnection } from './config.js';
import type { TaskPayload } from './processor.js';

const main = async (): Promise<void> => {
  const queue = new Queue<TaskPayload>(queueName, {
    connection: redisConnection,
  });

  const job = await queue.add('task', {
    type: 'ping',
    data: {
      at: new Date().toISOString(),
    },
  });

  console.log(`[enqueue] queued id=${job.id} queue=${queueName}`);
  await queue.close();
};

main().catch((error: unknown) => {
  console.error('[enqueue] failed', error);
  process.exit(1);
});
