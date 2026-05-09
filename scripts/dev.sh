#!/bin/bash

# Quick management commands for local development containers

set -e

case "$1" in
    start)
        echo "🚀 Setting up LastKey local development environment..."

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
        echo "   PostgreSQL: localhost:35432 (user: dev, password: dev_password)"
        echo "   Redis:      localhost:36379 (password: redis_password)"
        echo ""
        echo "🎯 Next steps:"
        echo "   1. Run: pnpm install"
        echo "   2. Run: pnpm dev"
        ;;
    stop)
        echo "🛑 Stopping services..."
        podman-compose -f podman-compose.yml down
        echo "✅ Services stopped"
        ;;
    restart)
        echo "🔄 Restarting services..."
        podman-compose -f podman-compose.yml restart
        echo "✅ Services restarted"
        ;;
    logs)
        echo "📋 Showing logs..."
        podman-compose -f podman-compose.yml logs -f ${2:-}
        ;;
    ps)
        echo "📊 Container status:"
        podman-compose -f podman-compose.yml ps
        ;;
    db-shell)
        echo "🗄️  Connecting to PostgreSQL..."
        podman-compose -f podman-compose.yml exec postgres psql -U dev -d last_key
        ;;
    redis-cli)
        echo "🔴 Connecting to Redis..."
        podman-compose -f podman-compose.yml exec redis redis-cli -a redis_password
        ;;
    clean)
        echo "🧹 Removing all containers and volumes..."
        read -p "⚠️  This will delete all data. Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            podman-compose -f podman-compose.yml down -v
            echo "✅ Cleanup complete"
        fi
        ;;
    *)
        echo "Usage: ./scripts/dev.sh [command]"
        echo ""
        echo "Commands:"
        echo "  start       - Set up and start dev environment (PostgreSQL + Redis)"
        echo "  stop        - Stop services"
        echo "  restart     - Restart services"
        echo "  logs        - Show service logs (optional: specify service name)"
        echo "  ps          - Show container status"
        echo "  db-shell    - Connect to PostgreSQL shell"
        echo "  redis-cli   - Connect to Redis CLI"
        echo "  clean       - Remove all containers and volumes"
        ;;
esac
