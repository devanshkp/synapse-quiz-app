import time
import subprocess
import logging
import json

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load topics from the JSON file
def load_topics_from_json():
    with open('urls.json', 'r') as file:
        return json.load(file)

# Function to run the scraper for all topics
def run_scraper_for_all_topics():
    topics = load_topics_from_json()  # Load topics from the JSON file
    for topic_name, data in topics.items():
        # Iterate through each URL and its corresponding max_questions
        for url, max_q in data:
            try:
                # Call the scraper script and pass the URL, max questions, and topic
                result = subprocess.run(
                    ["python", "scraper.py", url, str(max_q), topic_name],
                    check=True, capture_output=True, text=True
                )
                logger.info(f"Successfully scraped: {url} - Topic: {topic_name}")
                logger.debug(f"Output: {result.stdout}")
            except subprocess.CalledProcessError as e:
                logger.error(f"Error while scraping {url}: {e.stderr}")
            except Exception as e:
                logger.error(f"Unexpected error with {url}: {e}")

if __name__ == "__main__":
    run_scraper_for_all_topics()
    logger.info("All scraping tasks completed.")
