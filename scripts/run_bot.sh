#!/data/data/com.termux/files/usr/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Auto Claim Bot...${NC}"
echo -e "${BLUE}===============================${NC}"

# Change to bot directory
cd ~/auto_claim_bot || {
    echo -e "${RED}❌ Error: auto_claim_bot directory not found${NC}"
    echo -e "${YELLOW}💡 Make sure you're in the right directory${NC}"
    exit 1
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install dependencies if missing
if ! command_exists chromium || ! command_exists chromedriver; then
    echo -e "${YELLOW}⚠️ Dependencies not found - running installation...${NC}"
    ./scripts/install_dependencies.sh
    # Check if installation succeeded
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Installation failed!${NC}"
        exit 1
    fi
fi

# Check if config exists, if not create from template
if [ ! -f "config/websites.json" ]; then
    echo -e "${YELLOW}⚠️ No config file found - creating from template...${NC}"
    if [ ! -f "config/websites_template.json" ]; then
        echo -e "${RED}❌ Template config not found!${NC}"
        exit 1
    fi
    cp config/websites_template.json config/websites.json
    echo -e "${GREEN}✅ Config file created!${NC}"
    echo -e "${YELLOW}💡 Please edit config/websites.json with your websites${NC}"
    echo -e "${YELLOW}   Then run this script again${NC}"
    exit 1
fi

# Validate config
echo -e "${YELLOW}🔍 Validating configuration...${NC}"
python -m src.main --validate
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Config validation failed!${NC}"
    echo -e "${YELLOW}💡 Check your config/websites.json file${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Config validation passed!${NC}"
echo -e "${YELLOW}🔄 Starting claim process...${NC}"

# Run the main claim process
python -m src.main --all
exit_code=$?

echo -e "${BLUE}===============================${NC}"

if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✅ Bot run completed successfully!${NC}"
else
    echo -e "${RED}❌ Bot run completed with errors${NC}"
    echo -e "${YELLOW}💡 Check the output above for details${NC}"
fi

exit $exit_code
