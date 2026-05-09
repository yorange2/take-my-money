# Multi-stage build for BullMQ worker
FROM node:25-alpine AS base
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# Stage 1: Install dependencies
FROM base AS dependencies
COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./
COPY apps/worker/package.json ./apps/worker/
COPY packages/dal/package.json ./packages/dal/
COPY apps/web/package.json ./apps/web/
RUN pnpm install --frozen-lockfile

# Stage 2: Build
FROM base AS builder
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=dependencies /app/apps/worker/node_modules ./apps/worker/node_modules
COPY --from=dependencies /app/packages/dal/node_modules ./packages/dal/node_modules
COPY . .
RUN pnpm --filter @last-key/worker run build

# Stage 3: Runtime
FROM node:25-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production

RUN corepack enable && corepack prepare pnpm@latest --activate

COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./
COPY apps/worker/package.json ./apps/worker/
COPY packages/dal/package.json ./packages/dal/
RUN pnpm install --frozen-lockfile --prod --filter @last-key/worker

COPY --from=builder /app/apps/worker/dist ./apps/worker/dist
COPY --from=builder /app/packages/dal/dist ./packages/dal/dist

RUN addgroup -g 1001 -S nodejs && adduser -S worker -u 1001
USER worker

WORKDIR /app/apps/worker
CMD ["node", "dist/index.js"]
