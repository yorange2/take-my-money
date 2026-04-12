#!/bin/bash

# Quick management commands for local development containers

case "$1" in
    start)
        echo "🚀 Starting PostgreSQL and Redis..."
        podman-compose -f podman-compose.yml up -d
        echo "✅ Services started"
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
        podman-compose -f podman-compose.yml exec postgres psql -U dev -d take_my_money
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
        echo "  start       - Start PostgreSQL and Redis"
        echo "  stop        - Stop services"
        echo "  restart     - Restart services"
        echo "  logs        - Show service logs (optional: specify service name)"
        echo "  ps          - Show container status"
        echo "  db-shell    - Connect to PostgreSQL shell"
        echo "  redis-cli   - Connect to Redis CLI"
        echo "  clean       - Remove all containers and volumes"
        ;;
esac
