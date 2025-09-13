#!/data/data/com.termux/files/usr/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Starting Auto Claim Bot Installation...${NC}"
sleep 2

# Check if running in Termux
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo -e "${RED}❌ Error: This script must be run in Termux${NC}"
    exit 1
fi

# Update packages
echo -e "${YELLOW}📦 Updating Termux packages...${NC}"
pkg update -y && pkg upgrade -y

# Install required Termux packages
echo -e "${YELLOW}📦 Installing required Termux packages...${NC}"
pkg install -y python wget git proot-distro

# Install Alpine distro if not present
if ! proot-distro list | grep -q "alpine"; then
    echo -e "${YELLOW}📦 Installing Alpine Linux in Termux...${NC}"
    proot-distro install alpine
fi

# Set up packages in Alpine
echo -e "${YELLOW}📦 Setting up dependencies in Alpine...${NC}"
proot-distro login alpine << 'ALPINE_EOF'
apk update
apk add --no-cache chromium chromium-chromedriver python3 py3-pip tesseract-ocr tesseract-ocr-data-eng py3-pillow
pip install selenium==4.15.0 pytesseract==0.3.10 fake-useragent==1.4.0
echo "✅ Alpine dependencies installed!"
ALPINE_EOF

# Create wrapper to run Python in Alpine
echo -e "${YELLOW}📦 Creating Alpine Python wrapper...${NC}"
mkdir -p ~/bin
cat > ~/bin/alpine-python << 'WRAPPER_EOF'
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login alpine --isolated --fix-low-ports --bind=/data/data/com.termux/files/home:/root -- python3 "$@"
WRAPPER_EOF
chmod +x ~/bin/alpine-python
export PATH="$HOME/bin:$PATH"

# Create bot directory structure
echo -e "${YELLOW}📁 Building Auto Claim Bot project structure...${NC}"
cd ~
mkdir -p auto_claim_bot/{src,config,scripts}

# Download source files
echo -e "${YELLOW}⬇️ Downloading bot source code...${NC}"

# Download Python source files
cd auto_claim_bot/src
wget -O main.py https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/src/main.py
wget -O web_claimer.py https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/src/web_claimer.py
wget -O config_utils.py https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/src/config_utils.py

# Download config template
cd ../config
wget -O websites_template.json https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/config/websites_template.json
cp websites_template.json websites.json

# Download run script
cd ../scripts
wget -O run_bot.sh https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/scripts/run_bot.sh

# Make scripts executable
chmod +x run_bot.sh

# Create COMPLETE setup wizard
echo -e "${YELLOW}📝 Creating setup wizard...${NC}"
cd ..
cat > setup_wizard.py << 'WIZARD_EOF'
#!/usr/bin/env python3
import json
import os

def setup_wizard():
    print("🎯 Auto Claim Bot Setup Wizard")
    print("=" * 40)
    
    config_path = "config/websites.json"
    config = {}
    
    print("\nLet's set up your first website!")
    
    while True:
        print("\n" + "="*30)
        website_name = input("Website nickname (e.g., 'amazon_rewards'): ").strip()
        if not website_name:
            print("❌ Website name cannot be empty!")
            continue
            
        url = input("Website login URL: ").strip()
        if not url.startswith(('http://', 'https://')):
            print("❌ URL must start with http:// or https://")
            continue
            
        username = input("Your username: ").strip()
        password = input("Your password: ").strip()
        
        print("\n💡 For advanced settings, press Enter to use defaults")
        username_id = input("Username field ID (default 'username'): ").strip() or "username"
        password_id = input("Password field ID (default 'password'): ").strip() or "password"
        claim_selector = input("Claim button XPath (default '//button[contains(text(), \"Claim\")]'): ").strip() or '//button[contains(text(), "Claim")]'
        
        # Add website to config
        config[website_name] = {
            "url": url,
            "username": username,
            "password": password,
            "username_id": username_id,
            "password_id": password_id,
            "claim_selector": claim_selector
        }
        
        print(f"✅ Added {website_name} to configuration!")
        
        another = input("\nAdd another website? (y/n): ").strip().lower()
        if another != 'y':
            break
    
    # Save configuration
    os.makedirs("config", exist_ok=True)
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    
    print(f"\n✅ Configuration saved to {config_path}!")
    print("💡 You can edit this file manually to add more websites later")
    print("\n🚀 To run the bot: ./scripts/run_bot.sh")

if __name__ == "__main__":
    setup_wizard()
WIZARD_EOF

# Make wizard executable
chmod +x setup_wizard.py

# Verify installation with a quick test
echo -e "${YELLOW}🧪 Testing Alpine Selenium setup...${NC}"
cat > ~/test_alpine_selenium.py << 'TEST_EOF'
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

try:
    driver = webdriver.Chrome(executable_path="/usr/bin/chromedriver", options=options)
    driver.get("https://www.google.com")
    print(f"✅ SUCCESS: {driver.title}")
    driver.quit()
except Exception as e:
    print(f"❌ ERROR: {e}")
TEST_EOF

alpine-python ~/test_alpine_selenium.py
rm ~/test_alpine_selenium.py

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}ℹ️ Next steps:${NC}"
echo -e "${BLUE}   1. Run: python setup_wizard.py (to configure websites)${NC}"
echo -e "${BLUE}   2. Run: ./scripts/run_bot.sh (to start the bot)${NC}"
echo -e "${BLUE}ℹ️ Note: The bot runs in Alpine Linux for better compatibility${NC}"
