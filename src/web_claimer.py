import random
import time
import logging
import base64
import io
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import keys
from fake_useragent import UserAgent
from PIL import Image
import pytesseract

from config_utils import load_config

logger = logging.getLogger(__name__)

# FREE CAPTCHA SOLVING WITH TESSERACT

def solve_captcha_with_tesseract(image_element):
    """FREE CAPTCHA solving using Tesseract OCR"""
    try:
        # Capture the CAPTCHA image
        location = image_element.location
        size = image_element.size

        # Take screenshot and crop to CAPTCHA
        driver.save_screenshot("temp_screenshot.png")
        screenshot = Image.open("temp_screenshot.png")

        left = location['x']
        top = location['y']
        right = location['x'] + size['width']
        bottom = location['y'] + size['height']

        captcha_image = screenshot.crop((left, top, right, bottom))
        captcha_image.save("captcha_temp.png")

        # Use Tesseract to read text
        text = pytessearct.image_to_string(captcha_image).strip()
        logger.info(f"CAPTCHA text detected: {text}")

        return text if text else None

    except Exception as e:
        logger.error(f" Tesseract CAPTCHA solving failed: {e}")
        return None

def solve_audio_captcha():
    """Handle audio CAPTCHA as fallback"""
    try:
        # Switch to audio CAPTCHA
        audio_button = driver.find_element(By.XPATH, "//button[contains(@title, 'audio')]")
        audio_button.click()
        time.sleep(2)

        # Here you could use speech-to-text APIs (some have free tiers)
        # Or prompt user for manual input
        logger.warning("Audio CAPTCHA detected - may require manual intervention")
        return None

    except Exception:
        return None

# MOBILE USER AGENTS RESTORED
def get_stealth_options():
    """Create Chrome options with anti-detection measures"""
    options = webdriver.ChromeOptions()
    
    # Basic headless options
    
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument("--disable-gpu")
    options.add_argument("--start_maximized")
    options.add_argument('--ignore-certificate-errors')
    options.add_argument("--disable-popup-blocking")
    options.add_argument("--disable-notifications")
    options.add_argument("--disable-web-security")
    options.add_argument("--allow-running-insecure-content")
    options.add_argument("--disable-default-apps")

    #  ANTI-DETECTION MEASURES
    
    # 1. Remove automation flags
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)

    mobile_user_agents = [
        # Samsung devices
        "Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 12; SM-S906N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36"
        "Mozilla/5.0 (Linux; Android 13; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.5615.48 Mobile Safari/537.36",

        # Google pixel devices
        "Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.5615.48 Mobile Safari/537.36",

        # OnePlus devices
        "Mozilla/5.0 (Linux; Android 11; ONEPLUS A5010) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 12; ONEPLUS A6013) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36",

        # Xiaomi devices
        "Mozilla/5.0 (Linux; Android 11; M2012K11AG) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 12; 2201122G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36",

        # Various other brands
        "Mozilla/5.0 (Linux; Android 11; motorola edge 20) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 12; XQ-BC72) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36",
        "Mozilla/5.0 (Linux; Android 13; 2203121G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.5615.48 Mobile Safari/537.36",

        # Fallback to fake-useragent if available
        "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.5615.48 Mobile Safari/537.36"
]

    options.add_argument(f"--user-agent={random.choice(mobile_user_agents)}")

    return options

def handle_recaptcha(driver):
    """Handle reCAPTCHA challenges with FREE OCR"""
    try:
        # Check if reCAPTCHA iframe exits
        recaptcha_frame = WebDriverWait(driver, 5).until(
            EC.presence_of_element_located((By.XPATH, "//iframe[contains(@src, 'recaptcha')]"))
        )

        driver.switch_to.frame(recaptcha_frame)

        # Click the reCAPTCHA checkbox
        checkbox = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, "//div[@class='recaptcha-checkbox-border'])))
        checkbox.click()
        logger.info("reCAPTCHA checkbox clicked")

        # Check if image challenge appears
        time.sleep(3)
        try:
            image_challenge = driver.find_element(By.XPATH, "//div[contains(@class, 'rc-imageselect')]")
            if image_challenge:
                logger.info("Image CAPTCHA detected - attempting FREE OCR solution")
        
                # Try to solve with Tesseract
                captcha_text = solve_captcha_with_tesseract(image_challenge)
                if captcha_text:
                    # Enter the solved text
                    input_field = driver.find_element(X.PATH, "//input[@type='text']")
                    input_field.clear()
                    human_type(input_field, captcha_text)
                    
                    # Submit
                    submit_button = driver.find_element(By.XPATH, "//button[@type='submit']")
                    submit_button.click()
                    logger.info("CAPTCHA solved with OCR!")
                    return "solved"
                else:
                    # Fallback to audio or manual
                    solve_audio_captcha()
                    return "manual_needed"
        except Exception as e:
            logger.warning(f"No image challenge: {e}")

        driver.switch_to.default_frame()
            return "checkbox_only"

    except TimeoutException:
        return "no_recaptcha"
    except Exception as e:
        logger.error(f"reCAPTCHA handling failed: {e}")
        return "error"

def handle_cloudflare_challenge(driver):
    """Handle Cloudflare challenge - KEEP THIS"""
    try:
        challenge_frame = WebDriverWait(driver, 10).until
            EC.presence_of_ekement_located((By.XPATH, "//iframe[contains(@title, 'challenge')]"))
        )
        driver.switch_to.frame(challenge_frame)
        checkbox = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//input[@type='checkbox']"))
        )
        time.sleep(random.uniform(0.5, 1.5))
        checkbox.click()
        logger.info("Cloudflare challenge completed")
        driver.switch_to.default_frame()
        return True
    except TimeoutException:
        return False # No Cloudflare detected - that's OK!
    except Exception as e:
        logger.error(f"Cloudflare handling failed: {e}")
         return False

def setup_driver():
    try:
        options = get_stealth_options()
        driver = webdriver.Chrome(options=options)
        driver.execute_cdp_cmd('Page.addScriptToEvaluateOnNewDocument', {
            'source': '''
                // THIS IS JAVASCRIPT CODE
                // It runs inside the webpage and changes the 'webdriver' property to be hidden.
                Object.defineProperty(navigator, 'webdriver', {
                    get: () => undefined,
                });
            '''
        return driver
    except Exception as e:
        logger.error(f"Driver setup failed: {e}")
        return None

def claim_website(website_name, config):
    """Main claim function - SIMPLIFIED"""
    driver = None
    try:
        site_config = config[website_name]
        driver = setup_driver()
        if not driver:
            return False

        wait = WebDriverWait(driver, 25)
        logger.info(f"Claiming {website_name}...")

        # Navigate to site
        driver.get(site_config["url"])
        time.sleep(random.uniform(2, 4))  # Initial page load

        # Handle security challenges (fail gracefully if not present)
        handle_cloudflare_challenge(driver)
        recaptcha_result = handle_recaptcha(driver)

        # If image CAPTCHA detected and not solved, may need manual intervention
        if recaptcha_result == "image_challenge_unsolved":
            logger.warning(f"{website_name}: Manual CAPTCHA solving may be needed")
            # Continue anyway - user might solve it manually if watching
        # Wait for the login page to load
        time.sleep(random.uniform(1, 3))

        # LOGIN PROCESS
        login.info(f"Logging into {website_name}...")

        # Find and fill username field
        username_selector = site_config.get("username_id", "username")
        try:
            username_field = wait.until(
                EC.element_to_be_clickable((By.ID, username_selector))
            )
            username_field.clear()
            human_type(username_field, site_config["username"])
            logger.info("Username entered")
        except TimeoutException:
            # Try other common username selectors
            for selector in ["input[name='username]", "input[type='email']", "#email", "#user"]:
                try:
                    username_field = driver.find_element(By.CSS_SELECTOR, selector)
                    username_field.clear()
                    human_type(username_field, site_config["username"])
                    logger.info("Usename entered (fallback selector)")
                    break
                except:
                    continue
            else:
                logger.error(f"{website_name}: Username field not found")
                return False
        # Brief pause between fields
        time.sleep(random.uniform(0.5, 1.5))

        # Find and fill password field
        password_selector = site_config.get("password_id", "password")
        try:
            password_field m= wait.until(
                EC.element_to_be_clickable((By.ID, password_selector))
                )
            password_field.clear()
            human_type(password_field, site_config["password"])
            logger.info("Password entered")
        except TimeoutException:
            # Try other common password selectors
            for selector in ["input[type='password']", "#pass", "#pwd"]:
                try:
                    password_field = driver.find_element(By.CSS_SELECTOR, selector)
                    password_field.clear()
                    human_type(password_field, site_config["password"])
                    logger.info("Password entered (fallback selector)"}
                    break
                except:
                    continue
            else:
                logger.error(f"{website_name}: Password field not found")
                return False
        # Pause before submitting
        time.sleep(random.uniform(0.5, 1.0))

        # Click login button
        try:
            login_selector = site_config.get("login_selector", "button[type='submit']")
            login_button = wait.until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, login_selector))
            )
            human_click(login_button)
            logger.info("Login button clicked")
        except TimeoutException:
            # Try common login
            for selector in ["button[type='submit']", "input[type='submit']", ".login-btn", "#login"]
                try:
                    login_button = driver.find_element(By.CSS_SELECTOR, selector)
                    human_click(login_button)
                    logger.info = ("Login button clicked (fallback selector)")
                    break
                except:
                    continue
            else:
                logger.error(f"{website_name}: Login button not found")
                return False

        # Wait for login to complete
        time.sleep(random.uniform(3, 6))

        # CHECK FOR LOGIN SUCCESS OR FAILURE
        try:
            # Look for error messages
            error_elements = driver.find_elements(By.XPATH, "//*[contains(text(), 'error'] or
                             contains (text(). 'invalid') or contains(text(), 'incorrect')]")
            if error_elements:
                logger_error(f"{website_name}: Login failed - {error_elements[0].text[:50]}...")
                return False
        except:
            pass # No errors found - good!

        # CLAIM REWARDS
        logger.info(f"Attempting to create reward on {website_name}...")

        # Try to find and click claim button
        claim_selector = site_config["claim_selector"]
        try:
            claim_button = wait.until(
                EC.element_to_be_clickable((By.XPATH, claim_selector))
            )
            human_click(claim_button)
            logger.info("Claim button clicked")

            # Wait for claim to process
            time.sleep(random.uniform(3, 5))

            # Check for success message
            try:
                success_elements = driver.find_elements(By.XPATH, "//*[contains(text(), 'success')or contains(text(), 'reward')]")
                if success_elements:
                    logger.info(f"{website_name} : Success - {success_elements[0].text[:50]}...")
                else:
                    logger_info(f"{website_name}: Claim action completed (no success message detected)")
            except:
                logger.info(f"{website_name}: Claim action completed")

            return True

        except TimeoutException:
            logger.warning(f"{website_name}: Claim button not found - may already be claimed")

            # Check if already claimed
            try:
                claimed_elements = driver.find_elements(By.XPATH, "//*[contains(text(), 'already') or contains(text(), 'tomorrow') or contains(text(), 'daily')]")
                if claimed_elements:
                    logger.info(f"✅ {website_name}: Already claimed today - {claimed_elements[0].text[:50]}...")
                    return True
            except:
                pass
            logger.error(f"{website_name}: Claim button not found with selector: {claim_selector}")
            return False
    except Exception as e:
        logger.error(f"❌ {website_name}: Unexpected error - {str(e)}")
        return False
    finally:
        if driver:
            driver.quit()
        
                
        
