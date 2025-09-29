#!/bin/bash

# MC-Servers Management Script
# Provides common operations for Minecraft server management

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to list available server configurations
list_servers() {
    print_info "Available server configurations:"
    for dir in "$PROJECT_ROOT"/*/; do
        if [[ -f "$dir/docker-compose.yml" ]]; then
            basename="$(basename "$dir")"
            echo "  - $basename"
        fi
    done
}

# Function to validate server configuration exists
validate_server() {
    local server="$1"
    local server_path="$PROJECT_ROOT/$server"
    
    if [[ ! -d "$server_path" ]]; then
        print_error "Server configuration '$server' not found"
        list_servers
        exit 1
    fi
    
    if [[ ! -f "$server_path/docker-compose.yml" ]]; then
        print_error "No docker-compose.yml found in '$server'"
        exit 1
    fi
}

# Function to start a server
start_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "Starting server: $server"
    
    cd "$server_path"
    
    # Check if .env exists, if not copy from example
    if [[ ! -f ".env" && -f ".env.example" ]]; then
        print_warning ".env file not found, copying from .env.example"
        cp ".env.example" ".env"
        print_warning "Please edit .env file with your settings before starting the server"
        exit 1
    fi
    
    docker-compose up -d
    print_success "Server '$server' started successfully"
    print_info "Use 'docker-compose logs -f mc' to view logs"
}

# Function to stop a server
stop_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "Stopping server: $server"
    
    cd "$server_path"
    docker-compose down
    print_success "Server '$server' stopped successfully"
}

# Function to restart a server
restart_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "Restarting server: $server"
    
    cd "$server_path"
    docker-compose restart
    print_success "Server '$server' restarted successfully"
}

# Function to view server logs
logs_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "Showing logs for server: $server"
    
    cd "$server_path"
    docker-compose logs -f mc
}

# Function to show server status
status_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "Status for server: $server"
    
    cd "$server_path"
    docker-compose ps
}

# Function to update server
update_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    print_info "Updating server: $server"
    
    cd "$server_path"
    docker-compose pull
    docker-compose up -d
    print_success "Server '$server' updated successfully"
}

# Function to backup server data
backup_server() {
    local server="$1"
    validate_server "$server"
    
    local server_path="$PROJECT_ROOT/$server"
    local backup_dir="$PROJECT_ROOT/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/${server}_backup_${timestamp}.tar.gz"
    
    print_info "Creating backup for server: $server"
    
    mkdir -p "$backup_dir"
    
    cd "$server_path"
    
    # Stop server for consistent backup
    print_info "Stopping server for backup..."
    docker-compose stop mc
    
    # Create backup
    docker run --rm -v "${server}_data:/data" -v "$backup_dir:/backup" alpine:latest \
        tar czf "/backup/$(basename "$backup_file")" -C /data .
    
    # Restart server
    print_info "Restarting server..."
    docker-compose start mc
    
    print_success "Backup created: $backup_file"
}

# Function to show help
show_help() {
    echo "MC-Servers Management Script"
    echo ""
    echo "Usage: $0 <command> [server_name]"
    echo ""
    echo "Commands:"
    echo "  list                    List available server configurations"
    echo "  start <server>         Start a server"
    echo "  stop <server>          Stop a server"
    echo "  restart <server>       Restart a server"
    echo "  logs <server>          View server logs"
    echo "  status <server>        Show server status"
    echo "  update <server>        Update and restart server"
    echo "  backup <server>        Create a backup of server data"
    echo "  help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 start paper-latest"
    echo "  $0 logs paper-latest"
    echo "  $0 backup paper-latest"
}

# Main script logic
case "${1:-}" in
    "list")
        list_servers
        ;;
    "start")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        start_server "$2"
        ;;
    "stop")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        stop_server "$2"
        ;;
    "restart")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        restart_server "$2"
        ;;
    "logs")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        logs_server "$2"
        ;;
    "status")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        status_server "$2"
        ;;
    "update")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        update_server "$2"
        ;;
    "backup")
        if [[ -z "${2:-}" ]]; then
            print_error "Server name required"
            show_help
            exit 1
        fi
        backup_server "$2"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: ${1:-}"
        show_help
        exit 1
        ;;
esac