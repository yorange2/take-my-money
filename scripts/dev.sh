#!/bin/bash

# Quick management commands for local development containers

set -e

ENV_FILE=".env.local"
COMPOSE="podman-compose --env-file ${ENV_FILE} -f podman-compose.yml"

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
        fi

        # Build app images sequentially (parallel builds exceed podman memory)
        echo "🔨 Building Docker images..."
        podman build -f apps/web/Dockerfile -t last-key-web:local .
        podman build -f apps/worker/Dockerfile -t last-key-worker:local .

        # Start all services
        echo "📦 Starting all containers..."
        $COMPOSE up -d

        # Wait for infrastructure services
        echo "⏳ Waiting for services to be ready..."
        for i in {1..30}; do
            if $COMPOSE exec -T postgres pg_isready -U dev &>/dev/null; then
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
            if $COMPOSE exec -T redis redis-cli -a redis_password ping &>/dev/null; then
                echo "✅ Redis is ready"
                break
            fi
            if [ $i -eq 30 ]; then
                echo "❌ Redis failed to start"
                exit 1
            fi
            sleep 1
        done

        # Wait for web app
        for i in {1..60}; do
            if curl -sf http://localhost:3000 &>/dev/null; then
                echo "✅ Web app is ready (http://localhost:3000)"
                break
            fi
            if [ $i -eq 60 ]; then
                echo "❌ Web app failed to start"
                $COMPOSE logs web
                exit 1
            fi
            sleep 2
        done

        # Check worker is running
        for i in {1..30}; do
            if podman inspect last-key-worker --format '{{.State.Running}}' 2>/dev/null | grep -q true; then
                echo "✅ Worker is running"
                break
            fi
            if [ $i -eq 30 ]; then
                echo "❌ Worker failed to start"
                $COMPOSE logs worker
                exit 1
            fi
            sleep 1
        done

        echo ""
        echo "✨ Development environment is ready!"
        echo ""
        echo "📊 Service Information:"
        echo "   Web:        http://localhost:3000"
        echo "   PostgreSQL: localhost:35432 (user: dev, password: dev_password)"
        echo "   Redis:      localhost:36379 (password: redis_password)"
        echo "   Worker:     running in background"
        ;;
    stop)
        echo "🛑 Stopping services..."
        $COMPOSE down
        echo "✅ Services stopped"
        ;;
    restart)
        echo "🔄 Restarting services..."
        $COMPOSE restart
        echo "✅ Services restarted"
        ;;
    logs)
        echo "📋 Showing logs..."
        $COMPOSE logs -f ${2:-}
        ;;
    ps)
        echo "📊 Container status:"
        $COMPOSE ps
        ;;
    db-shell)
        echo "🗄️  Connecting to PostgreSQL..."
        $COMPOSE exec postgres psql -U dev -d last_key
        ;;
    redis-cli)
        echo "🔴 Connecting to Redis..."
        $COMPOSE exec redis redis-cli -a redis_password
        ;;
    clean)
        echo "🧹 Removing all containers and volumes..."
        read -p "⚠️  This will delete all data. Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $COMPOSE down -v
            echo "✅ Cleanup complete"
        fi
        ;;
    *)
        echo "Usage: ./scripts/dev.sh [command]"
        echo ""
        echo "Commands:"
        echo "  start       - Build images and start all services"
        echo "  stop        - Stop services"
        echo "  restart     - Restart services"
        echo "  logs        - Show service logs (optional: specify service name)"
        echo "  ps          - Show container status"
        echo "  db-shell    - Connect to PostgreSQL shell"
        echo "  redis-cli   - Connect to Redis CLI"
        echo "  clean       - Remove all containers and volumes"
        ;;
esac
