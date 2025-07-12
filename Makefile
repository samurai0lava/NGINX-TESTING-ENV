# NGINX Docker Development Environment
# Usage: make [target]

.PHONY: help setup start stop restart logs status clean rebuild test shell

# Default target
help:
	@echo "NGINX Docker Development Environment"
	@echo "====================================="
	@echo "Available targets:"
	@echo "  setup     - Create directories and default files"
	@echo "  start     - Start NGINX container"
	@echo "  stop      - Stop NGINX container"
	@echo "  restart   - Restart NGINX container"
	@echo "  logs      - Show container logs (follow)"
	@echo "  status    - Show container status"
	@echo "  test      - Test NGINX configuration"
	@echo "  shell     - Open shell in NGINX container"
	@echo "  rebuild   - Rebuild and restart container"
	@echo "  clean     - Stop and remove containers/volumes"
	@echo "  url       - Show access URLs"
	@echo "  reload    - Reload NGINX configuration"

# Setup project structure
setup:
	@echo "Setting up NGINX Docker environment..."
	@mkdir -p html conf.d logs
	@if [ ! -f html/index.html ]; then \
		echo '<h1>NGINX is working!</h1><p>This is running in Docker</p><p>Edit files in html/ directory</p>' > html/index.html; \
	fi
	@if [ ! -f html/404.html ]; then \
		echo '<h1>404 - Not Found</h1><p>The page you are looking for does not exist.</p>' > html/404.html; \
	fi
	@if [ ! -f html/50x.html ]; then \
		echo '<h1>Server Error</h1><p>Something went wrong on the server.</p>' > html/50x.html; \
	fi
	@echo "✓ Directory structure created"
	@echo "✓ Default HTML files created"
	@echo "Run 'make start' to start the server"

# Start containers
start:
	@echo "Starting NGINX container..."
	@docker-compose up -d
	@echo "✓ NGINX started at http://localhost:8080"

# Stop containers
stop:
	@echo "Stopping NGINX container..."
	@docker-compose down
	@echo "✓ NGINX stopped"

# Restart containers
restart:
	@echo "Restarting NGINX container..."
	@docker-compose restart nginx
	@echo "✓ NGINX restarted"

# Show logs
logs:
	@echo "Showing NGINX logs (Ctrl+C to exit)..."
	@docker-compose logs -f nginx

# Show container status
status:
	@echo "Container status:"
	@docker-compose ps

# Test NGINX configuration
test:
	@echo "Testing NGINX configuration..."
	@docker-compose exec nginx nginx -t
	@echo "✓ Configuration test complete"

# Open shell in container
shell:
	@echo "Opening shell in NGINX container..."
	@docker-compose exec nginx sh

# Rebuild container
rebuild:
	@echo "Rebuilding NGINX container..."
	@docker-compose down
	@docker-compose up -d --build
	@echo "✓ NGINX rebuilt and started"

# Clean up everything
clean:
	@echo "Cleaning up containers and volumes..."
	@docker-compose down -v
	@docker system prune -f
	@echo "✓ Cleanup complete"

# Show access URLs
url:
	@echo "NGINX Access URLs:"
	@echo "==================="
	@echo "Main site:  http://localhost:8080"
	@echo "HTTPS:      https://localhost:8443"
	@echo "Files are served from: ./html/"

# Reload NGINX configuration
reload:
	@echo "Reloading NGINX configuration..."
	@docker-compose exec nginx nginx -s reload
	@echo "✓ Configuration reloaded"

# Quick development workflow
dev: setup start url

# Production-like start
prod: setup
	@echo "Starting NGINX in production mode..."
	@docker-compose up -d --remove-orphans
	@echo "✓ NGINX started in production mode"

# Health check
health:
	@echo "Checking NGINX health..."
	@curl -f http://localhost:8080 > /dev/null 2>&1 && echo "✓ NGINX is healthy" || echo "✗ NGINX is not responding"

# Show container info
info:
	@echo "Container Information:"
	@echo "====================="
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "Resource Usage:"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Backup configuration
backup:
	@echo "Creating configuration backup..."
	@tar -czf nginx-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz docker-compose.yml nginx.conf conf.d/ html/
	@echo "✓ Backup created"

# Update NGINX image
update:
	@echo "Updating NGINX image..."
	@docker-compose pull nginx
	@docker-compose up -d nginx
	@echo "✓ NGINX updated"