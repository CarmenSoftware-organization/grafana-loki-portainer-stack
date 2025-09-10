# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Docker-based observability stack combining:
- **Grafana**: Visualization and dashboards (port 3999)
- **Loki**: Log aggregation system (port 3998) 
- **Promtail**: Log collector for system and Docker logs

The stack uses environment variable-based configuration with two identical deployment options: `docker-compose.yml` for local development and `portainer-stack.yml` for Portainer deployment.

## Common Commands

### Stack Management
```bash
# Start the entire stack
docker-compose up -d

# Stop the stack
docker-compose down

# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs grafana
docker-compose logs loki
docker-compose logs promtail

# Check service status
docker-compose ps

# Restart specific service
docker-compose restart grafana
```

### Data Management
```bash
# Create required data directories
mkdir -p data/grafana data/loki

# Backup data
tar -czf grafana-backup-$(date +%Y%m%d).tar.gz data/grafana/
tar -czf loki-backup-$(date +%Y%m%d).tar.gz data/loki/
```

## Configuration

### Environment Variables
Configuration is managed via `.env` file (use `env.example` as template):
- **GRAFANA_PORT**: Default 3999
- **LOKI_PORT**: Default 3998  
- **GRAFANA_ADMIN_USER/PASSWORD**: Admin credentials
- **NETWORK_NAME**: Docker network name (default: grafana-stack)
- **DATA_PATHS**: Local data persistence paths

### Service Access
- Grafana: http://localhost:3999 (admin/admin123)
- Loki API: http://localhost:3998

### Configuration Files
- `configs/loki-config.yml`: Loki storage and retention settings
- `configs/promtail-config.yml`: Log collection sources and parsing (currently commented out)
- `configs/grafana-datasources.yml`: Pre-configured Loki data source
- `configs/grafana-dashboards.yml`: Dashboard provisioning
- `dashboards/`: JSON dashboard definitions

## Key Implementation Details

### Dual Deployment Support
The repository maintains identical configurations in:
- `docker-compose.yml`: For local Docker Compose
- `portainer-stack.yml`: For Portainer stack deployment

Both files must be kept in sync when making changes.

### Network Architecture
All services run on a single Docker bridge network (`grafana-stack` by default) for internal communication. Only Grafana and Loki expose external ports.

### Data Persistence
- Grafana data: `./data/grafana` → `/var/lib/grafana`
- Loki data: `./data/loki` → `/loki`

### Promtail Configuration
Currently uses minimal configuration with custom config file commented out. Collects:
- System logs from `/var/log`
- Docker container logs
- Access to Docker socket for container discovery

## Development Notes

When modifying the stack:
1. Update both `docker-compose.yml` and `portainer-stack.yml` 
2. Test environment variable interpolation
3. Ensure data directory permissions are correct
4. Verify network connectivity between services
5. Update `.env` and `env.example` if adding new variables