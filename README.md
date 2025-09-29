# MC-Servers

This repository hosts Minecraft server-related scripts and Docker configurations, primarily maintaining Docker Compose setups for the [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) image.

## Features

- 🐳 Docker Compose configurations for various Minecraft server types
- 📦 Pre-configured Paper server setup (latest version)
- 🛠️ Management scripts for easy server deployment
- 📋 Environment-based configuration for different setups

## Server Configurations

### Paper Server (Latest)
A modern Paper server setup with the latest version, optimized for performance and plugin compatibility.

**Location**: `paper-latest/`

## Quick Start

1. Choose a server configuration directory
2. Copy the example environment file: `cp .env.example .env`
3. Edit the `.env` file with your preferred settings
4. Start the server: `docker-compose up -d`

## Directory Structure

```
.
├── paper-latest/           # Latest Paper server configuration
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── scripts/               # Management and utility scripts
└── docs/                 # Additional documentation
```

## Requirements

- Docker
- Docker Compose
- At least 2GB RAM for the Minecraft server

## Configuration

Each server configuration includes:
- Docker Compose file with optimized settings
- Environment file template for easy customization
- Server-specific documentation

## Contributing

Feel free to contribute additional server configurations, improvements to existing setups, or useful management scripts.