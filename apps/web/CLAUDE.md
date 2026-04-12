# Next.js App - Detailed Development Guide

This document provides detailed information about the Next.js application in the Take My Money monorepo. Refer to the root CLAUDE.md for general project setup and scripts.

## App Structure

```
apps/web/
├── src/
│   └── app/                      # Next.js App Router directory
│       ├── layout.tsx            # Root layout (metadata, html structure)
│       ├── page.tsx              # Home page (/ route)
│       └── globals.css           # Global Tailwind CSS import
├── public/                       # Static assets
├── .next/                        # Build output (git-ignored)
├── package.json                  # App dependencies
├── tsconfig.json                 # TypeScript configuration
├── next.config.mjs               # Next.js configuration
├── tailwind.config.mjs           # Tailwind CSS configuration
├── postcss.config.mjs            # PostCSS configuration
├── .gitignore                    # Git ignore rules
└── README.md                     # App-specific README
```

## Key Files

### `src/app/layout.tsx`

- Root layout component
- Defines metadata (title, description for SEO)
- Contains the html/body structure
- Wraps all pages with shared UI

### `src/app/page.tsx`

- Home page component (/ route)
- Uses `'use client'` directive (client component)
- Imports and uses `greet()` from `@take-my-money/shared-lib`
- Styled with Tailwind CSS

### `src/app/globals.css`

- Imports Tailwind CSS directives
- Can add global styles here if needed

## Dependencies

### Production

- **next**: ^15.0.0 - React framework
- **react**: ^19.0.0 - React library
- **react-dom**: ^19.0.0 - React DOM utilities
- **@take-my-money/shared-lib**: workspace:\* - Shared utilities from the monorepo

### Development

- **typescript**: ^5.3.0 - TypeScript compiler
- **@types/react**: ^18.2.0 - React type definitions
- **@types/react-dom**: ^18.2.0 - React DOM type definitions
- **@types/node**: ^20.0.0 - Node.js type definitions

## Configuration Files

### `tsconfig.json`

- **target**: ES2020 - JavaScript version target
- **lib**: ES2020, DOM, DOM.Iterable - Available APIs
- **jsx**: preserve - Preserves JSX for Next.js
- **moduleResolution**: bundler - Resolves modules like a bundler
- **strict**: true - TypeScript strict mode enabled
- **noEmit**: true - Don't emit JS (Next.js handles it)
- **isolatedModules**: true - Treat each file as a separate module
- **plugins**: Includes Next.js plugin for advanced type checking

### `next.config.mjs`

- ES module Next.js configuration
- Can be extended for custom webpack, environment variables, redirects, etc.

### `tailwind.config.mjs`

- Tailwind CSS configuration
- Configure theme colors, spacing, breakpoints, etc.
- Uses `content` array to find Tailwind class names

### `postcss.config.mjs`

- PostCSS configuration
- Includes Tailwind CSS plugin
- Processes CSS files and applies Tailwind directives

## Development Workflow

### Running the Dev Server

```bash
cd apps/web
pnpm run dev
# Server runs at http://localhost:3000
```

### Building for Production

```bash
cd apps/web
pnpm run build
```

### Starting Production Server

```bash
cd apps/web
pnpm run start
```

## Adding New Pages

Next.js uses file-based routing in the `src/app/` directory:

```
src/app/
├── page.tsx              → / (home)
├── layout.tsx            → Root layout
├── about/
│   └── page.tsx          → /about
├── blog/
│   ├── page.tsx          → /blog (list)
│   └── [id]/
│       └── page.tsx      → /blog/[id] (dynamic route)
```

**Example: Create `/about` page**

1. Create `src/app/about/page.tsx`:

```typescript
export default function About() {
  return <h1>About Page</h1>;
}
```

2. Access at `http://localhost:3000/about`

## Adding New Components

Store reusable components in a `src/components/` directory:

```
src/
├── app/
├── components/
│   ├── Header.tsx
│   ├── Footer.tsx
│   └── Navigation.tsx
```

**Example component**:

```typescript
export default function Header() {
  return <header className="bg-blue-600 text-white p-4">Header</header>;
}
```

Import in pages/layouts:

```typescript
import Header from '@/components/Header';
```

## Using the Shared Library

The shared library is already imported in `page.tsx`:

```typescript
import { greet } from '@take-my-money/shared-lib';

export default function Home() {
  return <p>{greet('User')}</p>;
}
```

**To add new functions to the shared library:**

1. Edit `packages/shared-lib/src/index.js`
2. Run `pnpm install` at the root
3. Import in this app

## Styling with Tailwind CSS

- Use Tailwind utility classes in JSX:

```typescript
<div className="flex items-center justify-center min-h-screen bg-gray-100">
  <h1 className="text-4xl font-bold text-blue-600">Hello</h1>
</div>
```

- Customize theme in `tailwind.config.mjs`
- Global styles in `src/app/globals.css`

## Client vs Server Components

- **Server Components** (default): Run on the server, can't use hooks

  ```typescript
  // No 'use client' directive
  export default function Page() { ... }
  ```

- **Client Components**: Run in the browser, can use hooks
  ```typescript
  'use client';
  import { useState } from 'react';
  export default function Page() { ... }
  ```

The home page uses `'use client'` because it needs to interact with the browser.

## Next.js Features to Explore

- **App Router**: File-based routing in `src/app/`
- **Server Components**: Default render on server for better performance
- **Client Components**: Use `'use client'` for interactivity
- **API Routes**: Create in `src/app/api/` for backend endpoints
- **Dynamic Routes**: `[param]` syntax for URL parameters
- **Layouts**: Nested layouts for shared UI structure
- **Metadata**: SEO with `Metadata` type from 'next'
- **Image Optimization**: `next/image` for optimized images
- **Streaming**: Progressive rendering with Suspense

## Linting and Formatting

```bash
# From app root
pnpm run lint              # Check for lint errors
pnpm run lint:fix          # Auto-fix lint errors

# Or from monorepo root
pnpm lint                  # Lint all packages
pnpm lint:fix              # Fix all packages
```

## TypeScript

- Strict mode enabled - types are required
- Check types: `pnpm exec tsc --noEmit`
- Define types clearly for props and state

## Tailwind CSS

The app uses Tailwind CSS for styling. Key utilities:

- **Flexbox**: `flex`, `items-center`, `justify-center`
- **Sizing**: `w-full`, `h-screen`, `min-h-screen`
- **Colors**: `text-blue-600`, `bg-gray-100`
- **Spacing**: `p-4`, `m-2`, `mb-8`
- **Text**: `text-lg`, `font-bold`, `text-center`
- **Responsive**: `md:flex`, `lg:grid` (mobile-first breakpoints)

Customize in `tailwind.config.mjs` for project-specific colors, fonts, etc.

## Common Development Tasks

### Add a New Page with Styling

1. Create `src/app/new-page/page.tsx`
2. Add component with Tailwind classes
3. Access at `/new-page`

### Create a Reusable Component

1. Create `src/components/MyComponent.tsx`
2. Import where needed: `import MyComponent from '@/components/MyComponent'`

### Add an API Endpoint

1. Create `src/app/api/route.ts`
2. Export functions: `export async function GET(req) { ... }`
3. Access at `/api/`

### Import from Shared Library

1. Use: `import { functionName } from '@take-my-money/shared-lib'`
2. Function automatically available after `pnpm install`

## Path Aliases

In `tsconfig.json`, `@/*` is aliased to `src/`:

```typescript
// These are equivalent:
import Header from './components/Header';
import Header from '@/components/Header'; // Preferred
```

## Notes for Claude

- This is a modern Next.js 15 app with React 19 and TypeScript strict mode
- Always use `'use client'` only when needed (interactivity, hooks)
- Prefer server components for better performance
- Use Tailwind CSS classes for styling (avoid inline styles)
- Keep components small and focused
- The shared library is already set up and ready to extend
- Follow the current code style (see root CLAUDE.md for linting rules)
- TypeScript is strict - all types must be defined
