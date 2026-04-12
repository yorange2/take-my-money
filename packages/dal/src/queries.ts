import { prisma } from './client';

// User operations
export const userQueries = {
  findUnique: (email: string) => prisma.user.findUnique({ where: { email } }),
  findById: (id: string) => prisma.user.findUnique({ where: { id } }),
  create: (data: { email: string; name?: string }) =>
    prisma.user.create({
      data,
    }),
  update: (id: string, data: Partial<{ email: string; name: string }>) =>
    prisma.user.update({
      where: { id },
      data,
    }),
  delete: (id: string) => prisma.user.delete({ where: { id } }),
  findAll: () => prisma.user.findMany(),
};

// Post operations
export const postQueries = {
  findUnique: (id: string) => prisma.post.findUnique({ where: { id } }),
  findByUserId: (userId: string) =>
    prisma.post.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    }),
  create: (data: { title: string; content?: string; userId: string }) =>
    prisma.post.create({ data }),
  update: (
    id: string,
    data: Partial<{ title: string; content: string; published: boolean }>
  ) => prisma.post.update({ where: { id }, data }),
  delete: (id: string) => prisma.post.delete({ where: { id } }),
  findPublished: () =>
    prisma.post.findMany({
      where: { published: true },
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    }),
};

// Session operations
export const sessionQueries = {
  findUnique: (sessionToken: string) =>
    prisma.session.findUnique({
      where: { sessionToken },
      include: { user: true },
    }),
  create: (data: { sessionToken: string; userId: string; expires: Date }) =>
    prisma.session.create({ data }),
  delete: (sessionToken: string) =>
    prisma.session.delete({ where: { sessionToken } }),
  deleteByUserId: (userId: string) =>
    prisma.session.deleteMany({ where: { userId } }),
};

// Account operations
export const accountQueries = {
  findByProvider: (provider: string, providerAccountId: string) =>
    prisma.account.findUnique({
      where: { provider_providerAccountId: { provider, providerAccountId } },
    }),
  create: (data: {
    userId: string;
    type: string;
    provider: string;
    providerAccountId: string;
  }) => prisma.account.create({ data }),
  delete: (id: string) => prisma.account.delete({ where: { id } }),
};

export { prisma };
