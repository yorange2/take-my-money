# Multi-stage build for Next.js application
# Stage 1: Dependencies
FROM node:25-alpine AS dependencies
WORKDIR /app

# Copy package files
COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./

# Install pnpm
RUN npm install -g pnpm@latest

# Install dependencies
RUN pnpm install --frozen-lockfile

# Stage 2: Builder
FROM node:25-alpine AS builder
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@latest

# Copy dependencies from previous stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy entire project
COPY . .

# Build the app and shared lib
RUN pnpm build

# Stage 3: Runtime
FROM node:25-alpine AS runtime
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@latest

# Install only production dependencies
ENV NODE_ENV=production
COPY pnpm-lock.yaml package.json pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --prod

# Copy built app from builder
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/web/.next ./apps/web/.next
COPY --from=builder /app/apps/web/public ./apps/web/public
COPY --from=builder /app/apps/web/package.json ./apps/web/package.json
COPY --from=builder /app/apps/web/next.config.mjs ./apps/web/next.config.mjs
COPY --from=builder /app/apps/web/tsconfig.json ./apps/web/tsconfig.json

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
USER nextjs

# Expose port (Next.js default)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start the application
WORKDIR /app/apps/web
CMD ["pnpm", "start"]
