import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'LastKey',
  description: 'Next.js app in LastKey monorepo',
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
