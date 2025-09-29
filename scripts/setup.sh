#!/bin/bash

# MC-Servers 快速设置脚本
# 此脚本帮助您快速开始使用 Minecraft 服务器

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
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否已安装并运行的函数
check_docker() {
    print_info "检查 Docker 安装..."
    
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker 未安装。请先安装 Docker。"
        echo "访问：https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker 未运行。请先启动 Docker。"
        exit 1
    fi
    
    print_success "Docker 已安装并运行"
}

# 检查 Docker Compose 是否可用的函数
check_docker_compose() {
    print_info "检查 Docker Compose..."
    
    if docker compose version >/dev/null 2>&1; then
        print_success "Docker Compose (v2) 可用"
    elif command -v docker-compose >/dev/null 2>&1; then
        print_success "Docker Compose (v1) 可用"
    else
        print_error "Docker Compose 不可用。请安装 Docker Compose。"
        echo "访问：https://docs.docker.com/compose/install/"
        exit 1
    fi
}

# 设置 Paper 服务器的函数
setup_paper() {
    local server_path="$PROJECT_ROOT/paper-latest"
    
    print_info "设置 Paper 服务器..."
    
    cd "$server_path"
    
    if [[ -f ".env" ]]; then
        print_warning ".env 文件已存在。跳过从模板复制。"
    else
        cp ".env.example" ".env"
        print_success "从模板创建 .env 文件"
    fi
    
    print_info "请编辑 .env 文件以自定义您的服务器设置："
    echo "  - 更改默认的 RCON_PASSWORD"
    echo "  - 根据您的系统调整 MEMORY 分配"
    echo "  - 设置 SERVER_NAME 和 MOTD"
    echo "  - 配置玩家限制和游戏设置"
    
    read -p "您现在想要编辑 .env 文件吗？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} ".env"
    fi
    
    print_info "启动 Paper 服务器..."
    docker-compose up -d
    
    print_success "Paper 服务器正在启动！"
    print_info "使用以下命令来管理您的服务器："
    echo "  - 查看日志：cd $server_path && docker-compose logs -f mc"
    echo "  - 停止服务器：cd $server_path && docker-compose down"
    echo "  - 重启服务器：cd $server_path && docker-compose restart mc"
    echo "  - 或使用管理脚本：$PROJECT_ROOT/scripts/manage.sh"
}

# 显示服务器列表的函数
show_servers() {
    print_info "可用的服务器配置："
    echo "  1. paper-latest - 最新 Paper 服务器（推荐）"
    echo ""
}

# 显示主菜单的函数
show_menu() {
    echo "MC-Servers 快速设置"
    echo "==================="
    echo ""
    show_servers
    echo "您想要做什么？"
    echo "  1. 设置 Paper 服务器（最新版）"
    echo "  2. 检查系统要求"
    echo "  3. 退出"
    echo ""
}

# 检查系统要求的函数
check_requirements() {
    print_info "检查系统要求..."
    
    # 检查可用内存
    if command -v free >/dev/null 2>&1; then
        local total_mem=$(free -g | awk '/^Mem:/{print $2}')
        print_info "可用内存：${total_mem}GB"
        
        if [[ $total_mem -lt 2 ]]; then
            print_warning "可用内存少于 2GB。Minecraft 服务器至少需要 2GB。"
            print_warning "考虑在 .env 文件中减少 MEMORY 设置或升级您的系统。"
        else
            print_success "Minecraft 服务器有足够的内存可用"
        fi
    fi
    
    # 检查磁盘空间
    local available_space=$(df -h . | awk 'NR==2 {print $4}')
    print_info "可用磁盘空间：$available_space"
    
    # 检查 Docker
    check_docker
    check_docker_compose
    
    print_success "系统要求检查完成"
}

# 主脚本
main() {
    while true; do
        show_menu
        read -p "输入您的选择 (1-3): " choice
        
        case $choice in
            1)
                check_docker
                check_docker_compose
                setup_paper
                break
                ;;
            2)
                check_requirements
                echo ""
                read -p "按 Enter 继续..."
                ;;
            3)
                print_info "再见！"
                exit 0
                ;;
            *)
                print_error "无效选择。请输入 1、2 或 3。"
                ;;
        esac
    done
}

# 运行主函数
main