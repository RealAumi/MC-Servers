#!/bin/bash

# MC-Servers 管理脚本
# 为 Minecraft 服务器管理提供常用操作

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 输出颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印彩色输出的函数
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 列出可用服务器配置的函数
list_servers() {
    print_info "可用的服务器配置："
    for dir in "$PROJECT_ROOT"/*/; do
        if [[ -f "$dir/docker-compose.yml" ]]; then
            basename="$(basename "$dir")"
            echo "  - $basename"
        fi
    done
}

# 验证服务器配置是否存在的函数
validate_server() {
    local server="$1"
    local server_path="$PROJECT_ROOT/$server"
    
    if [[ ! -d "$server_path" ]]; then
        print_error "服务器配置 '$server' 未找到"
        list_servers
        exit 1
    fi
    
    if [[ ! -f "$server_path/docker-compose.yml" ]]; then
        print_error "在 '$server' 中未找到 docker-compose.yml"
        exit 1
    fi
}

# 启动服务器的函数
start_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "启动服务器：$server"
    
    cd "$server_path"
    
    # 检查 .env 是否存在，如果不存在则从示例复制
    if [[ ! -f ".env" && -f ".env.example" ]]; then
        print_warning "未找到 .env 文件，从 .env.example 复制"
        cp ".env.example" ".env"
        print_warning "请在启动服务器前编辑 .env 文件以设置您的配置"
        exit 1
    fi
    
    docker-compose up -d
    print_success "服务器 '$server' 启动成功"
    print_info "使用 'docker-compose logs -f mc' 查看日志"
}

# 停止服务器的函数
stop_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "停止服务器：$server"
    
    cd "$server_path"
    docker-compose down
    print_success "服务器 '$server' 停止成功"
}

# 重启服务器的函数
restart_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "重启服务器：$server"
    
    cd "$server_path"
    docker-compose restart
    print_success "服务器 '$server' 重启成功"
}

# 查看服务器日志的函数
logs_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "显示服务器日志：$server"
    
    cd "$server_path"
    docker-compose logs -f mc
}

# 显示服务器状态的函数
status_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "服务器状态：$server"
    
    cd "$server_path"
    docker-compose ps
}

# 更新服务器的函数
update_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "更新服务器：$server"
    
    cd "$server_path"
    docker-compose pull
    docker-compose up -d
    print_success "服务器 '$server' 更新成功"
}

# 备份服务器数据的函数
backup_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    local backup_dir="$PROJECT_ROOT/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/${server}_backup_${timestamp}.tar.gz"
    
    print_info "为服务器创建备份：$server"
    
    mkdir -p "$backup_dir"
    
    cd "$server_path"
    
    # 停止服务器以确保备份一致性
    print_info "停止服务器进行备份..."
    docker-compose stop mc
    
    # 创建备份
    docker run --rm -v "${server}_data:/data" -v "$backup_dir:/backup" alpine:latest \
        tar czf "/backup/$(basename "$backup_file")" -C /data .
    
    # 重启服务器
    print_info "重启服务器..."
    docker-compose start mc
    
    print_success "备份已创建：$backup_file"
}

# 显示帮助的函数
show_help() {
    echo "MC-Servers 管理脚本"
    echo ""
    echo "用法：$0 <命令> [服务器名]"
    echo ""
    echo "命令："
    echo "  list                    列出可用的服务器配置"
    echo "  start <服务器>         启动服务器"
    echo "  stop <服务器>          停止服务器"
    echo "  restart <服务器>       重启服务器"
    echo "  logs <服务器>          查看服务器日志"
    echo "  status <服务器>        显示服务器状态"
    echo "  update <服务器>        更新并重启服务器"
    echo "  backup <服务器>        创建服务器数据备份"
    echo "  help                   显示此帮助信息"
    echo ""
    echo "示例："
    echo "  $0 list"
    echo "  $0 start paper-latest"
    echo "  $0 logs paper-latest"
    echo "  $0 backup paper-latest"
}

# 主脚本逻辑
case "${1:-}" in
    "list")
        list_servers
        ;;
    "start")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        start_server "$2"
        ;;
    "stop")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        stop_server "$2"
        ;;
    "restart")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        restart_server "$2"
        ;;
    "logs")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        logs_server "$2"
        ;;
    "status")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        status_server "$2"
        ;;
    "update")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        update_server "$2"
        ;;
    "backup")
        if [[ -z "${2:-}" ]]; then
            print_error "需要服务器名称"
            show_help
            exit 1
        fi
        backup_server "$2"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "未知命令：${1:-}"
        show_help
        exit 1
        ;;
esac