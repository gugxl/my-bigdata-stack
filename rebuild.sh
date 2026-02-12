#!/bin/bash
#
# BigData Stack Rebuild Script
# Usage: ./rebuild.sh [options]
#
# Options:
#   -f, --full          Full rebuild (delete all images and volumes)
#   -c, --clean         Clean build cache
#   -s, --service NAME  Rebuild specific service only (base-builder/hadoop-builder/hbase-builder/hive-builder/spark-builder)
#   --no-cache          Do not use Docker cache
#   --skip-init         Skip HDFS initialization
#   -h, --help          Show help

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
FULL_REBUILD=false
CLEAN_CACHE=false
SKIP_INIT=false
NO_CACHE=""
TARGET_SERVICE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--full)
            FULL_REBUILD=true
            shift
            ;;
        -c|--clean)
            CLEAN_CACHE=true
            shift
            ;;
        -s|--service)
            TARGET_SERVICE="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --skip-init)
            SKIP_INIT=true
            shift
            ;;
        -h|--help)
            echo "BigData Stack Rebuild Script"
            echo ""
            echo "Usage: ./rebuild.sh [options]"
            echo ""
            echo "Options:"
            echo "  -f, --full          Full rebuild (delete all images and volumes)"
            echo "  -c, --clean         Clean Docker build cache"
            echo "  -s, --service NAME  Rebuild specific service only"
            echo "                      Available: base-builder, hadoop-builder, hbase-builder, hive-builder, spark-builder"
            echo "  --no-cache          Do not use Docker cache"
            echo "  --skip-init         Skip HDFS initialization"
            echo "  -h, --help          Show this help"
            echo ""
            echo "Examples:"
            echo "  ./rebuild.sh                           # Standard rebuild"
            echo "  ./rebuild.sh -f                        # Full rebuild"
            echo "  ./rebuild.sh -s hadoop-builder         # Rebuild hadoop only"
            echo "  ./rebuild.sh -c --no-cache             # Clean cache and rebuild"
            exit 0
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Print colored messages
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Execute command with timing
run_with_time() {
    local cmd="$1"
    local desc="$2"
    local start_time=$(date +%s)
    
    info "Starting: $desc"
    eval "$cmd"
    local exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    if [ $exit_code -eq 0 ]; then
        success "$desc completed (Time: ${minutes}m${seconds}s)"
    else
        error "$desc failed (Exit code: $exit_code)"
        exit $exit_code
    fi
}

# Step 1: Stop existing containers
stop_containers() {
    info "Stopping existing containers..."
    docker-compose down --remove-orphans
    success "Containers stopped"
}

# Step 2: Cleanup (if needed)
cleanup() {
    if [ "$FULL_REBUILD" = true ]; then
        warning "Performing full rebuild, will delete all images and volumes..."
        
        # Delete images
        docker rmi bigdata-hbase:latest bigdata-hadoop-base:latest my-bigdata-base:latest bigdata-hive:latest bigdata-spark:latest 2>/dev/null || true
        
        # Ask for confirmation to delete volumes
        read -p "Also delete data volumes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker volume rm my-bigdata-stack_hadoop_namenode_data my-bigdata-stack_hadoop_datanode_data my-bigdata-stack_hbase_data 2>/dev/null || true
            success "Data volumes deleted"
        fi
        
        success "Old images deleted"
    fi
    
    if [ "$CLEAN_CACHE" = true ]; then
        info "Cleaning Docker build cache..."
        docker builder prune -f
        success "Build cache cleaned"
    fi
}

# Step 3: Build images
build_images() {
    local build_cmd="docker-compose --profile build build $NO_CACHE"
    
    if [ -n "$TARGET_SERVICE" ]; then
        info "Building service: $TARGET_SERVICE"
        run_with_time "$build_cmd $TARGET_SERVICE" "Building $TARGET_SERVICE"
    else
        info "Building all images in dependency order..."
        
        # Build in sequence to ensure correct dependencies
        run_with_time "$build_cmd base-builder" "Building base-builder"
        run_with_time "$build_cmd hadoop-builder" "Building hadoop-builder (includes native library compilation, may be slow)"
        run_with_time "$build_cmd hbase-builder" "Building hbase-builder"
        run_with_time "$build_cmd hive-builder" "Building hive-builder"
        run_with_time "$build_cmd spark-builder" "Building spark-builder"
    fi
}

# Step 4: Start services
start_services() {
    info "Starting all services..."
    docker-compose up -d
    success "Services started"
}

# Step 5: Initialize HDFS
init_hdfs() {
    if [ "$SKIP_INIT" = false ]; then
        info "Waiting for HDFS to be ready..."
        sleep 10
        
        if [ -f "./init-hdfs.sh" ]; then
            run_with_time "./init-hdfs.sh" "Initializing HDFS"
        else
            warning "init-hdfs.sh not found, skipping HDFS initialization"
        fi
    else
        info "Skipping HDFS initialization"
    fi
}

# Step 6: Verification
verify() {
    info "Verifying installation..."
    
    # Check container status
    echo ""
    echo "Container status:"
    docker-compose ps
    
    # Check HBase availability
    echo ""
    info "Checking HBase availability..."
    docker exec hbase-master hbase version 2>/dev/null || warning "Cannot connect to HBase (container may still be starting)"
    
    success "Verification completed"
}

# Main flow
main() {
    echo "========================================"
    echo "  BigData Stack Rebuild Script"
    echo "========================================"
    echo ""
    
    # Check docker-compose
    if ! command -v docker-compose &> /dev/null; then
        error "docker-compose command not found"
        exit 1
    fi
    
    # Show configuration
    info "Rebuild configuration:"
    echo "  Full rebuild: $FULL_REBUILD"
    echo "  Clean cache: $CLEAN_CACHE"
    echo "  Target service: ${TARGET_SERVICE:-All}"
    echo "  No cache: $([ -n "$NO_CACHE" ] && echo "Yes" || echo "No")"
    echo "  Skip init: $SKIP_INIT"
    echo ""
    
    # Confirm
    if [ "$FULL_REBUILD" = true ]; then
        warning "Full rebuild will delete all data!"
        read -p "Are you sure you want to continue? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Operation cancelled"
            exit 0
        fi
    fi
    
    local total_start=$(date +%s)
    
    # Execute steps
    stop_containers
    cleanup
    build_images
    start_services
    init_hdfs
    verify
    
    local total_end=$(date +%s)
    local total_duration=$((total_end - total_start))
    local total_minutes=$((total_duration / 60))
    local total_seconds=$((total_duration % 60))
    
    echo ""
    echo "========================================"
    success "Rebuild completed! Total time: ${total_minutes}m${total_seconds}s"
    echo "========================================"
    echo ""
    echo "Common commands:"
    echo "  View logs: docker-compose logs -f <service>"
    echo "  Enter container: docker exec -it <container> bash"
    echo "  HBase shell: docker exec -it hbase-master hbase shell"
    echo ""
}

# Error handling
trap 'error "Script error at line: $LINENO"' ERR

# Run main function
main
