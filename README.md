# MC-Servers

此仓库托管 Minecraft 服务器相关的脚本和 Docker 配置，主要维护基于 [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) 镜像的 Docker Compose 设置。

## 功能特性

- 🐳 适用于各种 Minecraft 服务器类型的 Docker Compose 配置
- 📦 预配置的 Paper 服务器设置（最新版本）
- 🛠️ 便于服务器部署的管理脚本
- 📋 基于环境变量的不同设置配置

## 服务器配置

### Paper 服务器（最新版）
一个现代化的 Paper 服务器设置，使用最新版本，针对性能和插件兼容性进行了优化。

**位置**: `paper-latest/`

## 快速开始

1. 选择一个服务器配置目录
2. 复制示例环境文件：`cp .env.example .env`
3. 使用你的首选设置编辑 `.env` 文件
4. 启动服务器：`docker-compose up -d`

## 目录结构

```
.
├── paper-latest/           # 最新 Paper 服务器配置
│   ├── docker-compose.yml
│   ├── .env.example
│   └── README.md
├── scripts/               # 管理和实用程序脚本
└── docs/                 # 附加文档
```

## 系统要求

- Docker
- Docker Compose
- 至少 2GB 内存用于 Minecraft 服务器

## 配置说明

每个服务器配置包括：
- 带有优化设置的 Docker Compose 文件
- 便于自定义的环境文件模板
- 服务器特定的文档

## 贡献

欢迎贡献额外的服务器配置、对现有设置的改进或有用的管理脚本。