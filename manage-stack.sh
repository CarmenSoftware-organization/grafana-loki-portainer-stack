#!/bin/bash

# Grafana Stack Management Script
# สคริปต์สำหรับจัดการ Grafana Stack

set -e

COMPOSE_FILE="docker-compose.yml"
STACK_NAME="grafana-stack"

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

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to create necessary directories
create_directories() {
    print_info "Creating necessary directories..."
    mkdir -p data/grafana data/loki
    
    # Set proper permissions
    sudo chown -R 472:472 data/grafana 2>/dev/null || true
    sudo chown -R 10001:10001 data/loki 2>/dev/null || true
    
    print_success "Directories created successfully"
}

# Function to start the stack
start_stack() {
    print_info "Starting Grafana Stack..."
    check_docker
    create_directories
    
    docker-compose -f $COMPOSE_FILE up -d
    
    print_success "Grafana Stack started successfully"
    print_info "Services available at:"
    print_info "  - Grafana: http://localhost:3999 (admin/admin123)"
    print_info "  - Loki: http://localhost:3998"
}

# Function to stop the stack
stop_stack() {
    print_info "Stopping Grafana Stack..."
    docker-compose -f $COMPOSE_FILE down
    print_success "Grafana Stack stopped successfully"
}

# Function to restart the stack
restart_stack() {
    print_info "Restarting Grafana Stack..."
    stop_stack
    start_stack
}

# Function to show stack status
show_status() {
    print_info "Grafana Stack Status:"
    docker-compose -f $COMPOSE_FILE ps
}

# Function to show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        print_info "Showing all logs..."
        docker-compose -f $COMPOSE_FILE logs -f
    else
        print_info "Showing logs for $service..."
        docker-compose -f $COMPOSE_FILE logs -f $service
    fi
}

# Function to backup data
backup_data() {
    print_info "Creating backup..."
    local backup_date=$(date +%Y%m%d_%H%M%S)
    local backup_dir="backups"
    
    mkdir -p $backup_dir
    
    # Backup Grafana data
    if [ -d "data/grafana" ]; then
        tar -czf "${backup_dir}/grafana_backup_${backup_date}.tar.gz" data/grafana/
        print_success "Grafana data backed up to ${backup_dir}/grafana_backup_${backup_date}.tar.gz"
    fi
    
    # Backup Loki data
    if [ -d "data/loki" ]; then
        tar -czf "${backup_dir}/loki_backup_${backup_date}.tar.gz" data/loki/
        print_success "Loki data backed up to ${backup_dir}/loki_backup_${backup_date}.tar.gz"
    fi
}

# Function to show help
show_help() {
    echo "Grafana Stack Management Script"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start        เริ่มต้น Grafana Stack"
    echo "  stop         หยุด Grafana Stack"
    echo "  restart      รีสตาร์ท Grafana Stack"
    echo "  status       แสดงสถานะของ services"
    echo "  logs [svc]   แสดง logs (ทั้งหมดหรือ service ที่ระบุ)"
    echo "  backup       สำรองข้อมูล"
    echo "  help         แสดงข้อมูลนี้"
    echo ""
    echo "Services: grafana, loki, promtail"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs grafana"
    echo "  $0 backup"
}

# Main script logic
case "${1:-help}" in
    start)
        start_stack
        ;;
    stop)
        stop_stack
        ;;
    restart)
        restart_stack
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    backup)
        backup_data
        ;;
    help)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
