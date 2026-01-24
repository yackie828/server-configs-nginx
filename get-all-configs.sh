#!/usr/bin/env bash
#
# Script to collect all nginx configuration files
# This script creates a copy of all .conf and .types files
# Usage: ./get-all-configs.sh [output-directory]

set -e

# Default output directory
OUTPUT_DIR="${1:-./all-configs}"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Collecting all nginx configuration files...${NC}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy main config files
echo -e "${GREEN}Copying main configuration files...${NC}"
if [ -f "nginx.conf" ]; then
    cp -v nginx.conf "$OUTPUT_DIR/"
else
    echo -e "${YELLOW}Warning: nginx.conf not found${NC}"
fi

if [ -f "mime.types" ]; then
    cp -v mime.types "$OUTPUT_DIR/"
else
    echo -e "${YELLOW}Warning: mime.types not found${NC}"
fi

# Copy h5bp directory with all config snippets
if [ -d "h5bp" ]; then
    echo -e "${GREEN}Copying h5bp configuration snippets...${NC}"
    cp -rv h5bp "$OUTPUT_DIR/"
else
    echo -e "${YELLOW}Warning: h5bp directory not found${NC}"
fi

# Copy conf.d directory
if [ -d "conf.d" ]; then
    echo -e "${GREEN}Copying conf.d server definitions...${NC}"
    cp -rv conf.d "$OUTPUT_DIR/"
else
    echo -e "${YELLOW}Warning: conf.d directory not found${NC}"
fi

# Copy custom.d directory if it exists
if [ -d "custom.d" ]; then
    echo -e "${GREEN}Copying custom.d configurations...${NC}"
    cp -rv custom.d "$OUTPUT_DIR/"
fi

# Create a README in the output directory
cat > "$OUTPUT_DIR/README.txt" << 'EOF'
Nginx Server Configuration Files
=================================

This directory contains all nginx configuration files from the
server-configs-nginx repository.

Directory Structure:
-------------------
nginx.conf          - Main nginx configuration file
mime.types          - MIME types mapping file
h5bp/              - Configuration snippets (mixins)
  basic.conf       - Basic recommended rules
  location/        - Location-specific directives
  security/        - Security headers and policies
  tls/            - TLS/SSL configuration
  web_performance/ - Performance optimization
  cross-origin/    - Cross-origin resource sharing
  errors/          - Error handling
  media_types/     - Media type configurations
conf.d/            - Server definitions
  templates/       - Server configuration templates
custom.d/          - Custom configuration files (if present)

Usage:
------
1. Review nginx.conf and adjust paths, user, pid, etc.
2. Copy templates from conf.d/templates/ and customize for your domains
3. Include desired h5bp snippets in your server blocks
4. Test configuration: nginx -t -c /path/to/nginx.conf
5. Reload nginx: nginx -s reload

For more information, visit:
https://github.com/h5bp/server-configs-nginx
EOF

# Count files copied
CONF_COUNT=$(find "$OUTPUT_DIR" -name "*.conf" 2>/dev/null | wc -l)
TYPES_COUNT=$(find "$OUTPUT_DIR" -name "*.types" 2>/dev/null | wc -l)
TOTAL_COUNT=$((CONF_COUNT + TYPES_COUNT))

echo ""
echo -e "${GREEN}✓ Successfully collected all configuration files!${NC}"
echo -e "  Total files: $TOTAL_COUNT ($CONF_COUNT .conf + $TYPES_COUNT .types)"
echo -e "  Output directory: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Review the files in $OUTPUT_DIR"
echo "  2. Read $OUTPUT_DIR/README.txt for usage instructions"
echo "  3. Customize the configurations for your needs"
