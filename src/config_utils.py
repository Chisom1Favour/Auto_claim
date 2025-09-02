import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

def get_config_path():
    """Get absolute path to config file"""
    return Path(__file__).parent.parent / "config" / "websites.json"

def load_config():
    """Load and validate websites configuration"""
    config_path = get_config_path()

    if not config_path.exists():
        logger.error(f"❌ Config file not found: {config_path}")
        logger.error("💡 Run: cp config/websites_template.json config/websites.json")
        logger.error("💡 Then edit config/websites.json with your websites")
        return None

    try:
        with open(config_path) as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in config file: {e}")
        return None
    except Exception as e:
        logger.error(f"Error reading config: {e}")
        return None

    # Validate config structure
    if not validate_config(config):
        return None

    return config

def validate_config(config):
    """Validate that config has required fields"""
    if not config:
        logger.error("Config is empty")
        return False

    all_valid = True
    for site_name, site_config in config.items():
        # Check required fields
        required = ["url", "username", "password", "claim_selector"]
        for field in required:
            if field not in site_config:
                logger.error(f"{site_name}: Missing required field' {field}'")
                all_valid = False

            # Checks if fields are non-empty
            for field in required:
                if field in site_config and not str(site_config[field]).strip():
                    logger.error(f"{site_name}: Field '{field}' is empty")
                    all_valid = False

    return all_valid
