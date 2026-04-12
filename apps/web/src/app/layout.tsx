import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Take My Money',
  description: 'Next.js app in Take My Money monorepo',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
