# Migration Guide: Simplified Monitoring and Reverse Proxy Stack

This document outlines the migration from the complex monitoring and reverse proxy stack to the simplified modern alternatives.

## Overview of Changes

The DOJO stack has been significantly simplified to reduce complexity, resource usage, and maintenance overhead:

### Old Stack → New Stack
- **6-service monitoring stack** → **Single Netdata container**
- **2-service reverse proxy** → **Single Caddy container**

## Monitoring Stack Migration

### What Was Removed
- **Splunk** - Log aggregation and analysis
- **Prometheus** - Metrics collection
- **Grafana** - Metrics visualization dashboard
- **cAdvisor** - Container metrics collection
- **Node Exporter** - System metrics collection
- **Prometheus-generate-targets** - Dynamic target configuration

### Replacement: Netdata
Netdata provides all the functionality of the previous monitoring stack in a single container:
- **Real-time monitoring** - Live system and container metrics
- **Auto-discovery** - Automatically detects and monitors all containers
- **Zero configuration** - Works out of the box without config files
- **Web dashboard** - Built-in web interface on port 19999
- **Low resource usage** - Significantly lighter than the old stack

### Migration Steps
1. No manual migration required - Netdata automatically discovers existing containers
2. Access monitoring at `http://your-host:19999` (internal access only by default)
3. Remove old monitoring configuration files (see cleanup section below)

## Reverse Proxy Migration

### What Was Removed
- **nginx-proxy** - Nginx-based reverse proxy
- **acme-companion** - SSL certificate management companion

### Replacement: Caddy
Caddy combines reverse proxy and SSL management in a single modern container:
- **Automatic HTTPS** - Built-in Let's Encrypt integration
- **Zero configuration** - Configured via Docker labels
- **Modern architecture** - Memory-safe, efficient implementation
- **Automatic certificate renewal** - No manual certificate management

### Migration Steps
1. Set `VIRTUAL_HOST` environment variable in `.env` file
2. Caddy automatically handles SSL certificates and renewal
3. Remove old Nginx configuration files (see cleanup section below)

## Configuration Changes

### New Configuration Method
Instead of managing separate configuration files, everything is now configured through:
- **Docker Compose labels** - For reverse proxy configuration
- **Environment variables** - For domain configuration
- **Auto-discovery** - For monitoring (no configuration needed)

### Required Configuration
Create or update your `.env` file in the project root:
```bash
VIRTUAL_HOST=your-domain.com
```

This single variable configures:
- Caddy reverse proxy routing
- Automatic SSL certificate acquisition
- HTTP to HTTPS redirects

## Cleanup Instructions

### Safe to Remove
The following files and directories are no longer used and can be safely deleted:

#### Monitoring Configuration
```bash
# Remove Prometheus configuration
rm -rf prometheus/
rm -f prometheus.yml

# Remove Grafana configuration  
rm -rf grafana/
rm -f grafana/datasource.yml

# Remove Splunk configuration
rm -f /opt/pwn.college/splunk/default.yml
```

#### Reverse Proxy Configuration
```bash
# Remove Nginx configuration
rm -rf /nginx-proxy/etc/nginx/vhost.d/
rm -rf nginx-proxy/

# Remove ACME companion configuration
rm -rf acme-companion/
```

### Deprecated Configuration Variables
The following variables in `dojo-init` are deprecated but maintained for compatibility:
- `ENABLE_SPLUNK=false` (default) - Will be removed in future versions

## Benefits of the New Stack

### Resource Efficiency
- **Reduced memory usage** - Single containers instead of complex stacks
- **Lower CPU overhead** - More efficient modern implementations
- **Fewer containers** - Simpler container orchestration

### Operational Simplicity
- **Zero configuration** - Auto-discovery and auto-configuration
- **Automatic SSL** - No manual certificate management
- **Unified logging** - Simplified log collection and viewing

### Developer Experience
- **Faster startup** - Fewer services to initialize
- **Easier debugging** - Fewer moving parts
- **Modern tooling** - Built on current best practices

## Troubleshooting

### Monitoring Issues
- **Access Netdata dashboard**: Visit `http://your-host:19999`
- **Check container logs**: `docker logs netdata`
- **Verify auto-discovery**: Netdata should automatically detect all containers

### Reverse Proxy Issues
- **Check domain configuration**: Verify `VIRTUAL_HOST` in `.env` file
- **SSL certificate issues**: Check Caddy logs with `docker logs caddy`
- **Port conflicts**: Ensure ports 80 and 443 are available

### Migration Issues
- **Old containers still running**: Remove old monitoring containers manually
- **Configuration conflicts**: Ensure old config files are removed
- **DNS issues**: Verify domain points to correct IP address

## Support

For issues during migration:
1. Check container logs: `docker logs <container-name>`
2. Verify configuration: Review `.env` file and docker-compose.yml
3. Open an issue: Include logs and configuration details

The simplified stack provides the same functionality with significantly reduced complexity and resource requirements.
