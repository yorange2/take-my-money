# Take My Money Monorepo with pnpm

A modern monorepo using pnpm workspaces with a Next.js application and shared utilities.

## 📁 Structure

```
.
├── packages/
│   └── shared-lib/        # Shared utility library
├── apps/
│   └── web/               # Next.js application
├── .vscode/               # VS Code settings for auto-fix/format
├── pnpm-workspace.yaml    # Workspace configuration
├── eslint.config.mts      # ESLint configuration
└── package.json           # Root package.json with scripts
```

## 📦 Packages

### `@take-my-money/shared-lib`

Shared utilities used across the monorepo. Contains:

- `greet(name)` - Returns a greeting message
- `add(a, b)` - Returns the sum of two numbers

### `@take-my-money/web`

A modern Next.js application with:

- **TypeScript** support
- **Tailwind CSS** for styling
- **ESLint** integration
- Uses `@take-my-money/shared-lib`

**Run:**

```bash
cd apps/web
pnpm run dev
```

Open [http://localhost:3000](http://localhost:3000) to see the app.

## 🚀 Key Features

- **pnpm Workspaces** - Monorepo workspace management
- **Workspace Protocol** - Packages use `"workspace:*"` for dependencies
- **ESLint + Prettier** - Code quality and formatting with auto-fix on save
- **TypeScript** - Type safety across the monorepo
- **Next.js 15** - Modern React framework
- **Tailwind CSS** - Utility-first CSS framework
- **VS Code Integration** - Auto-format and auto-fix on save

## 📝 Root Scripts

- `pnpm dev` - Run dev servers for all apps in parallel
- `pnpm build` - Build all packages
- `pnpm test` - Run tests across all packages
- `pnpm lint` - Check code quality
- `pnpm lint:fix` - Auto-fix ESLint issues + format with Prettier
- `pnpm format` - Format code with Prettier

## 🛠️ Development

### Install Dependencies

```bash
pnpm install
```

### Auto-fix on Save

The project is configured for VS Code to auto-fix and format on save:

1. Install recommended extensions:
   - [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
   - [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

2. Files will auto-fix and format when you save

### Run Next.js Dev Server

```bash
pnpm --filter @take-my-money/web run dev
```

Or from the app directory:

```bash
cd apps/web
pnpm run dev
```

## ✨ Next Steps

You can extend this monorepo by:

1. Adding more apps or packages to the `apps/` and `packages/` directories
2. Setting up testing frameworks (Jest, Vitest, etc.)
3. Adding CI/CD pipelines
4. Setting up database migrations and ORM configuration

