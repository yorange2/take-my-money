# Local Development Environment Setup

This guide helps you set up PostgreSQL and Redis using Podman for local development.

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

## Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# From project root
chmod +x scripts/setup-dev.sh
./scripts/setup-dev.sh
```

This will:

- Check Podman installation
- Create `.env.local` from template
- Start PostgreSQL and Redis containers
- Wait for services to be ready
- Display connection information

### Option 2: Manual Setup

```bash
# Copy environment template
cp .env.local.example .env.local

# Start services
podman-compose -f podman-compose.yml up -d

# Verify services are running
podman-compose -f podman-compose.yml ps
```

## Development Commands

Use the convenient `dev.sh` helper script:

```bash
# Start containers
./scripts/dev.sh start

# Stop containers
./scripts/dev.sh stop

# Restart containers
./scripts/dev.sh restart

# View logs
./scripts/dev.sh logs
./scripts/dev.sh logs postgres
./scripts/dev.sh logs redis

# Check status
./scripts/dev.sh ps

# Connect to PostgreSQL
./scripts/dev.sh db-shell

# Connect to Redis
./scripts/dev.sh redis-cli

# Clean up (removes all data)
./scripts/dev.sh clean
```

## Service Details

### PostgreSQL

**Connection Details:**

- Host: `localhost`
- Port: `5432`
- Username: `dev`
- Password: `dev_password`
- Database: `take_my_money`

**Connect with psql:**

```bash
./scripts/dev.sh db-shell
# or
psql -h localhost -U dev -d take_my_money
```

**Connection String (for .env.local):**

```
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
```

### Redis

**Connection Details:**

- Host: `localhost`
- Port: `6379`
- Password: `redis_password`

**Connect with Redis CLI:**

```bash
./scripts/dev.sh redis-cli
# or
redis-cli -h localhost -p 6379 -a redis_password
```

**Connection String (for .env.local):**

```
REDIS_URL=redis://:redis_password@localhost:6379
```

## Environment Configuration

Create `.env.local` from the template:

```bash
cp .env.local.example .env.local
```

Edit `.env.local` with your preferred values:

```env
# Database
DB_USER=dev
DB_PASSWORD=dev_password
DB_NAME=take_my_money
DB_PORT=5432
DB_HOST=localhost
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis_password
REDIS_URL=redis://:redis_password@localhost:6379

# Application
NODE_ENV=development
NEXT_PUBLIC_APP_NAME=Take My Money
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Running the Development Server

After setting up the local environment:

```bash
# Install dependencies
pnpm install

# Start services (if not already running)
./scripts/dev.sh start

# Run development server
pnpm dev

# Open browser
# http://localhost:3000
```

## Database Migrations (Optional)

If you have database migrations:

```bash
# Using raw SQL
./scripts/dev.sh db-shell < db/init.sql

# Or import from file
psql -h localhost -U dev -d take_my_money < db/init.sql
```

## Troubleshooting

### Port Already in Use

If port 5432 or 6379 is already in use:

1. **Stop existing services:**

   ```bash
   ./scripts/dev.sh stop
   ```

2. **Use different ports** (edit `podman-compose.yml`):

   ```yaml
   postgres:
     ports:
       - '5433:5432' # Use 5433 instead

   redis:
     ports:
       - '6380:6379' # Use 6380 instead
   ```

3. **Update .env.local:**
   ```env
   DB_PORT=5433
   REDIS_PORT=6380
   DATABASE_URL=postgresql://dev:dev_password@localhost:5433/take_my_money
   REDIS_URL=redis://:redis_password@localhost:6380
   ```

### Container Won't Start

```bash
# View logs
./scripts/dev.sh logs

# Check specific service
./scripts/dev.sh logs postgres
./scripts/dev.sh logs redis

# Try restarting
./scripts/dev.sh restart

# Clean and restart
./scripts/dev.sh clean
./scripts/dev.sh start
```

### Cannot Connect to Database

```bash
# Verify container is running
./scripts/dev.sh ps

# Check if service is healthy
podman-compose -f podman-compose.yml exec postgres pg_isready -U dev

# Try connecting directly
./scripts/dev.sh db-shell
```

### Podman Socket Error

On Linux, you may need to start the Podman socket:

```bash
# Start the Podman socket service
systemctl --user start podman.socket

# Or enable it to auto-start
systemctl --user enable podman.socket
```

## Data Persistence

- **PostgreSQL data** is stored in the `postgres_data` volume
- **Redis data** is stored in the `redis_data` volume
- Both survive container restarts

To completely remove data:

```bash
./scripts/dev.sh clean
```

## Using with Your Application

### Next.js

In your Next.js app, import database URLs from environment:

```typescript
const databaseUrl = process.env.DATABASE_URL;
const redisUrl = process.env.REDIS_URL;
```

### With ORMs (Prisma, Drizzle, etc.)

Update your ORM configuration to use environment variables:

```env
# .env.local
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
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

## Health Checks

Both services are configured with health checks:

```bash
# Check PostgreSQL health
podman-compose -f podman-compose.yml exec postgres pg_isready -U dev

# Check Redis health
podman-compose -f podman-compose.yml exec redis redis-cli -a redis_password ping
```

## Performance Tips

1. **Allocate sufficient resources** to Podman VM (on Docker Desktop):
   - At least 2 CPUs
   - At least 4GB RAM

2. **Use `.env.local`** for local-only secrets
3. **Don't commit `.env.local`** to git (.gitignore included)
4. **Stop services** when not developing to save resources

## What's Next?

1. ✅ Services are running
2. Install dependencies: `pnpm install`
3. Start dev server: `pnpm dev`
4. Create `.env.local` with your settings
5. Begin development!

## References

- [Podman Documentation](https://docs.podman.io/)
- [podman-compose GitHub](https://github.com/containers/podman-compose)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Redis Docker Image](https://hub.docker.com/_/redis)
