# Paper Server (Latest Version)

This configuration provides a Paper Minecraft server using the latest available version. Paper is a high-performance fork of Spigot that includes additional optimizations and features.

## Features

- 🚀 Latest Paper server version
- ⚡ Optimized JVM settings for performance
- 🔧 Comprehensive environment-based configuration
- 📊 Built-in health checks
- 🔐 RCON support for remote administration
- 📦 Volume persistence for world data and logs

## Quick Setup

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your preferred settings:
   ```bash
   nano .env
   ```

3. Start the server:
   ```bash
   docker-compose up -d
   ```

4. Check server status:
   ```bash
   docker-compose logs -f mc
   ```

## Configuration Options

### Essential Settings

- `SERVER_NAME`: The name of your server
- `MOTD`: Message of the day shown in the server list
- `MAX_PLAYERS`: Maximum number of concurrent players
- `MEMORY`: RAM allocation (e.g., "2G", "4G", "8G")
- `RCON_PASSWORD`: Password for RCON access (change from default!)

### Network Settings

- `MC_PORT`: Minecraft server port (default: 25565)
- `RCON_PORT`: RCON port for administration (default: 25575)

### World Settings

- `LEVEL`: World name
- `SEED`: World seed (leave empty for random)
- `DIFFICULTY`: Game difficulty (peaceful, easy, normal, hard)
- `MODE`: Game mode (survival, creative, adventure, spectator)
- `VIEW_DISTANCE`: Server view distance (affects performance)

## Management Commands

### Start the server
```bash
docker-compose up -d
```

### Stop the server
```bash
docker-compose down
```

### View server logs
```bash
docker-compose logs -f mc
```

### Execute server commands
```bash
docker-compose exec mc rcon-cli
```

### Restart the server
```bash
docker-compose restart mc
```

### Update the server
```bash
docker-compose pull
docker-compose up -d
```

## Data Persistence

The server data is stored in Docker volumes:
- `mc_data`: Contains world data, plugins, configurations
- `mc_logs`: Contains server logs

## Plugin Installation

To install plugins:

1. Uncomment the plugins volume mount in `docker-compose.yml`
2. Create a `plugins` directory in this folder
3. Place your `.jar` plugin files in the `plugins` directory
4. Restart the server

## World Import

To use an existing world:

1. Uncomment the world volume mount in `docker-compose.yml`
2. Place your world folder in this directory
3. Set `LEVEL` in `.env` to match your world folder name
4. Restart the server

## Troubleshooting

### Server won't start
- Check Docker logs: `docker-compose logs mc`
- Verify environment variables in `.env`
- Ensure sufficient memory allocation

### Can't connect to server
- Verify `MC_PORT` is correctly set and not blocked by firewall
- Check if `ONLINE_MODE` is appropriate for your setup
- Ensure server has finished starting (check logs)

### Performance issues
- Increase `MEMORY` allocation
- Adjust `VIEW_DISTANCE` (lower = better performance)
- Monitor server resources: `docker stats`

## Security Notes

- **Change the default RCON password!**
- Use whitelist in production: set `WHITELIST` with player names
- Consider disabling RCON if not needed: `ENABLE_RCON=false`
- Use `ONLINE_MODE=true` for authentication unless using a proxy

## Paper-Specific Features

Paper includes several enhancements over vanilla Minecraft:
- Better performance optimizations
- Additional configuration options
- Plugin compatibility improvements
- Anti-cheat enhancements

For more information about Paper, visit: https://papermc.io/