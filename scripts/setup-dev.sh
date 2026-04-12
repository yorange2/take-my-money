#!/bin/bash

# Setup script for local development environment with Podman

set -e

echo "🚀 Setting up Take My Money local development environment..."

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    echo "❌ Podman is not installed. Please install Podman first."
    echo "   See: https://podman.io/docs/installation"
    exit 1
fi

# Check if podman-compose is installed
if ! command -v podman-compose &> /dev/null; then
    echo "⚠️  podman-compose is not installed."
    echo "   Install with: apt install podman-compose -y"
    exit 1
fi

# Create .env.local if it doesn't exist
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from template..."
    cp .env.local.example .env.local
    echo "✅ Created .env.local - update if needed"
else
    echo "✅ .env.local already exists"
fi

# Start services
echo "📦 Starting PostgreSQL and Redis containers..."
podman-compose -f podman-compose.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
for i in {1..30}; do
    if podman-compose -f podman-compose.yml exec -T postgres pg_isready -U dev &>/dev/null; then
        echo "✅ PostgreSQL is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ PostgreSQL failed to start"
        exit 1
    fi
    sleep 1
done

for i in {1..30}; do
    if podman-compose -f podman-compose.yml exec -T redis redis-cli -a redis_password ping &>/dev/null; then
        echo "✅ Redis is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Redis failed to start"
        exit 1
    fi
    sleep 1
done

echo ""
echo "✨ Development environment is ready!"
echo ""
echo "📊 Service Information:"
echo "   PostgreSQL: localhost:5432 (user: dev, password: dev_password)"
echo "   Redis:      localhost:6379 (password: redis_password)"
echo ""
echo "🎯 Next steps:"
echo "   1. Run: pnpm install"
echo "   2. Run: pnpm dev"
echo ""
echo "🛑 To stop services:"
echo "   podman-compose -f podman-compose.yml down"
echo ""
