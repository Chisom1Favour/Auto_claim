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

# Install required packages
echo -e "${YELLOW}📦 Installing required packages...${NC}"
pkg install python -y
pkg install wget -y

# Install Chromium
echo -e "${YELLOW}📦 Installing Chromium...${NC}"
pkg install -y chromium-browser

# Install Python dependencies
echo -e "${YELLOW}🐍 Installing Python packages...${NC}"
pip install selenium


# --- DYNAMIC CHROMEDRIVER INSTALLATION ---
echo -e "${YELLOW}⬇️ Finding and downloading matching ChromeDriver...${NC}"

# 1. Get the installed Chromium major version (e.g., 120)
# Using 'chromium-browser' as the command is more reliable in Termux
CHROME_MAJOR_VERSION=$(chromium-browser --version | grep -oP '\s\d+\.' | grep -oP '\d+' | head -1)

# 2. Check if we got a version number
if [ -z "$CHROME_MAJOR_VERSION" ]; then
    echo -e "${RED}❌ Failed to detect Chromium version. Please check if Chromium installed correctly.${NC}"
    echo -e "${YELLOW}⚠️  Falling back to known stable ChromeDriver version 114.0.5735.90${NC}"
    CHROMEDRIVER_VERSION="114.0.5735.90"
else
    echo -e "${BLUE}ℹ️  Detected Chromium major version: $CHROME_MAJOR_VERSION${NC}"
    # Use the major version number to get the latest ChromeDriver for that branch
    CHROMEDRIVER_VERSION="${CHROME_MAJOR_VERSION}.0.0.0"
fi

# 3. Download and install that version
cd /data/data/com.termux/files/usr/bin/
echo -e "${YELLOW}ℹ️  Attempting to download ChromeDriver v$CHROMEDRIVER_VERSION${NC}"

wget -q -O chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"

# 4. Check if the download was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ChromeDriver ${CHROMEDRIVER_VERSION} not found online.${NC}"
    echo -e "${YELLOW}⚠️  This is common. Trying latest version for major ${CHROME_MAJOR_VERSION}...${NC}"

    # Fetch the latest patch version for the major release from the LATEST_RELEASE file
    LATEST_PATCH_URL="https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}"
    CHROMEDRIVER_VERSION=$(wget -q -O - "$LATEST_PATCH_URL")
    echo -e "${YELLOW}ℹ️  Found latest patch version: $CHROMEDRIVER_VERSION${NC}"

    wget -q -O chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"

    # Final check if this also failed
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to download ChromeDriver. Please check your internet connection.${NC}"
        echo -e "${YELLOW}⚠️  Falling back to known stable ChromeDriver version 114.0.5735.90${NC}"
        CHROMEDRIVER_VERSION="114.0.5735.90"
        wget -q -O chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
    fi
fi

# 5. Proceed with installation
echo -e "${GREEN}✅ Downloaded ChromeDriver v$CHROMEDRIVER_VERSION successfully. Installing...${NC}"
unzip -o chromedriver.zip
rm -f chromedriver.zip
chmod +x chromedriver

# Verify installation
if ./chromedriver --version; then
    echo -e "${GREEN}✅ ChromeDriver installed successfully!${NC}"
else
    echo -e "${RED}❌ ChromeDriver installation may have failed.${NC}"
fi

# Create bot directory
# Install Tesseract OCR for CAPTCHA solving
echo -e "${YELLOW}📦 Installing Tesseract OCR...${NC}"

pkg install tesseract tesseract-data-eng -y
pip install pytesseract
pkg install python-pillow
pip install fake-useragent

# Create bot directory
echo -e "${YELLOW}📁 Building Auto Claim Bot project structure...${NC}"
# 1. Create the main project directory and subdirectories
cd ~
mkdir -p auto_claim_bot/src
mkdir -p auto_claim_bot/config
mkdir -p auto_claim_bot/scripts

# Download the main script
echo -e "${YELLOW}⬇️ Downloading bot source code...${NC}"

# 2. Download the Python source files into ~/auto_claim_bot/src/
cd auto_claim_bot/scrc
wget https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/src/main.py
wget https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/src/web_claimer.py
wget https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/src/config_utils.py

# 3. Download the config template into ~/auto_claim_bot/config/
cd ../config
wget https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/config/websites_template.json
cp websites_template.json websites.json

# 4. Download the run script into ~/auto_claim_bot/scripts/
# NOTE: Your install_dependencies.sh is already running from here, so we need toget the other script.
cd ../scripts
wget https://raw.githubusercontent.com/Chisom1Favour/Auto_claim/main/scripts/run_bot.sh

# 6. Make the main run script executable
chmod +x scripts/run_bot.sh

# 8. Create the setup wizard Python script
echo -e "${YELLOW}📝 Creating setup wizard...${NC}"

cat > setup_wizard.py << 'EOF'

#!/data/data/com.termux/files/usr/bin/python3
import json
import os

print("🎯 Auto Claim Bot Setup Wizard")
print("=" * 40)

config_path = "config/websites.json"

# Load existing config or create new
if os.path.exists(config_path):
    with open(config_path, 'r') as f:
        config = json.load(f)
else:
    config = {}

while True:
    print(f"\nCurrent websites: {list(config.keys())}")
    print("\n1. Add new website")
    print("2. Edit existing website")
    print("3. Remove website")
    print("4. View all websites")
    print("5. Save and exit")
    
    choice = input("\nChoose option (1-5): ").strip()
    
    if choice == "1":
        name = input("Website nickname (e.g., 'amazon_rewards'): ").strip()
        url = input("Website URL: ").strip()
        username = input("Username: ").strip()
        password = input("Password: ").strip()
        
        config[name] = {
            "url": url,
            "username": username,
            "password": password,
            "username_id": input("Username field ID (press Enter for 'username'): ").strip() or "username",
            "password_id": input("Password field ID (press Enter for 'password'): ").strip() or "password",
            "claim_selector": input("Claim button XPath (press Enter for default): ").strip() or "//button[contains(., 'Claim')]"
        }
        print(f"✅ Added {name}")
        
    elif choice == "2":
        # Edit logic here
        print("\n📝 Edit Website")
        site_to_edit = input("Enter the nickname of the website to edit: ").strip()
        if site_to_edit in config:
            print(f"Editing {site_to_edit}. Press Enter to keep current value.")
            current_data = config[site_to_edit]
            
            new_url = input(f"URL [{current_data['url']}]: ").strip()
            if new_url: current_data['url'] = new_url
            
            new_user = input(f"Username [{current_data['username']}]: ").strip()
            if new_user: current_data['username'] = new_user
            
            # ... you would add prompts for other fields here ...
            
            print(f"✅ Updated {site_to_edit}")
        else:
            print("❌ Website not found!")
    elif choice == 3:
        # Remove logic
        print("\n🗑️ Remove Website")
        site_to_remove = input("Enter the nickname of the website to remove: ").strip()
        if site_to_remove in config:
            del config[site_to_remove]
            print(f"✅ Removed {site_to_remove}")
        else:
            print("❌ Website not found!")

     elif choice == "4":
        # View all
        print("\n📋 All Configured Websites:")
        if config:
            for name, data in config.items():
                print(f"\n{name}:")
                print(f"  URL: {data['url']}")
                print(f"  Username: {data['username']}")
                # Don't print the password for security
        else:
            print("No websites configured yet.")
            
    elif choice == "5":
        # Save and exit
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=4)
        print("✅ Configuration saved to 'config/websites.json'!")
        break
        
    else:
        print("❌ Invalid option. Please choose 1-5.")

print("\nSetup complete! Run './start_bot.sh' to start claiming!")


