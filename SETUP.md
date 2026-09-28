# Cloud Patterns — Local Development Setup

Quick start for reviewing and developing the cloud architecture patterns catalogue.

---

## Quick Start (5 minutes)

### Option 1: Fast Iteration (HTML/SVG edits)

```bash
cd /home/mark/projects/web-apps/cloud-patterns
just dev
```

Then visit: **`http://localhost:8000/`**

**Use when:** Editing pattern descriptions, SVG diagrams, CSS styling  
**Advantage:** Instant reload, no Docker overhead  
**Note:** Root path is `/`, not `/patterns/` (adjust `<base href>` or test relative URLs)

### Option 2: Integrated Review (Realistic paths)

```bash
just up
```

Then visit:
- **Patterns:** `http://localhost:8080/patterns/`
- **API:** `http://localhost:8080/api/` (future)
- **Health:** `http://localhost:8080/healthz`

**Use when:** Final review, demo, testing API integration  
**Advantage:** Matches production path structure

---

## Architecture

```
Browser (localhost:8080)
  │
  └── Nginx Reverse Proxy (gateway)
        ├── /patterns/   → cloud-patterns/ (static files)
        ├── /api/        → uvicorn backend (future)
        └── /healthz     → health check

Layer 0 (Shared):
  ../../infrastructure/nginx/nginx.conf  ← Reverse proxy config

Layer 1 (This Project):
  ./docker-compose.yml                   ← Services
  ./index.html                           ← Static site
  ./data/patterns.json
  ./assets/diagrams/
```

---

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Local services (Nginx, API) |
| `justfile` | Quick commands (just dev, just up, just down) |
| `index.html` | Catalogue homepage |
| `data/patterns.json` | Pattern definitions |
| `assets/diagrams/*.svg` | Architecture diagrams |

---

## Available Commands

```bash
just dev              # Start Python server (fast iteration)
just up               # Start Docker Compose (integrated review)
just up-bg            # Start Docker in background
just down             # Stop services
just check            # Run health checks
just logs             # View live logs
just restart          # Restart services
just clean            # Remove Docker containers/volumes
```

---

## Static Site Best Practices

### Use Relative URLs

✅ **Good:**
```html
<script src="./app.js"></script>
<img src="./assets/diagrams/pattern.svg" alt="...">
```

❌ **Bad:**
```html
<script src="/app.js"></script>
<img src="/assets/diagrams/pattern.svg" alt="...">
```

### Or use `<base href>`

```html
<head>
  <base href="/patterns/">
</head>
<body>
  <script src="app.js"></script>
  <img src="assets/diagrams/pattern.svg" alt="...">
</body>
```

---

## Adding More Pattern Catalogues

Once `math-trace` and `equations-history` are built:

1. Add volumes to `docker-compose.yml`:
   ```yaml
   - ../math-trace:/usr/share/nginx/html/math-trace:ro
   - ../equations-history:/usr/share/nginx/html/equations:ro
   ```

2. Uncomment location blocks in `../../infrastructure/nginx/nginx.conf`

3. Restart: `just restart`

---

## Troubleshooting

**Port 8080 already in use:**
```bash
lsof -i :8080
kill -9 <PID>
```

**Nginx config error:**
```bash
docker compose logs gateway
```

**Static files not found:**
- Check relative URLs in HTML
- Verify volume mount in `docker-compose.yml`
- Ensure file exists in `./` (cloud-patterns root)

---

## Next Steps

1. ✅ Review one pattern locally: `just up`
2. ✅ Iterate on SVG diagrams or descriptions
3. ✅ Build remaining three patterns (Strangler, Circuit Breaker, Event-Driven)
4. ✅ Deploy to staging/production

---

**Questions?** See `../../infrastructure/README.md` for layer-0 architecture details.
