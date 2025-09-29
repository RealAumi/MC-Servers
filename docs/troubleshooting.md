# 故障排除指南

本指南帮助您诊断和修复 Minecraft 服务器设置中的常见问题。

## 快速诊断

### 检查服务器状态
```bash
# 查看运行中的容器
docker-compose ps

# 检查服务器健康状态
docker-compose exec mc mc-health

# 查看实时日志
docker-compose logs -f mc
```

### 常见日志模式
- `Server thread/INFO]: Done (X.XXXs)!` - 服务器启动成功
- `EULA=TRUE` - EULA 已接受
- `Exception` 或 `Error` - 需要注意的问题

## 连接问题

### 无法连接到服务器

**症状**: 连接超时，"无法连接到服务器"

**诊断**:
```bash
# 检查容器是否运行
docker-compose ps

# 检查端口绑定
docker port $(docker-compose ps -q mc)

# 测试端口连接（从另一台机器）
telnet <服务器IP> <端口>
```

**解决方案**:
1. **验证服务器正在运行**:
   ```bash
   docker-compose logs mc | grep "Done"
   ```

2. **检查端口配置**:
   - 确保 `.env` 中的 `MC_PORT` 与您的客户端匹配
   - 验证防火墙允许该端口
   - 如果从家中托管，检查路由器端口转发

3. **验证网络设置**:
   ```bash
   # 检查端口是否正确绑定
   docker-compose ps
   ```

### 身份验证问题

**症状**: "验证用户名失败"，"身份验证服务器离线"

**解决方案**:
1. **离线服务器**: 在 `.env` 中设置 `ONLINE_MODE=false`
2. **在线服务器**: 
   - 验证互联网连接
   - 检查 Mojang 服务状态
   - 确保用户名/密码正确

## 性能问题

### 服务器延迟

**症状**: 方块更新缓慢，聊天延迟，高 TPS

**诊断**:
```bash
# 检查资源使用情况
docker stats

# 检查服务器 TPS（游戏内）
/tps

# 检查内存使用情况
docker-compose exec mc free -h
```

**解决方案**:
1. **增加内存分配**:
   ```bash
   # 在 .env 文件中
   MEMORY=4G  # 从 2G 增加
   ```

2. **优化 JVM 设置**（我们的配置中已优化）

3. **降低视距**:
   ```bash
   # 在 .env 文件中
   VIEW_DISTANCE=8  # 从 10 降低
   ```

4. **检查资源密集型插件**

### 高内存使用

**症状**: 容器使用过多 RAM，OOM 杀死

**解决方案**:
1. **监控实际使用情况**:
   ```bash
   docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
   ```

2. **调整堆大小**:
   ```bash
   # 不要超过容器内存的 80%
   MEMORY=4G  # 对于 5GB 容器限制
   ```

3. **启用 G1GC**（我们的配置中已启用）

## 启动问题

### 服务器无法启动

**症状**: 容器立即退出，重启循环

**诊断**:
```bash
# 检查退出代码和日志
docker-compose logs mc

# 检查环境变量
docker-compose config
```

**常见原因和解决方案**:

1. **EULA 未接受**:
   ```bash
   # 确保在 .env 或 docker-compose.yml 中
   EULA=TRUE
   ```

2. **无效的环境变量**:
   ```bash
   # 检查 .env 中的拼写错误
   # 验证枚举值（DIFFICULTY、MODE 等）
   ```

3. **权限不足**:
   ```bash
   # 检查卷权限
   docker-compose down
   docker volume rm $(docker-compose ps -q)_data
   docker-compose up -d
   ```

4. **端口已被使用**:
   ```bash
   # 检查什么在使用端口
   sudo netstat -tlnp | grep :25565
   
   # 使用不同端口
   MC_PORT=25566
   ```

### 容器持续重启

**症状**: 容器每隔几分钟重启

**诊断**:
```bash
# 检查重启次数
docker-compose ps

# 检查健康检查状态
docker inspect $(docker-compose ps -q mc) | grep Health -A 20
```

**解决方案**:
1. **检查健康检查配置**
2. **增加启动超时**
3. **修复潜在的启动问题**

## 数据问题

### 丢失世界数据

**症状**: 世界重置，进度丢失

**预防**:
```bash
# 定期备份
./scripts/manage.sh backup paper-latest

# 验证卷持久化
docker volume ls | grep data
```

**恢复**:
1. **检查数据卷是否存在**:
   ```bash
   docker volume ls
   ```

2. **从备份恢复**:
   ```bash
   # 停止服务器
   docker-compose down
   
   # 恢复数据
   docker run --rm -v server_data:/data -v $(pwd):/backup alpine \
     tar xzf /backup/backup.tar.gz -C /data
   
   # 启动服务器
   docker-compose up -d
   ```

### 配置未生效

**症状**: `.env` 中的设置未生效

**解决方案**:
1. **更改后重启容器**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

2. **检查环境变量语法**:
   ```bash
   # = 周围不要有空格
   MEMORY=4G  # 正确
   MEMORY = 4G  # 错误
   ```

3. **验证环境已加载**:
   ```bash
   docker-compose config
   ```

## 插件问题

### 插件未加载

**症状**: 功能缺失，插件命令不工作

**解决方案**:
1. **检查插件目录挂载**:
   ```yaml
   # 在 docker-compose.yml 中
   volumes:
     - ./plugins:/data/plugins
   ```

2. **验证插件兼容性**:
   - 检查 Paper 版本兼容性
   - 查看依赖要求

3. **检查插件日志**:
   ```bash
   docker-compose logs mc | grep -i plugin
   ```

### 插件冲突

**症状**: 日志中出现错误，异常行为

**解决方案**:
1. **逐一禁用插件**
2. **检查插件文档**了解已知冲突
3. **更新插件**到最新版本

## 网络问题

### RCON 不工作

**症状**: 无法使用 RCON 客户端连接

**解决方案**:
1. **验证 RCON 已启用**:
   ```bash
   ENABLE_RCON=true
   ```

2. **检查 RCON 端口**:
   ```bash
   RCON_PORT=25575
   ```

3. **测试 RCON 连接**:
   ```bash
   docker-compose exec mc rcon-cli
   ```

### Docker 网络问题

**症状**: 容器无法访问外部资源

**解决方案**:
1. **检查 Docker 网络**:
   ```bash
   docker network ls
   docker network inspect $(docker-compose ps -q)_default
   ```

2. **重启 Docker 服务**:
   ```bash
   sudo systemctl restart docker
   ```

## 资源监控

### 系统资源检查
```bash
# CPU 和内存使用情况
htop

# 磁盘使用情况
df -h

# Docker 资源使用情况
docker system df
```

### 服务器特定监控
```bash
# Minecraft 特定指标
docker-compose exec mc cat /data/logs/latest.log | grep TPS

# Java 堆使用情况
docker-compose exec mc jstat -gc 1
```

## 获取帮助

### 需要收集的信息
寻求帮助时，请收集：
1. **Docker Compose 日志**: `docker-compose logs mc`
2. **系统信息**: `docker info`
3. **配置**: `docker-compose config`
4. **资源使用情况**: `docker stats`

### 支持有用的命令
```bash
# 生成诊断报告
echo "=== Docker 信息 ===" > debug.txt
docker info >> debug.txt
echo "=== 容器状态 ===" >> debug.txt
docker-compose ps >> debug.txt
echo "=== 容器日志 ===" >> debug.txt
docker-compose logs --tail=100 mc >> debug.txt
echo "=== 环境 ===" >> debug.txt
docker-compose config >> debug.txt
```

### 社区资源
- [itzg/docker-minecraft-server 文档](https://github.com/itzg/docker-minecraft-server)
- [Paper MC 文档](https://docs.papermc.io/)
- [Docker 文档](https://docs.docker.com/)
- [Minecraft 服务器管理指南](https://minecraft.wiki/w/Tutorials/Setting_up_a_server)