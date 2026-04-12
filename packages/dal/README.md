# DAL (Data Access Layer) Package

Prisma-based data access layer for Take My Money application.

## Features

- **Prisma ORM** - Type-safe database access
- **Singleton pattern** - Single database connection
- **Pre-built queries** - Common database operations
- **TypeScript** - Fully typed database models
- **PostgreSQL** - Optimized for PostgreSQL

## Installation

```bash
pnpm install
```

## Setup

### 1. Configure Database URL

Create `.env.local` in project root:

```env
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
```

Or in packages/dal/.env:

```env
DATABASE_URL=postgresql://dev:dev_password@localhost:5432/take_my_money
```

### 2. Generate Prisma Client

```bash
pnpm prisma:generate
```

### 3. Run Migrations

```bash
# Development (with prompt for migration name)
pnpm prisma:migrate:dev

# Production (apply existing migrations)
pnpm prisma:migrate:deploy
```

### 4. Seed Database (Optional)

```bash
pnpm prisma:seed
```

## Usage

### Basic Queries

```typescript
import { prisma, userQueries, postQueries } from '@take-my-money/dal';

// Find user by email
const user = await userQueries.findUnique('user@example.com');

// Create post
const post = await postQueries.create({
  title: 'My Post',
  content: 'Post content',
  userId: user.id,
});

// Get all published posts
const posts = await postQueries.findPublished();
```

### Direct Prisma Access

```typescript
import { prisma } from '@take-my-money/dal';

// Use Prisma directly for custom queries
const result = await prisma.user.findMany({
  where: {
    email: { contains: '@example.com' },
  },
  include: { posts: true },
});
```

## Database Schema

### Models

- **User** - Application users
- **Post** - User posts/content
- **Account** - OAuth/external auth accounts
- **Session** - User sessions
- **VerificationToken** - Email verification tokens

## Migrations

### Create Migration

```bash
# After updating schema.prisma
pnpm prisma:migrate:dev --name migration_name
```

### View Migration History

```bash
ls prisma/migrations/
```

### Reset Database

```bash
pnpm prisma:migrate:reset
```

## Prisma Studio

Explore database with GUI:

```bash
pnpm prisma:studio
```

Opens at http://localhost:5555

## Development

### Watch Mode

```bash
pnpm dev
```

### Type Checking

```bash
pnpm build
```

### Update Schema

1. Edit `prisma/schema.prisma`
2. Run `pnpm prisma:migrate:dev --name descriptive_name`
3. Commit migration files

## Adding New Models

1. Edit `prisma/schema.prisma`:

```prisma
model Article {
  id    String  @id @default(cuid())
  title String
  slug  String  @unique

  @@map("articles")
}
```

2. Create migration:

```bash
pnpm prisma:migrate:dev --name add_article_model
```

3. Add queries in `src/queries.ts`:

```typescript
export const articleQueries = {
  findBySlug: (slug: string) => prisma.article.findUnique({ where: { slug } }),
  // ... more queries
};
```

4. Export from `src/index.ts`:

```typescript
export { articleQueries };
```

## Best Practices

- Use the pre-built query functions for common operations
- Import types from `@prisma/client` for TypeScript
- Always handle database errors in calling code
- Use transactions for multi-step operations
- Index frequently queried fields
- Use `@unique` for email, usernames, etc.

## Exports

```typescript
// Singleton Prisma client
import { prisma } from '@take-my-money/dal';

// Prisma types
import type { User, Post } from '@take-my-money/dal';

// Query functions
import { userQueries, postQueries, sessionQueries } from '@take-my-money/dal';
```

## Environment Variables

```env
# Required
DATABASE_URL=postgresql://user:password@localhost:5432/db_name

# Optional
DATABASE_POOL_SIZE=10
DATABASE_TIMEOUT=10
```

## Deployment

### Production Build

```bash
pnpm build
```

### Apply Migrations

```bash
pnpm prisma:migrate:deploy
```

### Docker

Use with your Dockerfile:

```dockerfile
# Generate Prisma client
RUN pnpm prisma:generate

# Run migrations
RUN pnpm prisma:migrate:deploy
```

## Troubleshooting

### Connection Error

```bash
# Check DATABASE_URL is correct
echo $DATABASE_URL

# Test connection
pnpm prisma db execute --stdin
```

### Migration Lock

```bash
# Reset migration state
pnpm prisma migrate resolve --rolled-back migration_name
```

### Type Generation Issues

```bash
# Regenerate client
pnpm prisma:generate

# Clear cache
rm node_modules/.prisma
pnpm prisma:generate
```

## References

- [Prisma Documentation](https://www.prisma.io/docs/)
- [Prisma Schema](https://www.prisma.io/docs/orm/prisma-schema)
- [Prisma Client](https://www.prisma.io/docs/orm/prisma-client)
