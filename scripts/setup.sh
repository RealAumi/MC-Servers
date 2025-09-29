#!/bin/bash

# Quick Setup Script for MC-Servers
# This script helps you get started quickly with a Minecraft server

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

# Function to check if Docker is installed and running
check_docker() {
    print_info "Checking Docker installation..."
    
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    print_info "Checking Docker Compose..."
    
    if docker compose version >/dev/null 2>&1; then
        print_success "Docker Compose (v2) is available"
    elif command -v docker-compose >/dev/null 2>&1; then
        print_success "Docker Compose (v1) is available"
    else
        print_error "Docker Compose is not available. Please install Docker Compose."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
}

# Function to setup Paper server
setup_paper() {
    local server_path="$PROJECT_ROOT/paper-latest"
    
    print_info "Setting up Paper server..."
    
    cd "$server_path"
    
    if [[ -f ".env" ]]; then
        print_warning ".env file already exists. Skipping copy from template."
    else
        cp ".env.example" ".env"
        print_success "Created .env file from template"
    fi
    
    print_info "Please edit the .env file to customize your server settings:"
    echo "  - Change RCON_PASSWORD from the default"
    echo "  - Adjust MEMORY allocation based on your system"
    echo "  - Set SERVER_NAME and MOTD"
    echo "  - Configure player limits and game settings"
    
    read -p "Would you like to edit the .env file now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} ".env"
    fi
    
    print_info "Starting Paper server..."
    docker-compose up -d
    
    print_success "Paper server is starting up!"
    print_info "Use the following commands to manage your server:"
    echo "  - View logs: cd $server_path && docker-compose logs -f mc"
    echo "  - Stop server: cd $server_path && docker-compose down"
    echo "  - Restart server: cd $server_path && docker-compose restart mc"
    echo "  - Or use the management script: $PROJECT_ROOT/scripts/manage.sh"
}

# Function to show server list
show_servers() {
    print_info "Available server configurations:"
    echo "  1. paper-latest - Latest Paper server (recommended)"
    echo ""
}

# Function to show main menu
show_menu() {
    echo "MC-Servers Quick Setup"
    echo "======================"
    echo ""
    show_servers
    echo "What would you like to do?"
    echo "  1. Setup Paper server (latest)"
    echo "  2. Check system requirements"
    echo "  3. Exit"
    echo ""
}

# Function to check system requirements
check_requirements() {
    print_info "Checking system requirements..."
    
    # Check available memory
    if command -v free >/dev/null 2>&1; then
        local total_mem=$(free -g | awk '/^Mem:/{print $2}')
        print_info "Available RAM: ${total_mem}GB"
        
        if [[ $total_mem -lt 2 ]]; then
            print_warning "Less than 2GB RAM available. Minecraft servers need at least 2GB."
            print_warning "Consider reducing MEMORY setting in .env file or upgrading your system."
        else
            print_success "Sufficient RAM available for Minecraft server"
        fi
    fi
    
    # Check disk space
    local available_space=$(df -h . | awk 'NR==2 {print $4}')
    print_info "Available disk space: $available_space"
    
    # Check Docker
    check_docker
    check_docker_compose
    
    print_success "System requirements check completed"
}

# Main script
main() {
    while true; do
        show_menu
        read -p "Enter your choice (1-3): " choice
        
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
                read -p "Press Enter to continue..."
                ;;
            3)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# Run main function
main