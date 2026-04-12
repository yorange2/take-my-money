# Development Workflow

Quick reference guide for local development with Take My Money.

## Initial Setup (First Time Only)

```bash
# 1. Clone and navigate to project
cd take-my-money

# 2. Setup local services (PostgreSQL + Redis)
pnpm setup:dev

# 3. Install dependencies
pnpm install

# 4. Start development servers
pnpm dev
```

The `pnpm setup:dev` command handles:

- Checking Podman installation
- Creating `.env.local` from template
- Starting PostgreSQL and Redis containers
- Waiting for services to be ready

## Daily Development

### Start Everything

```bash
# Services are already running? Just start dev server
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

### Check Service Status

```bash
pnpm services:ps

# Or individual logs
pnpm services:logs              # All services
pnpm services:logs postgres     # PostgreSQL only
pnpm services:logs redis        # Redis only
```

### Database Access

```bash
# Connect to PostgreSQL shell
pnpm db:shell

# Run migrations (if you have them)
psql -h localhost -U dev -d take_my_money < db/migrations/001_init.sql
```

### Redis Access

```bash
# Connect to Redis CLI
pnpm redis:cli

# Example commands
# SET mykey "Hello"
# GET mykey
# FLUSHDB  (clear all data)
```

## Code Quality

```bash
# Check for linting errors
pnpm lint

# Auto-fix lint and format issues
pnpm lint:fix

# Format with Prettier only
pnpm format
```

## Building & Deployment

```bash
# Build all packages
pnpm build

# Build for production
pnpm build

# Run tests
pnpm test
```

## Stopping Services

```bash
# Stop, but keep data
pnpm services:stop

# Or use the dev script
./scripts/dev.sh stop

# Remove everything (careful: deletes all data)
./scripts/dev.sh clean
```

## Environment Variables

### Local Development (.env.local)

```bash
# Copy from template
cp .env.local.example .env.local

# Edit as needed
nano .env.local  # or your editor
```

Default local values:

```env
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
REDIS_URL=redis://:redis_password@localhost:6379
```

## Useful Commands Reference

| Command                 | Purpose                       |
| ----------------------- | ----------------------------- |
| `pnpm setup:dev`        | Initial dev environment setup |
| `pnpm dev`              | Start development servers     |
| `pnpm services:start`   | Start PostgreSQL & Redis      |
| `pnpm services:stop`    | Stop services                 |
| `pnpm services:restart` | Restart services              |
| `pnpm services:ps`      | View service status           |
| `pnpm services:logs`    | View service logs             |
| `pnpm db:shell`         | Connect to PostgreSQL         |
| `pnpm redis:cli`        | Connect to Redis              |
| `pnpm lint`             | Check code quality            |
| `pnpm lint:fix`         | Fix lint/format issues        |
| `pnpm format`           | Format code with Prettier     |
| `pnpm build`            | Build all packages            |
| `pnpm test`             | Run tests                     |

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
```

Then update `.env.local`:

```env
DB_PORT=5433
```

### Can't Connect to Database

```bash
# Verify service is running and healthy
pnpm services:ps

# Try connecting directly
pnpm db:shell

# Check logs
pnpm services:logs postgres
```

## More Information

- **K8s Deployment**: See [k8s/README.md](k8s/README.md)
- **Local Setup Details**: See [LOCAL_DEV_SETUP.md](LOCAL_DEV_SETUP.md)
- **Project Structure**: See [CLAUDE.md](CLAUDE.md)
- **Next.js App**: See [apps/web/CLAUDE.md](apps/web/CLAUDE.md)

## Tips

1. **Keep services running** throughout your dev session
2. **Check logs** if anything seems wrong: `pnpm services:logs`
3. **Use `.env.local`** for local overrides (never commit it)
4. **Update DATABASE_URL and REDIS_URL** if you change ports
5. **Run `pnpm lint:fix`** before committing code
