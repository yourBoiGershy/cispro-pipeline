#!/bin/bash

echo "=== GitLab Deployment Script ==="
echo "Starting deployment process..."
echo ""

# Navigate to the project directory
echo "Step 1: Navigating to project directory..."
cd ~/documents/CisPro
if [ $? -eq 0 ]; then
    echo "✓ Successfully navigated to $(pwd)"
else
    echo "✗ Failed to navigate to /documents/cispro"
    exit 1
fi
echo ""

# Pull latest code from git
echo "Step 2: Pulling latest code from git..."
git pull origin main
if [ $? -eq 0 ]; then
    echo "✓ Code pulled successfully"
else
    echo "✗ Git pull failed"
    exit 1
fi
echo ""

# Build backend
echo "Step 3: Building backend..."
cd backend
if [ $? -eq 0 ]; then
    echo "✓ Navigated to backend directory"

    # Install dependencies if needed
    echo "Installing backend dependencies..."
    npm install
    if [ $? -eq 0 ]; then
        echo "✓ Backend dependencies installed"
    else
        echo "✗ Backend npm install failed"
        exit 1
    fi

    # Build backend
    echo "Building backend..."
    npm run build
    if [ $? -eq 0 ]; then
        echo "✓ Backend built successfully"
    else
        echo "✗ Backend build failed"
        exit 1
    fi
else
    echo "✗ Failed to navigate to backend directory"
    exit 1
fi
echo ""

# Build frontend
echo "Step 4: Building frontend..."
cd ../frontend
if [ $? -eq 0 ]; then
    echo "✓ Navigated to frontend directory"

    # Install dependencies if needed
    echo "Installing frontend dependencies..."
    npm install
    if [ $? -eq 0 ]; then
        echo "✓ Frontend dependencies installed"
    else
        echo "✗ Frontend npm install failed"
        exit 1
    fi

    # Build frontend
    echo "Building frontend..."
    npm run build
    if [ $? -eq 0 ]; then
        echo "✓ Frontend built successfully"
    else
        echo "✗ Frontend build failed"
        exit 1
    fi

    # Copy build contents to parent build directory
    echo "Copying build contents to parent directory..."
    if [ -d "build" ]; then
        # Create parent build directory if it doesn't exist
        mkdir -p ../build

        # Empty the parent build directory first
        rm -rf ../build/*

        # Copy all contents from frontend/build to ../build
        cp -r build/* ../build/
        if [ $? -eq 0 ]; then
            echo "✓ Build contents copied to /documents/cispro/build"
        else
            echo "✗ Failed to copy build contents"
            exit 1
        fi
    else
        echo "✗ Build folder not found"
        exit 1
    fi
else
    echo "✗ Failed to navigate to frontend directory"
    exit 1
fi
echo ""

# Start backend server (only if both builds were successful)
echo "Step 5: Starting backend server..."
cd ../backend
if [ $? -eq 0 ]; then
    echo "✓ Navigated back to backend directory"

    # Stop any existing processes on port 4000
    echo "Stopping any existing processes on port 4000..."
    PORT_PID=$(lsof -ti:4000)
    if [ ! -z "$PORT_PID" ]; then
        echo "Found process(es) running on port 4000: $PORT_PID"
        kill -9 $PORT_PID
        if [ $? -eq 0 ]; then
            echo "✓ Successfully stopped existing processes on port 4000"
        else
            echo "✗ Failed to stop processes on port 4000"
            exit 1
        fi
        # Wait a moment for the port to be freed
        sleep 1
    else
        echo "✓ No existing processes found on port 4000"
    fi

    echo "Starting backend with npm start..."
    npm start &
    BACKEND_PID=$!

    # Give the server a moment to start
    sleep 2

    # Check if the process is still running
    if kill -0 $BACKEND_PID 2>/dev/null; then
        echo "✓ Backend server started successfully (PID: $BACKEND_PID)"
    else
        echo "✗ Backend server failed to start"
        exit 1
    fi
else
    echo "✗ Failed to navigate back to backend directory"
    exit 1
fi
echo ""

echo "=== Deployment Summary ==="
echo "Status: SUCCESS"
echo "Time: $(date)"
echo "Frontend build: /documents/cispro/build"
echo "Backend server: Running (PID: $BACKEND_PID)"
echo ""
echo "🎉 Deployment completed successfully!"
echo "Backend server is now running in the background."
