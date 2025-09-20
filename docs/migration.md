# Migration Guide: Simplified Monitoring and Reverse Proxy Stack

This document outlines the migration from the complex monitoring and reverse proxy stack to the simplified modern alternatives.

## Overview of Changes

The DOJO stack has been significantly simplified to reduce complexity, resource usage, and maintenance overhead.

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
2. Access monitoring at `http://your-host:80/_netdata` (internal access only by default)
3. Remove old monitoring configuration files (see cleanup section below)
