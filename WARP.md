# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Architecture Overview

This repository contains a containerized observability stack consisting of three main components:

- **Grafana** (port 3999): Dashboard and visualization platform for log analysis
- **Loki** (port 3998): Log aggregation system that stores and indexes logs
- **Promtail**: Log collector that ships logs from various sources to Loki

The stack uses Docker networking with an isolated `grafana-stack` bridge network and persistent volumes for data storage. Two deployment methods are supported: direct Docker Compose and Portainer stack deployment.

## Common Commands

### Stack Management
```bash
# Start the complete stack
./manage-stack.sh start

# Stop the stack  
./manage-stack.sh stop

# Restart all services
./manage-stack.sh restart

# Check service status
./manage-stack.sh status

# Direct Docker Compose commands
docker-compose up -d
docker-compose down
docker-compose ps
```

### Logs and Debugging
```bash
# View logs for all services
./manage-stack.sh logs

# View logs for specific service
./manage-stack.sh logs grafana
./manage-stack.sh logs loki
./manage-stack.sh logs promtail

# Follow logs in real-time
docker-compose logs -f
docker-compose logs -f grafana
```

### Data Management
```bash
# Backup data volumes
./manage-stack.sh backup

# Manual data backup
tar -czf grafana-backup-$(date +%Y%m%d).tar.gz data/grafana/
tar -czf loki-backup-$(date +%Y%m%d).tar.gz data/loki/

# Create required directories with permissions
mkdir -p data/grafana data/loki
sudo chown -R 472:472 data/grafana      # Grafana user
sudo chown -R 10001:10001 data/loki     # Loki user
```

### Configuration Management
```bash
# Restart services after config changes
docker-compose restart grafana
docker-compose restart loki
docker-compose restart promtail

# Validate Docker Compose configuration
docker-compose config

# Apply new dashboard (place .json in dashboards/ directory)
docker-compose restart grafana
```

## Key Configuration Files

- `docker-compose.yml`: Main stack definition for local development
- `portainer-stack.yml`: Alternative stack for Portainer deployment 
- `configs/loki-config.yml`: Loki storage, retention, and performance settings
- `configs/promtail-config.yml`: Log collection sources and parsing rules
- `configs/grafana-datasources.yml`: Grafana data source provisioning
- `configs/grafana-dashboards.yml`: Dashboard provisioning configuration
- `dashboards/*.json`: Dashboard definitions auto-imported by Grafana

## Service Access

- **Grafana Web UI**: http://localhost:3999 (admin/admin123)
- **Loki API**: http://localhost:3998
- **Internal Loki URL**: `http://loki:3100` (for Grafana data source)
- **Promtail Metrics**: http://localhost:9080/metrics

## Deployment Methods

### Docker Compose (Development)
Standard approach using `docker-compose.yml` with volume mounts for configurations and data persistence.

### Portainer Stack (Production) 
Uses `portainer-stack.yml` with external configs and managed volumes. Requires pre-creating configuration objects in Portainer.

## Log Sources Supported

Promtail is configured to collect from:
- System logs (`/var/log/*`)
- Docker container logs (with `logging=promtail` label)
- Nginx logs (`/var/log/nginx/*`)
- Apache logs (`/var/log/apache2/*`) 
- Systemd journal logs
- File-based service discovery (`/etc/promtail/targets.json`)

## Data Persistence

- **Grafana data**: `data/grafana/` or `grafana-data` volume
- **Loki data**: `data/loki/` or `loki-data` volume  
- **Configuration files**: `configs/` directory mounted read-only
- **Dashboards**: `dashboards/` directory auto-provisioned

## Security Notes

- Default Grafana credentials: admin/admin123 (change in production)
- Services communicate over isolated Docker network
- Only Grafana and Loki ports are exposed to host
- Log files mounted read-only for security
- Docker socket access required for container log collection

## Performance Tuning

Key settings in `loki-config.yml`:
- Chunk retention and aging policies
- Query result caching (100MB embedded cache)
- Log retention period (currently unlimited)
- WAL enabled for data durability

## Common Issues

- **Permission errors**: Ensure data directories have correct ownership
- **Missing logs**: Check Promtail configuration and file permissions
- **High memory usage**: Adjust retention policies and cache sizes
- **Connection failures**: Verify Docker network and service dependencies
