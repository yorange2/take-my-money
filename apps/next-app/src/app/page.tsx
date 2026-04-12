'use client';

import { greet } from '@take-my-money/shared-lib';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">Take My Money</h1>
        <p className="text-xl text-gray-600 mb-8">{greet('Next.js User')}</p>
        <p className="text-lg">Welcome to your Next.js application!</p>
      </div>
    </main>
  );
}
