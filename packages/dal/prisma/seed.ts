import { prisma } from '../src/client';

// Seed database with example data
async function main() {
  console.log('🌱 Seeding database...');

  // Create a user
  const user = await prisma.user.upsert({
    where: { email: 'demo@example.com' },
    update: {},
    create: {
      email: 'demo@example.com',
      name: 'Demo User',
    },
  });

  console.log('✅ Created user:', user);

  // Create a post
  const post = await prisma.post.create({
    data: {
      title: 'Hello World',
      content: 'This is a demo post',
      published: true,
      userId: user.id,
    },
  });

  console.log('✅ Created post:', post);

  console.log('✨ Seeding complete!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
