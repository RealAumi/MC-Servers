# Docker Compose Configuration Guide

This document provides detailed information about the Docker Compose configurations used in this repository.

## Base Configuration

All server configurations use the [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) Docker image, which provides:

- Easy server setup and management
- Support for multiple server types (Vanilla, Paper, Spigot, Forge, etc.)
- Automatic server updates
- Plugin and mod management
- Comprehensive configuration options

## Common Environment Variables

### Server Identification
- `SERVER_NAME`: Display name for the server
- `MOTD`: Message of the day shown in server browser

### Connection Settings
- `MC_PORT`: Minecraft server port (default: 25565)
- `RCON_PORT`: Remote console port (default: 25575)
- `ONLINE_MODE`: Enable Mojang authentication (true/false)

### Performance Settings
- `MEMORY`: RAM allocation (e.g., "2G", "4G", "8G")
- `JVM_OPTS`: Custom JVM arguments for optimization
- `VIEW_DISTANCE`: Render distance (affects performance)

### Game Configuration
- `DIFFICULTY`: Game difficulty (peaceful, easy, normal, hard)
- `MODE`: Default game mode (survival, creative, adventure, spectator)
- `MAX_PLAYERS`: Maximum concurrent players
- `PVP`: Enable player vs player combat
- `HARDCORE`: Enable hardcore mode (permanent death)

### World Settings
- `LEVEL`: World/level name
- `SEED`: World generation seed
- `GENERATE_STRUCTURES`: Generate villages, dungeons, etc.
- `ALLOW_NETHER`: Enable the Nether dimension
- `MAX_WORLD_SIZE`: Maximum world size in blocks

### Administrative
- `WHITELIST`: Comma-separated list of allowed players
- `OPS`: Comma-separated list of operators
- `ENABLE_RCON`: Enable remote console
- `RCON_PASSWORD`: Password for RCON access

## Volume Management

### Data Persistence
All configurations use named volumes for data persistence:
- `mc_data`: Contains world data, plugins, configurations
- `mc_logs`: Contains server logs (optional, for easier access)

### Benefits of Named Volumes
- Data persists across container updates
- Easy backup and restore
- Shared between container restarts
- Platform-independent storage

### Local Directory Mounting
You can also mount local directories for easier access:
```yaml
volumes:
  - ./world:/data/world        # Mount local world directory
  - ./plugins:/data/plugins    # Mount local plugins directory
  - ./config:/data/config      # Mount local config directory
```

## Network Configuration

### Default Setup
- Exposes Minecraft port (25565) and RCON port (25575)
- Creates isolated network for security
- Supports custom port mapping via environment variables

### Port Customization
```bash
# In .env file
MC_PORT=25566      # Use alternative port
RCON_PORT=25576    # Use alternative RCON port
```

## Health Checks

All configurations include health checks using the `mc-health` command:
- Checks server responsiveness every 30 seconds
- 2-minute startup grace period
- Automatic container restart on health failures

## Security Considerations

### RCON Security
- Always change the default RCON password
- Consider disabling RCON if not needed
- Limit RCON port exposure in production

### Authentication
- Use `ONLINE_MODE=true` for Mojang authentication
- Implement whitelist for private servers
- Monitor operator assignments

### Network Security
- Use reverse proxies for production deployments
- Implement firewall rules
- Consider VPN access for administration

## Performance Optimization

### Memory Allocation
- Minimum 2GB for basic servers
- 4-8GB recommended for modded servers
- Monitor actual usage with `docker stats`

### JVM Tuning
The configurations include optimized JVM arguments:
- G1 garbage collector for better performance
- Optimized for server workloads
- Reduced pause times

### View Distance
- Lower view distance = better performance
- 10 chunks is a good balance
- Adjust based on player count and hardware

## Backup Strategies

### Volume Backups
```bash
# Backup data volume
docker run --rm -v server_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/backup.tar.gz -C /data .
```

### Automated Backups
Consider implementing automated backup scripts:
- Schedule regular world saves
- Rotate old backups
- Store backups off-site

## Troubleshooting

### Common Issues

1. **Server won't start**
   - Check Docker logs: `docker-compose logs mc`
   - Verify environment variables
   - Ensure sufficient resources

2. **Connection issues**
   - Verify port configuration
   - Check firewall settings
   - Confirm server startup completion

3. **Performance problems**
   - Monitor resource usage
   - Adjust memory allocation
   - Reduce view distance
   - Check for plugin conflicts

### Debugging Tools
- `docker-compose logs -f mc`: Real-time logs
- `docker stats`: Resource usage
- `mc-health`: Server health check
- RCON: Remote command execution

## Updates and Maintenance

### Container Updates
```bash
docker-compose pull    # Download latest images
docker-compose up -d   # Restart with new images
```

### Configuration Changes
1. Stop the server: `docker-compose down`
2. Edit configuration files
3. Start the server: `docker-compose up -d`

### Plugin Updates
- Update plugins in mounted directory
- Restart server to load changes
- Monitor logs for compatibility issues

## Best Practices

1. **Always use environment files** for configuration
2. **Regular backups** of world data
3. **Monitor resource usage** and adjust accordingly
4. **Keep containers updated** for security
5. **Test configuration changes** in development first
6. **Document custom modifications** for team members