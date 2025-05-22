#!/bin/bash

# 10NetZero-FLRTS Backend Startup Script
# This script sets up the Python environment and starts the Flask backend

set -e  # Exit on any error

echo "🚀 Starting 10NetZero-FLRTS Backend..."
echo "================================================"

# Check if we're in the correct directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found. Please run this script from the backend directory."
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required but not installed."
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"

# Check if virtual environment exists, create if not
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "📥 Upgrading pip..."
pip install --upgrade pip

# Install requirements
if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."
    pip install -r requirements.txt
    echo "✅ Dependencies installed"
else
    echo "❌ Error: requirements.txt not found"
    exit 1
fi

# Check for environment file
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found"
    echo "📋 Please copy .env.template to .env and configure your settings:"
    echo "   cp .env.template .env"
    echo "   # Then edit .env with your configuration"
    
    # Ask if user wants to continue anyway
    read -p "Continue without .env file? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Startup cancelled. Please configure .env file first."
        exit 1
    fi
fi

# Create logs directory
mkdir -p logs

# Check if MCP servers are running
echo "🔍 Checking MCP server status..."
if command -v mcpcheck &> /dev/null; then
    mcpcheck
else
    echo "⚠️  MCP check command not found - make sure MCP servers are running"
fi

echo "================================================"
echo "🎯 Starting Flask backend application..."
echo "================================================"

# Start the application
python3 app.py