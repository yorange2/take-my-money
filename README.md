# Take My Money Monorepo with pnpm

A monorepo using pnpm workspaces with three packages:

## 📁 Structure

```
.
├── packages/
│   └── shared-lib/        # Shared utility library
├── apps/
│   ├── app-cli/           # CLI application
│   └── app-web/           # Web application
├── pnpm-workspace.yaml    # Workspace configuration
├── pnpm-lock.yaml         # Lock file
└── package.json           # Root package.json with scripts
```

## 📦 Packages

### `@take-my-money/shared-lib`
Shared utilities that other packages can depend on. Contains:
- `greet(name)` - Returns a greeting message
- `add(a, b)` - Returns the sum of two numbers

### `@take-my-money/app-cli`
A CLI application that uses the shared library.

**Run:**
```bash
node apps/app-cli/src/index.js
```

**Output:**
```
Hello, World!
2 + 3 = 5
```

### `@take-my-money/app-web`
A web application that also uses the shared library.

**Run:**
```bash
node apps/app-web/src/index.js
```

**Output:**
```
Web app started
Hello, Web User!
```

## 🚀 Key Features

- **Workspace protocol**: Packages use `"workspace:*"` to depend on local packages
- **ES Modules**: All packages configured with `"type": "module"` for modern JavaScript
- **Shared dependencies**: Changes to `@helloworld/shared-lib` are immediately available to other packages
- **Root scripts**: Run commands across all packages with `pnpm -r`

## 📝 Root Scripts

- `pnpm build` - Build all packages
- `pnpm test` - Test all packages
- `pnpm dev` - Run dev server for all packages in parallel

## ✨ Next Steps

You can extend this monorepo by:
1. Adding more packages to the `packages/` directory or `apps/` directory
2. Adding build tools (TypeScript, Babel, etc.)
3. Setting up testing frameworks (Jest, Vitest, etc.)
4. Adding linting and formatting tools (ESLint, Prettier, etc.)
