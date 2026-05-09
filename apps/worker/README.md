# @last-key/worker

BullMQ-based task worker app.

## Environment

Copy `.env.example` values into your preferred environment source.

- `BULLMQ_QUEUE_NAME` queue name to subscribe to
- `BULLMQ_WORKER_CONCURRENCY` concurrent jobs processed by this worker
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_DB`, `REDIS_USERNAME`, `REDIS_PASSWORD` Redis connection settings
- `REDIS_TLS` set to `true` to enable TLS

## Scripts

```bash
pnpm --filter @last-key/worker run dev
pnpm --filter @last-key/worker run build
pnpm --filter @last-key/worker run start
```

## Job Data Contract

The worker expects jobs with data shape:

```ts
type TaskPayload = {
  type: string;
  data?: Record<string, unknown>;
};
```

Out of the box, `type: "ping"` returns `pong` and all other types return a generic success response.
