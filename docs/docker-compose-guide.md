# Docker Compose 配置指南

本文档提供了此仓库中使用的 Docker Compose 配置的详细信息。

## 基础配置

所有服务器配置都使用 [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) Docker 镜像，该镜像提供：

- 简单的服务器设置和管理
- 支持多种服务器类型（原版、Paper、Spigot、Forge 等）
- 自动服务器更新
- 插件和模组管理
- 全面的配置选项

## 常用环境变量

### 服务器标识
- `SERVER_NAME`: 服务器的显示名称
- `MOTD`: 在服务器浏览器中显示的每日消息

### 连接设置
- `MC_PORT`: Minecraft 服务器端口（默认：25565）
- `RCON_PORT`: 远程控制台端口（默认：25575）
- `ONLINE_MODE`: 启用 Mojang 身份验证（true/false）

### 性能设置
- `MEMORY`: 内存分配（例如："2G"、"4G"、"8G"）
- `JVM_OPTS`: 用于优化的自定义 JVM 参数
- `VIEW_DISTANCE`: 渲染距离（影响性能）

### 游戏配置
- `DIFFICULTY`: 游戏难度（peaceful、easy、normal、hard）
- `MODE`: 默认游戏模式（survival、creative、adventure、spectator）
- `MAX_PLAYERS`: 最大并发玩家数
- `PVP`: 启用玩家对战
- `HARDCORE`: 启用极限模式（永久死亡）

### 世界设置
- `LEVEL`: 世界/关卡名称
- `SEED`: 世界生成种子
- `GENERATE_STRUCTURES`: 生成村庄、地牢等
- `ALLOW_NETHER`: 启用下界维度
- `MAX_WORLD_SIZE`: 最大世界大小（以方块为单位）

### 管理设置
- `WHITELIST`: 允许的玩家的逗号分隔列表
- `OPS`: 管理员的逗号分隔列表
- `ENABLE_RCON`: 启用远程控制台
- `RCON_PASSWORD`: RCON 访问密码

## 数据卷管理

### 数据持久化
所有配置都使用命名卷进行数据持久化：
- `mc_data`: 包含世界数据、插件、配置
- `mc_logs`: 包含服务器日志（可选，便于访问）

### 命名卷的优势
- 数据在容器更新时保持不变
- 易于备份和恢复
- 在容器重启之间共享
- 平台无关的存储

### 本地目录挂载
您也可以挂载本地目录以便于访问：
```yaml
volumes:
  - ./world:/data/world        # 挂载本地世界目录
  - ./plugins:/data/plugins    # 挂载本地插件目录
  - ./config:/data/config      # 挂载本地配置目录
```

## 网络配置

### 默认设置
- 暴露 Minecraft 端口（25565）和 RCON 端口（25575）
- 为安全创建隔离网络
- 通过环境变量支持自定义端口映射

### 端口自定义
```bash
# 在 .env 文件中
MC_PORT=25566      # 使用替代端口
RCON_PORT=25576    # 使用替代 RCON 端口
```

## 健康检查

所有配置都包含使用 `mc-health` 命令的健康检查：
- 每 30 秒检查服务器响应性
- 2 分钟启动宽限期
- 健康检查失败时自动重启容器

## 安全考虑

### RCON 安全
- 始终更改默认的 RCON 密码
- 如果不需要，考虑禁用 RCON
- 在生产环境中限制 RCON 端口暴露

### 身份验证
- 使用 `ONLINE_MODE=true` 进行 Mojang 身份验证
- 为私人服务器实施白名单
- 监控管理员分配

### 网络安全
- 在生产部署中使用反向代理
- 实施防火墙规则
- 考虑 VPN 访问进行管理

## 性能优化

### 内存分配
- 基础服务器最少 2GB
- 模组服务器推荐 4-8GB
- 使用 `docker stats` 监控实际使用情况

### JVM 调优
配置包含优化的 JVM 参数：
- G1 垃圾收集器以获得更好的性能
- 针对服务器工作负载进行优化
- 减少暂停时间

### 视距
- 较低的视距 = 更好的性能
- 10 个区块是一个很好的平衡
- 根据玩家数量和硬件进行调整

## 备份策略

### 数据卷备份
```bash
# 备份数据卷
docker run --rm -v server_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/backup.tar.gz -C /data .
```

### 自动备份
考虑实施自动备份脚本：
- 定期安排世界保存
- 轮换旧备份
- 异地存储备份

## 故障排除

### 常见问题

1. **服务器无法启动**
   - 检查 Docker 日志：`docker-compose logs mc`
   - 验证环境变量
   - 确保有足够的资源

2. **连接问题**
   - 验证端口配置
   - 检查防火墙设置
   - 确认服务器启动完成

3. **性能问题**
   - 监控资源使用情况
   - 调整内存分配
   - 降低视距
   - 检查插件冲突

### 调试工具
- `docker-compose logs -f mc`: 实时日志
- `docker stats`: 资源使用情况
- `mc-health`: 服务器健康检查
- RCON: 远程命令执行

## 更新和维护

### 容器更新
```bash
docker-compose pull    # 下载最新镜像
docker-compose up -d   # 使用新镜像重启
```

### 配置更改
1. 停止服务器：`docker-compose down`
2. 编辑配置文件
3. 启动服务器：`docker-compose up -d`

### 插件更新
- 在挂载目录中更新插件
- 重启服务器以加载更改
- 监控日志以查看兼容性问题

## 最佳实践

1. **始终使用环境文件**进行配置
2. **定期备份**世界数据
3. **监控资源使用情况**并相应调整
4. **保持容器更新**以确保安全
5. **在开发环境中测试配置更改**
6. **为团队成员记录自定义修改**