// Export Prisma client and types
export { PrismaClient } from '@prisma/client';
export type {
  User,
  Post,
  Account,
  Session,
  VerificationToken,
} from '@prisma/client';

// Export our singleton instance
export { default as prisma } from './client';
export { default } from './client';
