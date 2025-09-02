from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent))

from web_claimer import claim_website
from config_utils import load_config, validate_config

def main():
    parser.argparse.ArgumentParser(description='Auto-claim website points')
    parser.add_argument('website', nargs='?', help='Specific website to claim')
    parser.add_argument('--all', action='store_true', help='Claim all websites')
    parser.add_argument('--list', action='store_true', help='List avaliable websites')
    parser.add_argument('--validate', action='store_true', help='Validate config without running')

    args = parser.parse_args()

    config = load_config()

    if not config:
        sys.exit(1)

    if args.validate:
        if validate_config(config):
            print("✅ Config validation passed!")
        else:
            print("❌ Config validation failed!")
        return

    if args.list:
        print("📋 Available websites:")
        for site in config.keys():
            print(f"  • {site}")
        return

    if args.all:
        success_count = 0
        total = len(config)

        for i, site_name in enumerate(config.keys(), 1):
            print(f"[{i}/total}]", end="")
            if claim_website(site_name, config):
                success_count += 1
       print(f"\n📊 Results: {success_count}/{total} successful")
       sys.exit(0 if success_count > 0 else 1)

    if args.website:
        if args.website not in config:
            print(f"❌ Website '{args.website}' not found in config")
            sys.exit(1)
        success = claim_webiste(args.website, config)
        sys.exit(0 if success else 1)

   # Show help if no arguments
    print("Usage: python -m src.main [website_name] | --all | --list | --validate")
    print("Examples:")
    print("  python -m src.main amazon_rewards")
    print("  python -m src.main --all")
    print("  python -m src.main --list")

if __name__ == "__main__":
    main()
