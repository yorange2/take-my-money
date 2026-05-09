# Development Guide

Complete guide for local development setup, daily workflow, and troubleshooting.

## Quick Start (First Time)

```bash
# 1. Setup local services (PostgreSQL + Redis with Podman)
pnpm setup:dev

# 2. Install dependencies
pnpm install

# 3. Start development servers
pnpm dev
```

Done! Services run at:

- **PostgreSQL**: localhost:5432 (user: dev, password: dev_password)
- **Redis**: localhost:6379 (password: redis_password)

## Prerequisites

### Install Podman

**macOS:**

```bash
brew install podman
podman machine start
```

**Linux:**

```bash
# Ubuntu/Debian
sudo apt-get install podman

# Fedora
sudo dnf install podman
```

**Windows:**

```bash
# Use WSL2 and install in Ubuntu
# Or download Podman Desktop from https://podman.io
```

### Install podman-compose

```bash
pip install podman-compose
# or with pip3
pip3 install podman-compose
```

## Setup Options

### Option 1: Automated Setup (Recommended)

```bash
pnpm setup:dev
```

This script:

- ✅ Checks Podman installation
- ✅ Creates `.env.local` from template
- ✅ Starts PostgreSQL and Redis containers
- ✅ Waits for services to be ready
- ✅ Displays connection information

### Option 2: Manual Setup

```bash
# Copy environment template
cp .env.local.example .env.local

# Start services
podman-compose -f podman-compose.yml up -d

# Verify services are running
pnpm services:ps
```

## Daily Development

### Start Everything

```bash
# Services already running? Just start dev server
pnpm dev

# Services stopped? Start them first
pnpm services:start
pnpm dev

# Or both in one go (open two terminals)
# Terminal 1:
pnpm services:start

# Terminal 2:
pnpm dev
```

### Service Management

```bash
pnpm services:start      # Start PostgreSQL & Redis
pnpm services:stop       # Stop services
pnpm services:restart    # Restart services
pnpm services:ps         # View service status
pnpm services:logs       # View all logs
pnpm services:logs postgres    # View PostgreSQL logs
pnpm services:logs redis       # View Redis logs
```

### Database Access

```bash
# Connect to PostgreSQL shell
pnpm db:shell

# Or direct psql command
psql -h localhost -U dev -d take_my_money

# Run migrations
psql -h localhost -U dev -d take_my_money < db/migrations/001_init.sql
```

### Redis Access

```bash
# Connect to Redis CLI
pnpm redis:cli

# Or direct redis-cli command
redis-cli -h localhost -p 6379 -a redis_password

# Example commands
SET mykey "Hello"
GET mykey
FLUSHDB  # clear all data
```

### Code Quality

```bash
pnpm lint          # Check code quality
pnpm lint:fix      # Auto-fix lint & format issues
pnpm format        # Format with Prettier only
```

### Building & Deployment

```bash
pnpm build         # Build all packages
pnpm test          # Run tests
```

## Environment Configuration

### Setup .env.local

```bash
# Copy from template
cp .env.local.example .env.local

# Edit as needed
nano .env.local  # or your editor
```

### Default Local Values

```env
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
REDIS_URL=redis://:redis_password@localhost:6379
NODE_ENV=development
NEXT_PUBLIC_APP_NAME=LastKey
NEXT_PUBLIC_API_URL=http://localhost:3000
```

### Database Connection

```env
DB_USER=dev
DB_PASSWORD=dev_password
DB_NAME=take_my_money
DB_PORT=5432
DB_HOST=localhost
```

### Redis Connection

```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis_password
```

## Service Details

### PostgreSQL

**Connection Details:**

- Host: `localhost`
- Port: `5432`
- Username: `dev`
- Password: `dev_password`
- Database: `take_my_money`

**Connection URL:**

```
postgresql://dev:dev_password@localhost:5432/take_my_money
```

### Redis

**Connection Details:**

- Host: `localhost`
- Port: `6379`
- Password: `redis_password`

**Connection URL:**

```
redis://:redis_password@localhost:6379
```

## Data Persistence

- **PostgreSQL data** → `postgres_data` volume
- **Redis data** → `redis_data` volume
- Both survive container restarts

To completely remove data:

```bash
./scripts/dev.sh clean
```

## Command Reference

| Command                 | Purpose                   |
| ----------------------- | ------------------------- |
| `pnpm setup:dev`        | Initial environment setup |
| `pnpm dev`              | Start development servers |
| `pnpm services:start`   | Start PostgreSQL & Redis  |
| `pnpm services:stop`    | Stop services             |
| `pnpm services:restart` | Restart services          |
| `pnpm services:ps`      | View service status       |
| `pnpm services:logs`    | View service logs         |
| `pnpm db:shell`         | Connect to PostgreSQL     |
| `pnpm redis:cli`        | Connect to Redis          |
| `pnpm lint`             | Check code quality        |
| `pnpm lint:fix`         | Fix lint/format issues    |
| `pnpm format`           | Format code               |
| `pnpm build`            | Build all packages        |
| `pnpm test`             | Run tests                 |

## Troubleshooting

### Services Won't Start

```bash
# Check if Podman is running
podman ps

# View service logs
pnpm services:logs

# Try restarting
pnpm services:restart

# Last resort: clean and restart
./scripts/dev.sh clean
pnpm services:start
```

### Port Already in Use

Edit `podman-compose.yml` to use different ports:

```yaml
postgres:
  ports:
    - '5433:5432' # Use 5433 instead of 5432

redis:
  ports:
    - '6380:6379' # Use 6380 instead of 6379
```

Then update `.env.local`:

```env
DB_PORT=5433
REDIS_PORT=6380
DATABASE_URL=postgresql://dev:dev_password@localhost:5433/take_my_money
REDIS_URL=redis://:redis_password@localhost:6380
```

### Container Won't Start

```bash
# View logs for specific service
pnpm services:logs postgres
pnpm services:logs redis

# Check if service is healthy
podman-compose -f podman-compose.yml exec postgres pg_isready -U dev
podman-compose -f podman-compose.yml exec redis redis-cli -a redis_password ping

# Try restarting
pnpm services:restart
```

### Cannot Connect to Database

```bash
# Verify service is running
pnpm services:ps

# Try connecting directly
pnpm db:shell

# Check PostgreSQL is ready
pg_isready -h localhost -U dev

# Check logs
pnpm services:logs postgres
```

### Cannot Find Podman

On Linux, start the Podman socket:

```bash
# Start socket service
systemctl --user start podman.socket

# Or enable to auto-start
systemctl --user enable podman.socket
```

### Podman Registry Error

If you get "short-name did not resolve" error:

```bash
# Use fully qualified image names (already configured)
# Or configure registries in /etc/containers/registries.conf
```

## Using with Applications

### Next.js

```typescript
const databaseUrl = process.env.DATABASE_URL;
const redisUrl = process.env.REDIS_URL;
```

### With Prisma

Update `packages/dal/.env`:

```env
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
```

Then run migrations:

```bash
pnpm --filter @last-key/dal prisma:migrate:dev
```

### With Redis Libraries

```typescript
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD || 'redis_password',
});
```

## Performance Tips

1. **Allocate resources** to Podman VM:
   - At least 2 CPUs
   - At least 4GB RAM

2. **Use `.env.local`** for local-only secrets
3. **Don't commit `.env.local`** to git (already in .gitignore)
4. **Stop services** when not developing to save resources

## Health Checks

Both services are configured with health checks:

```bash
# Check PostgreSQL health
podman-compose -f podman-compose.yml exec postgres pg_isready -U dev

# Check Redis health
podman-compose -f podman-compose.yml exec redis redis-cli -a redis_password ping
```

## Stopping Services

```bash
# Stop but keep data
pnpm services:stop

# Or remove everything (careful: deletes all data)
./scripts/dev.sh clean
```

## References

- [Podman Documentation](https://docs.podman.io/)
- [podman-compose GitHub](https://github.com/containers/podman-compose)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Redis Docker Image](https://hub.docker.com/_/redis)
- [Project Structure](CLAUDE.md)
- [Kubernetes Deployment](k8s/README.md)
