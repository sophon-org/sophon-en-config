#!/bin/bash

# Function to cleanup all resources
cleanup() {
    echo "Cleaning up resources..."
    
    # Stop and remove all containers
    docker-compose down --remove-orphans
    
    # Remove all volumes
    docker volume rm $(docker volume ls -q | grep -E 'mainnet-node')
    
    echo "Cleanup complete!"
}

# Function to start the node
start_node() {
    echo "Starting node..."
    docker-compose up -d
}

# Main script logic
if [ "$1" == "--cleanup" ]; then
    # Set up trap to ensure cleanup runs on script exit
    trap cleanup EXIT
    
    # Start the node
    start_node
    
    # Wait for user to press Ctrl+C
    echo "Node is running. Press Ctrl+C to stop and cleanup..."
    while true; do
        sleep 1
    done
else
    # Just start the node without cleanup
    start_node
fi 