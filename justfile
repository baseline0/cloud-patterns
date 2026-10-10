# Shared commit recipe from fleet-base. Literal path: just does not interpolate variables into import paths.
import "../fleet-base/src/fleet_base/justfiles/shared/commit.just"

# Cloud Patterns — local development recipes

# Show available recipes
@help:
    just --list

# === Local Development ===

# Fast iteration: Python HTTP server (local paths, no Docker)
@dev:
    echo "🚀 Starting development server on http://localhost:8000/"
    echo "   (Note: paths are root-relative, not /patterns/)"
    python -m http.server 8000

# Integrated review: Docker Compose (realistic paths, API proxy)
@up:
    echo "🚀 Starting gateway + API on http://localhost:8080/"
    docker compose up gateway api

# Start in background, show URLs
@up-bg:
    docker compose up -d gateway api
    echo "✅ Gateway started"
    echo "   - Patterns: http://localhost:8080/patterns/"
    echo "   - API:      http://localhost:8080/api/"
    echo "   - Health:   http://localhost:8080/healthz"

# Stop services
@down:
    docker compose down

# Health check
@check:
    #!/bin/bash
    echo "🔍 Running health checks..."
    curl -fsS http://localhost:8080/healthz && echo "✓ Gateway healthy" || echo "✗ Gateway down"
    curl -fsS http://localhost:8080/patterns/ > /dev/null && echo "✓ Patterns reachable" || echo "✗ Patterns 404"
    echo "Done."

# === Build & Preview ===

# View logs (for Docker Compose)
@logs:
    docker compose logs -f gateway api

# Restart services
@restart:
    docker compose restart

# Clean up Docker resources
@clean:
    docker compose down -v
    docker system prune -f

# === Testing & Validation ===

# Validate patterns.json schema and assets
@test:
    python tests/validate_patterns.py

# Validate + watch for changes
@test-watch:
    #!/bin/bash
    echo "Watching for changes..."
    while true; do
        clear
        python tests/validate_patterns.py || true
        sleep 2
        # Watch for changes in data/ directory
        inotifywait -e modify data/patterns.json assets/diagrams/*.svg 2>/dev/null || sleep 2
    done
