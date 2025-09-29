# Paper 服务器（最新版本）

此配置提供使用最新可用版本的 Paper Minecraft 服务器。Paper 是 Spigot 的高性能分支，包含额外的优化和功能。

## 功能特性

- 🚀 最新 Paper 服务器版本
- ⚡ 针对性能优化的 JVM 设置
- 🔧 全面的基于环境变量的配置
- 📊 内置健康检查
- 🔐 支持远程管理的 RCON
- 📦 世界数据和日志的卷持久化

## 快速设置

1. 复制环境模板：
   ```bash
   cp .env.example .env
   ```

2. 使用您的首选设置编辑 `.env` 文件：
   ```bash
   nano .env
   ```

3. 启动服务器：
   ```bash
   docker-compose up -d
   ```

4. 检查服务器状态：
   ```bash
   docker-compose logs -f mc
   ```

## 配置选项

### 基本设置

- `SERVER_NAME`: 您的服务器名称
- `MOTD`: 在服务器列表中显示的每日消息
- `MAX_PLAYERS`: 最大并发玩家数
- `MEMORY`: 内存分配（例如："2G"、"4G"、"8G"）
- `RCON_PASSWORD`: RCON 访问密码（请更改默认值！）

### 网络设置

- `MC_PORT`: Minecraft 服务器端口（默认：25565）
- `RCON_PORT`: 管理用 RCON 端口（默认：25575）

### 世界设置

- `LEVEL`: 世界名称
- `SEED`: 世界种子（留空为随机）
- `DIFFICULTY`: 游戏难度（peaceful、easy、normal、hard）
- `MODE`: 游戏模式（survival、creative、adventure、spectator）
- `VIEW_DISTANCE`: 服务器视距（影响性能）

## 管理命令

### 启动服务器
```bash
docker-compose up -d
```

### 停止服务器
```bash
docker-compose down
```

### 查看服务器日志
```bash
docker-compose logs -f mc
```

### 执行服务器命令
```bash
docker-compose exec mc rcon-cli
```

### 重启服务器
```bash
docker-compose restart mc
```

### 更新服务器
```bash
docker-compose pull
docker-compose up -d
```

## 数据持久化

服务器数据存储在 Docker 卷中：
- `mc_data`: 包含世界数据、插件、配置
- `mc_logs`: 包含服务器日志

## 插件安装

安装插件的步骤：

1. 在 `docker-compose.yml` 中取消注释插件卷挂载
2. 在此文件夹中创建 `plugins` 目录
3. 将您的 `.jar` 插件文件放入 `plugins` 目录
4. 重启服务器

## 世界导入

使用现有世界：

1. 在 `docker-compose.yml` 中取消注释世界卷挂载
2. 将您的世界文件夹放在此目录中
3. 在 `.env` 中设置 `LEVEL` 以匹配您的世界文件夹名称
4. 重启服务器

## 故障排除

### 服务器无法启动
- 检查 Docker 日志：`docker-compose logs mc`
- 验证 `.env` 中的环境变量
- 确保有足够的内存分配

### 无法连接到服务器
- 验证 `MC_PORT` 设置正确且未被防火墙阻止
- 检查 `ONLINE_MODE` 是否适合您的设置
- 确保服务器已完成启动（检查日志）

### 性能问题
- 增加 `MEMORY` 分配
- 调整 `VIEW_DISTANCE`（更低 = 更好的性能）
- 监控服务器资源：`docker stats`

## 安全注意事项

- **更改默认的 RCON 密码！**
- 在生产环境中使用白名单：设置 `WHITELIST` 包含玩家名称
- 如果不需要，考虑禁用 RCON：`ENABLE_RCON=false`
- 除非使用代理，否则使用 `ONLINE_MODE=true` 进行身份验证

## Paper 特有功能

Paper 相比原版 Minecraft 包含多项增强：
- 更好的性能优化
- 额外的配置选项
- 插件兼容性改进
- 反作弊增强

有关 Paper 的更多信息，请访问：https://papermc.io/