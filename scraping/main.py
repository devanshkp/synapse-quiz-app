import time
import subprocess
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# List of site details as dictionaries
sites = [
    {
        "url": "https://www.sanfoundry.com/software-engineering-questions-answers/",
        "max_questions": 100,
        "category": "Software Engineering"
    },
    {
        "url": "https://www.sanfoundry.com/c-programming-questions-answers/",
        "max_questions": 150,
        "category": "C Programming"
    },
    {
        "url": "https://www.sanfoundry.com/data-structures-questions-answers/",
        "max_questions": 200,
        "category": "Data Structures"
    }
]

def run_scraper_for_site(site):
    try:
        # Extract details from the site dictionary
        url = site["url"]
        max_questions = str(site["max_questions"])
        category = site["category"]
        
        # Call the scraper script and pass the URL, max questions, and category
        result = subprocess.run(
            ["python", "scraper_script.py", url, max_questions, category],
            check=True, capture_output=True, text=True
        )
        logger.info(f"Successfully scraped: {url} - Category: {category}")
        logger.debug(f"Output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logger.error(f"Error while scraping {url}: {e.stderr}")
    except Exception as e:
        logger.error(f"Unexpected error with {url}: {e}")

if __name__ == "__main__":
    for site in sites:
        logger.info(f"Scraping from {site['url']} (Category: {site['category']})...")
        run_scraper_for_site(site)
        time.sleep(5)  # Delay to prevent overwhelming the server

    logger.info("All scraping tasks completed.")
