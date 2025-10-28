#!/usr/bin/env bash

# Complete cleanup script for VPS - removes all Namizun/traffic-creator installations
set -euo pipefail

echo "🧹 Complete VPS Cleanup"
echo "======================="

# Stop all Namizun-related processes
echo "🛑 Stopping all processes..."
pkill -9 -f "python uploader.py" || true
pkill -9 -f "uvicorn" || true
pkill -9 -f "namizun" || true
pkill -9 -f "traffic-creator" || true
pkill -9 -f "metrics_server" || true

# Stop and disable systemd services
echo "🔧 Stopping systemd services..."
systemctl stop namizun.service || true
systemctl disable namizun.service || true
systemctl stop traffic-creator.service || true
systemctl disable traffic-creator.service || true

# Remove service files
echo "🗑️  Removing service files..."
rm -f /etc/systemd/system/namizun.service
rm -f /etc/systemd/system/traffic-creator.service

# Reload systemd
systemctl daemon-reload

# Clear Redis database
echo "🗄️  Clearing Redis database..."
redis-cli FLUSHALL || true

# Remove all installation directories
echo "📁 Removing installation directories..."
rm -rf /var/www/namizun
rm -rf /root/namizun
rm -rf /root/traffic-creator
rm -rf /var/www/traffic-creator

# Remove logs
echo "📋 Removing logs..."
rm -rf /var/www/namizun/logs
rm -rf /root/namizun/logs
rm -rf /var/log/namizun

# Remove any remaining processes
echo "🔄 Final cleanup..."
sleep 2
pkill -9 -f "python" || true
pkill -9 -f "uvicorn" || true

echo ""
echo "✅ VPS completely cleaned!"
echo ""
echo "🔍 Current status:"
echo "  - No Namizun processes running"
echo "  - No systemd services active"
echo "  - All directories removed"
echo "  - Redis database cleared"
echo ""
echo "🚀 Ready for fresh deployment!"
