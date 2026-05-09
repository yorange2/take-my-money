# LastKey - Claude Project Guide

This is a modern monorepo using pnpm workspaces with a Next.js application and backend packages.

## Project Overview

**LastKey** is a monorepo project structured with:

- **packages/dal** - Prisma data access layer (`@last-key/dal`)
- **apps/web** - Next.js 15 application with TypeScript and Tailwind CSS
- **apps/worker** - BullMQ task worker

## Tech Stack

- **Monorepo**: pnpm workspaces
- **Apps**: Next.js 15, React 19, TypeScript
- **Styling**: Tailwind CSS
- **Code Quality**: ESLint (Google config), Prettier
- **Development**: VS Code with auto-fix/format on save

## Key Scripts

```bash
# Root level commands
pnpm install              # Install all dependencies
pnpm dev                  # Run all apps in parallel
pnpm build                # Build all packages
pnpm lint                 # Check code quality
pnpm lint:fix             # ESLint auto-fix + Prettier format
pnpm format               # Prettier format only

# Web app specific
cd apps/web
pnpm run dev              # Start Next.js dev server (localhost:3000)
pnpm run build            # Build for production
pnpm run start            # Start production server
```

## Project Structure

```
last-key/
├── packages/dal/                 # Data Access Layer package
│   ├── prisma/                   # Prisma schema and seed
│   └── src/                      # DAL source
│
├── apps/web/                     # Next.js application
│   ├── src/app/
│   │   ├── page.tsx              # Home page
│   │   ├── layout.tsx            # Root layout with metadata
│   │   └── globals.css           # Tailwind CSS
│   ├── tailwind.config.mjs
│   ├── next.config.mjs
│   └── tsconfig.json
│
├── apps/worker/                  # BullMQ worker
│   ├── src/index.ts              # Worker bootstrap
│   ├── src/processor.ts          # Job processing logic
│   └── package.json
│
├── .vscode/
│   ├── settings.json             # Auto-fix/format on save
│   └── extensions.json           # Recommended extensions
│
├── eslint.config.mts             # ESLint configuration (flat config)
├── .prettierrc                    # Prettier configuration
├── .gitignore
├── pnpm-workspace.yaml           # Workspace configuration
└── package.json                  # Root package with shared scripts
```

## Development Guidelines

### Code Style

- **Formatting**: Prettier (2-space indents, single quotes)
- **Linting**: ESLint with Google config
- **TypeScript**: Strict mode enabled
- **Auto-fix**: Enabled on save in VS Code

### VS Code Setup

1. Install recommended extensions (VSCode will prompt):
   - dbaeumer.vscode-eslint
   - esbenp.prettier-vscode

2. Files auto-fix and format on save automatically

### Adding New Packages

1. Create package in `packages/` (libraries) or `apps/` (applications)
2. Add `package.json` with:
   ```json
   {
     "name": "@last-key/my-package",
     "type": "module",
     "scripts": {
       "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
       "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix"
     }
   }
   ```
3. Run `pnpm install` to update workspace

## Important Notes

- **Node Version**: Currently using Node v25.9.0 (via nvm)
- **Package Manager**: pnpm (not npm or yarn)
- **Workspace Protocol**: All inter-package dependencies use `workspace:*`
- **ES Modules**: All packages use `"type": "module"`
- **Git**: Master branch is the main development branch

## Common Tasks

### Run Next.js Development Server

```bash
pnpm --filter @last-key/web run dev
# or
cd apps/web && pnpm run dev
```

### Fix All Formatting Issues

```bash
pnpm lint:fix
```

### Check for ESLint Errors

```bash
pnpm lint
```

### Add New Dependency to Next.js App

```bash
pnpm --filter @last-key/web add some-package
# or for dev dependency
pnpm --filter @last-key/web add -D some-package
```

## Git Workflow

- Use conventional commit messages
- Keep commits focused and descriptive
- Lint and format before committing (or use pre-commit hooks)
- All major features go to master branch

## Configuration Files to Know

- **eslint.config.mts** - ESLint rules for JS/TS/JSX/TSX files
- **.prettierrc** - Prettier formatting settings
- **.vscode/settings.json** - VS Code workspace settings
- **pnpm-workspace.yaml** - Workspace configuration (includes `packages/*` and `apps/*`)
- **tsconfig.json** (at app level) - TypeScript configuration for each app

## Next Steps for Enhancement

1. Add testing framework (Vitest or Jest)
2. Set up pre-commit hooks (husky)
3. Add GitHub Actions CI/CD
4. Set up database configuration
5. Add authentication/authorization
6. Add more shared packages as needed

## App-Specific Documentation

For detailed information about the Next.js application, including page structure, component development, Tailwind CSS usage, and development workflows, see [apps/web/CLAUDE.md](apps/web/CLAUDE.md).

## Notes for Claude

- This is a modern, well-configured monorepo
- Code style is enforced via ESLint + Prettier
- All files auto-fix on save in VS Code
- Next.js app is configured with TypeScript and Tailwind
- Feel free to add new packages to the `packages/` or `apps/` directories
- Always run `pnpm install` after adding new packages
- Use `pnpm lint:fix` to auto-fix code before committing
