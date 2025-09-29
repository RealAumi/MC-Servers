# Troubleshooting Guide

This guide helps you diagnose and fix common issues with your Minecraft server setup.

## Quick Diagnosis

### Check Server Status
```bash
# View running containers
docker-compose ps

# Check server health
docker-compose exec mc mc-health

# View real-time logs
docker-compose logs -f mc
```

### Common Log Patterns
- `Server thread/INFO]: Done (X.XXXs)!` - Server started successfully
- `EULA=TRUE` - EULA accepted
- `Exception` or `Error` - Issues that need attention

## Connection Issues

### Can't Connect to Server

**Symptoms**: Connection timeout, "Can't reach server"

**Diagnosis**:
```bash
# Check if container is running
docker-compose ps

# Check port binding
docker port $(docker-compose ps -q mc)

# Test port connectivity (from another machine)
telnet <server-ip> <port>
```

**Solutions**:
1. **Verify server is running**:
   ```bash
   docker-compose logs mc | grep "Done"
   ```

2. **Check port configuration**:
   - Ensure `MC_PORT` in `.env` matches your client
   - Verify firewall allows the port
   - Check router port forwarding if hosting from home

3. **Verify network settings**:
   ```bash
   # Check if port is bound correctly
   docker-compose ps
   ```

### Authentication Issues

**Symptoms**: "Failed to verify username", "Authentication servers are down"

**Solutions**:
1. **For offline servers**: Set `ONLINE_MODE=false` in `.env`
2. **For online servers**: 
   - Verify internet connectivity
   - Check Mojang service status
   - Ensure correct username/password

## Performance Issues

### Server Lag

**Symptoms**: Slow block updates, delayed chat, high TPS

**Diagnosis**:
```bash
# Check resource usage
docker stats

# Check server TPS (in-game)
/tps

# Check memory usage
docker-compose exec mc free -h
```

**Solutions**:
1. **Increase memory allocation**:
   ```bash
   # In .env file
   MEMORY=4G  # Increase from 2G
   ```

2. **Optimize JVM settings** (already optimized in our configs)

3. **Reduce view distance**:
   ```bash
   # In .env file
   VIEW_DISTANCE=8  # Reduce from 10
   ```

4. **Check for resource-heavy plugins**

### High Memory Usage

**Symptoms**: Container using excessive RAM, OOM kills

**Solutions**:
1. **Monitor actual usage**:
   ```bash
   docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
   ```

2. **Adjust heap size**:
   ```bash
   # Don't exceed 80% of container memory
   MEMORY=4G  # For 5GB container limit
   ```

3. **Enable G1GC** (already enabled in our configs)

## Startup Issues

### Server Won't Start

**Symptoms**: Container exits immediately, restart loops

**Diagnosis**:
```bash
# Check exit code and logs
docker-compose logs mc

# Check environment variables
docker-compose config
```

**Common Causes & Solutions**:

1. **EULA not accepted**:
   ```bash
   # Ensure in .env or docker-compose.yml
   EULA=TRUE
   ```

2. **Invalid environment variables**:
   ```bash
   # Check for typos in .env
   # Validate enum values (DIFFICULTY, MODE, etc.)
   ```

3. **Insufficient permissions**:
   ```bash
   # Check volume permissions
   docker-compose down
   docker volume rm $(docker-compose ps -q)_data
   docker-compose up -d
   ```

4. **Port already in use**:
   ```bash
   # Check what's using the port
   sudo netstat -tlnp | grep :25565
   
   # Use different port
   MC_PORT=25566
   ```

### Container Keeps Restarting

**Symptoms**: Container restarts every few minutes

**Diagnosis**:
```bash
# Check restart count
docker-compose ps

# Check health check status
docker inspect $(docker-compose ps -q mc) | grep Health -A 20
```

**Solutions**:
1. **Check health check configuration**
2. **Increase startup timeout**
3. **Fix underlying startup issues**

## Data Issues

### Lost World Data

**Symptoms**: World reset, progress lost

**Prevention**:
```bash
# Regular backups
./scripts/manage.sh backup paper-latest

# Verify volume persistence
docker volume ls | grep data
```

**Recovery**:
1. **Check if data volume exists**:
   ```bash
   docker volume ls
   ```

2. **Restore from backup**:
   ```bash
   # Stop server
   docker-compose down
   
   # Restore data
   docker run --rm -v server_data:/data -v $(pwd):/backup alpine \
     tar xzf /backup/backup.tar.gz -C /data
   
   # Start server
   docker-compose up -d
   ```

### Configuration Not Applied

**Symptoms**: Settings in `.env` not taking effect

**Solutions**:
1. **Restart container after changes**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

2. **Check environment variable syntax**:
   ```bash
   # No spaces around =
   MEMORY=4G  # Correct
   MEMORY = 4G  # Wrong
   ```

3. **Verify environment is loaded**:
   ```bash
   docker-compose config
   ```

## Plugin Issues

### Plugins Not Loading

**Symptoms**: Features missing, plugin commands not working

**Solutions**:
1. **Check plugin directory mounting**:
   ```yaml
   # In docker-compose.yml
   volumes:
     - ./plugins:/data/plugins
   ```

2. **Verify plugin compatibility**:
   - Check Paper version compatibility
   - Look for dependency requirements

3. **Check plugin logs**:
   ```bash
   docker-compose logs mc | grep -i plugin
   ```

### Plugin Conflicts

**Symptoms**: Errors in logs, unexpected behavior

**Solutions**:
1. **Disable plugins one by one**
2. **Check plugin documentation** for known conflicts
3. **Update plugins** to latest versions

## Network Issues

### RCON Not Working

**Symptoms**: Can't connect with RCON client

**Solutions**:
1. **Verify RCON is enabled**:
   ```bash
   ENABLE_RCON=true
   ```

2. **Check RCON port**:
   ```bash
   RCON_PORT=25575
   ```

3. **Test RCON connection**:
   ```bash
   docker-compose exec mc rcon-cli
   ```

### Docker Network Issues

**Symptoms**: Container can't reach external resources

**Solutions**:
1. **Check Docker network**:
   ```bash
   docker network ls
   docker network inspect $(docker-compose ps -q)_default
   ```

2. **Restart Docker service**:
   ```bash
   sudo systemctl restart docker
   ```

## Resource Monitoring

### System Resource Check
```bash
# CPU and memory usage
htop

# Disk usage
df -h

# Docker resource usage
docker system df
```

### Server-Specific Monitoring
```bash
# Minecraft-specific metrics
docker-compose exec mc cat /data/logs/latest.log | grep TPS

# Java heap usage
docker-compose exec mc jstat -gc 1
```

## Getting Help

### Information to Collect
When seeking help, collect:
1. **Docker Compose logs**: `docker-compose logs mc`
2. **System information**: `docker info`
3. **Configuration**: `docker-compose config`
4. **Resource usage**: `docker stats`

### Useful Commands for Support
```bash
# Generate diagnostic report
echo "=== Docker Info ===" > debug.txt
docker info >> debug.txt
echo "=== Container Status ===" >> debug.txt
docker-compose ps >> debug.txt
echo "=== Container Logs ===" >> debug.txt
docker-compose logs --tail=100 mc >> debug.txt
echo "=== Environment ===" >> debug.txt
docker-compose config >> debug.txt
```

### Community Resources
- [itzg/docker-minecraft-server Documentation](https://github.com/itzg/docker-minecraft-server)
- [Paper MC Documentation](https://docs.papermc.io/)
- [Docker Documentation](https://docs.docker.com/)
- [Minecraft Server Administration Guides](https://minecraft.wiki/w/Tutorials/Setting_up_a_server)