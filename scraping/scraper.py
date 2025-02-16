import time
import random
import os
import json
import logging
import re
import sys
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
import bs4
from bs4 import BeautifulSoup
from google import genai
from google.genai import types
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains



# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Retrieve the OpenAI API key
genai_api_key = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=genai_api_key)

# Initialize Firestore
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


# ============================== JSON FILE SECTION ==============================

def save_mcqs_to_json(mcqs):
    # Check if the file exists
    file_path = "scraped_questions.json"
    
    if os.path.exists(file_path):
        try:
            # Load existing MCQs from the file
            with open(file_path, "r", encoding="utf-8") as f:
                existing_mcqs = json.load(f)
            
            # Append the new MCQs to the existing list
            existing_mcqs.extend(mcqs)
            
            # Save the updated list back to the file
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(existing_mcqs, f, ensure_ascii=False, indent=4)
            logger.info("Appended new questions to 'scraped_questions.json'.")
        
        except Exception as e:
            logger.error(f"Error appending to 'scraped_questions.json': {e}")
    
    else:
        try:
            # If the file doesn't exist, create a new file and save the MCQs
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(mcqs, f, ensure_ascii=False, indent=4)
            logger.info("Created new 'scraped_questions.json' and saved questions.")
        
        except Exception as e:
            logger.error(f"Error creating 'scraped_questions.json': {e}")


# Function to load MCQs from JSON File
def load_mcqs_from_json(filename):
    try:
        with open(filename, "r", encoding="utf-8") as f:
            mcqs = json.load(f)
        logger.info(f"Loaded {len(mcqs)} MCQs from {filename}.")
        return mcqs
    except Exception as e:
        logger.error(f"Error loading JSON file: {e}")
        return []


# ============================== SCRAPING SECTION ==============================

# Function to add random delays
def random_delay(min_seconds=1, max_seconds=3):
    time.sleep(random.uniform(min_seconds, max_seconds))

# Function to scrape questions from www.sanfoundry.com
def scrape_mcqs(url, maxQuestions=250):
    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
    ]
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-popup-blocking")
    chrome_options.add_argument("--disable-blink-features=AutomationControlled")
    chrome_options.add_argument(f"user-agent={random.choice(user_agents)}")

    driver = webdriver.Chrome(options=chrome_options)
    try:
        logger.info(f"Scraping URL: {url}")
        driver.get(url)
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "entry-content")))

        soup = BeautifulSoup(driver.page_source, 'html.parser')
        mcqs = []

        # Extract the subtopic from the entry-title using regex
        header = soup.find("header", class_="entry-header")
        if header:
            title_element = header.find("h1", class_="entry-title")
            if title_element:
                title_text = title_element.text
                match = re.search(r"[–-](.+)", title_text)  # Regex search
                subtopic = match.group(1).strip() if match else None # if match found, group 1 is the subtopic. else None
            else:
                subtopic = None
        else:
            subtopic = None

        content = soup.find("div", class_="entry-content")
        if not content:
            logger.error("Error: Unable to find questions section.")
            return []

        def contains_complex_content(tag):
            """Check if a tag contains images, code blocks, scripts, or other complex elements."""
            return (tag.find('img') is not None or 
                    tag.find('noscript') is not None or
                    tag.find('pre') is not None or
                    tag.find('code') is not None or
                    tag.find('script') is not None or
                    tag.find('div', class_="hk1_style-wrap5") is not None)

        def extract_formatted_text(tag):
            """Extract text, handling nested sub/superscripts."""
            extracted_text = ""

            if isinstance(tag, str):
                return tag

            for elem in tag.contents:
                if isinstance(elem, str):
                    extracted_text += elem
                elif elem.name == "sub":
                    extracted_text += f"_{{{extract_formatted_text(elem)}}}"  # Recursive call
                elif elem.name == "sup":
                    extracted_text += f"^{{{extract_formatted_text(elem)}}}"  # Recursive call
                elif elem.name == "br":
                    extracted_text += "\n"
                elif elem.name in ['b', 'i', 'u', 'span']:
                    extracted_text += extract_formatted_text(elem) # recursive call
                elif elem.name in ['img', 'pre', 'code', 'div']:
                    break

            return extracted_text.strip()



        def extract_question_text(p_tag):
            """Extract multi-line question text before any options, with improved subscript/superscript formatting."""
            full_text = ""
            
            # First, collect all text nodes and tags in sequence
            elements = []
            for child in p_tag.children:
                elements.append(child)
            
            # Process all elements to build the question text
            i = 0
            while i < len(elements):
                element = elements[i]
                
                # Handle string nodes
                if isinstance(element, str):
                    text = element
                    # If this looks like an option, we're done
                    if re.match(r'^[a-d]\)', text):
                        break
                    # Otherwise, add it to our question text if it's not empty
                    if text:
                        # Remove question number at the beginning if present
                        if i == 0:
                            text = re.sub(r"^\d+[\).]\s*", "", text)
                        full_text += text
                
                # Handle HTML tags
                elif isinstance(element, bs4.element.Tag):
                    if element.name == "br":
                        # Check if next element is an option
                        if i + 1 < len(elements):
                            next_elem = elements[i + 1]
                            if isinstance(next_elem, str) and re.match(r'^[a-d]\)', next_elem.strip()):
                                break
                        full_text += "\n"
                    elif element.name == "sub":
                        full_text += "_{" + extract_formatted_text(element) + "}" 
                    elif element.name == "sup":
                        full_text += "^{" + extract_formatted_text(element) + "}" 
                    elif element.name in ['b', 'i', 'u', 'span'] and not element.get("class"):
                        full_text += extract_formatted_text(element)
                    elif element.name in ['img', 'a', 'pre', 'code']:
                        # Stop at complex elements
                        break
                
                i += 1
            
            # Clean up whitespace
            full_text = re.sub(r'\s+', ' ', full_text)
            full_text = re.sub(r'\n\s+', '\n', full_text)
            
            return full_text.strip()


        def extract_options(p_tag):
            """Extract options with improved mathematical notation and prevent duplicates."""
            options = []
            br_tags = p_tag.find_all("br")
            seen_options = set()  # To track already processed options
            
            for i, br in enumerate(br_tags):
                # Only process <br> tags that are immediately followed by option markers
                next_elem = br.next_sibling
                if not (isinstance(next_elem, str) and re.match(r'^[a-d]\)', next_elem.strip())):
                    continue
                    
                option_content = []
                current = next_elem
                
                while current and (i == len(br_tags) - 1 or current != br_tags[i + 1]):
                    if isinstance(current, bs4.element.Tag):
                        if current.name == "sub":
                            option_content.append(f"_{{{extract_formatted_text(current)}}}") 
                        elif current.name == "sup":
                            option_content.append(f"^{{{extract_formatted_text(current)}}}") 
                        elif current.name not in ['img', 'pre', 'code', 'div', 'span']:
                            option_content.append(extract_formatted_text(current)) 
                    elif isinstance(current, str):
                        option_content.append(current)
                    
                    current = current.next_sibling if hasattr(current, 'next_sibling') else None
                
                option_text = ''.join(option_content).strip()
                if option_text and re.match(r'^[a-d]\)', option_text):
                    option_text = re.sub(r'^[a-d]\)\s*', '', option_text).strip()
                    
                    # Fix common LaTeX formatting issues
                    option_text = re.sub(r'\s+', ' ', option_text)
                    
                    # Only add if not already seen and non-empty
                    if option_text and option_text not in seen_options:
                        options.append(option_text)
                        seen_options.add(option_text)
            
            return options if len(options) >= 2 else []



        questions = content.find_all("p")
        i = 0
        while i < len(questions):
            current_tag = questions[i]
            
            # Skip if not a valid question start
            if not re.match(r"^\d+[\).]\s|\b[A-Da-d][\).]\s", current_tag.get_text().strip()):
                i += 1
                continue

            # Skip questions with complex content
            next_tag = current_tag.find_next_sibling()
            if (contains_complex_content(current_tag) or
                not current_tag.find("br") or
                not (next_tag and next_tag.name == "div" and "collapseomatic_content" in next_tag.get("class", []))
            ):
                i += 1
                continue

            question_text = extract_question_text(current_tag)
            
            options = extract_options(current_tag)
            if not options:  # Skip if no valid options found
                i += 1
                continue

            # Extract answer and explanation
            answer_button = current_tag.find("span", class_="collapseomatic")

            if answer_button:
                answer_id = answer_button.get("id")
                if answer_id:
                    answer_div = soup.find("div", id=f"target-{answer_id}")
                    if contains_complex_content(answer_div):
                        i += 1
                        continue
                    if answer_div:
                        full_text = extract_formatted_text(answer_div) 
                        try:
                            answer_text = full_text.split("Answer:")[-1].split("\n")[0].strip()
                            explanation_lines = full_text.split("Explanation:")[-1].split("\n") if "Explanation:" in full_text else full_text.split("Answer:")[-1].split("\n")[1:]
                            explanation = "\n".join(line.strip() for line in explanation_lines if line.strip()).strip() 
                            explanation = re.sub(r'^Explanation:\s*', '', explanation).strip()
                        except IndexError:
                            answer_text = explanation = None
                    else:
                        answer_text = explanation = None
                else:
                    answer_text = explanation = None
            else:
                answer_text = explanation = None

            if question_text and options and answer_text and explanation:
                mcqs.append({
                    "question": question_text,
                    "options": options,
                    "answer": answer_text,
                    "explanation": explanation,
                    "subtopic": subtopic
                })

            if len(mcqs) >= maxQuestions:
                break
            i += 1

        logger.info(f"Scraped {len(mcqs)} MCQs successfully.")
        return mcqs

    finally:
        driver.quit()
    
# ============================== HINT GENERATION SECTION ==============================

# Function to generate hints using OpenAI with retries
def generate_hints_for_mcqs(mcqs):
    for i, mcq in enumerate(mcqs):
        # Create the prompt
        prompt = f"""
        Generate a hint that provides subtle guidance without being too direct or revealing the answer. The hint should feel like a natural clue rather than an explicit instruction.

        ### Hint Generation Instructions:
        - The hint should feel natural, offering a nudge in the right direction rather than directly instructing the user.
        - Do not directly guide the user to the answer but help them think critically about the question and its options.
        - Avoid using the following words at the beginning of the hint: "consider," "think," "remember," or any similar directive.
        - Do not include "hint:" or any other prefix.
        
        ### Input
        Question: {mcq['question']}
        Options: {mcq['options']}
        Answer: {mcq['answer']}
        Explanation: {mcq['explanation']}

        Respond in the following format:

        [Hint]
        <Generated hint here>
        """

        try:
            response = client.models.generate_content(
                model="gemini-2.0-flash",
                contents=[prompt],
                config=types.GenerateContentConfig(
                    max_output_tokens=100,
                    temperature=0.7
                )
            )

            # Extract response text
            response_text = response.text.strip() if response.text else ""
            mcq["hint"] = response_text.split("[Hint]")[1].strip() if "[Hint]" in response_text else response_text

        except Exception as e:
            logging.error(f"Error processing question {i + 1}: {e}")
            mcq["hint"] = ""

    return mcqs

# ============================== FIRESTORE STORAGE SECTION ==============================

# Function to store MCQs in Firestore using batch writes
def store_in_firestore(mcqs):
    batch = db.batch()
    mcq_ref = db.collection("questions")

    for i, mcq in enumerate(mcqs):
        doc_ref = mcq_ref.document()  # Auto-generate ID
        batch.set(doc_ref, mcq)

        if (i + 1) % 500 == 0:  # Commit every 500 documents
            batch.commit()
            batch = db.batch()
            logger.info(f"Stored {i + 1} MCQs so far...")

    batch.commit()  # Commit remaining documents
    logger.info("All MCQs stored successfully!")


# ============================== MAIN FUNCTION CALL ==============================

def main():
    if len(sys.argv) < 4:
        raise ValueError("Error: URL and number of questions not provided.")
    
    url = sys.argv[1]
    maxQuestions = int(sys.argv[2]) 
    topic = sys.argv[3]

    # Scrape MCQs
    mcqs = scrape_mcqs(url, maxQuestions=maxQuestions)
    
    # Hint generation
    hints = generate_hints_for_mcqs(mcqs)

    for mcq in mcqs:
        mcq["topic"] = topic

    # Use when adjusting the prompt for hint generation
    # mcqs = load_mcqs_from_json('scraped_questions.json')

    # Save MCQs to a JSON File
    if mcqs:
        save_mcqs_to_json(mcqs)
    else:
        logger.error("No MCQs were scraped.")

    # Store MCQs in Firestore
    if mcqs:
        store_in_firestore(mcqs)
    else:
        logger.error("No MCQs to store.")


if __name__ == "__main__":
    main()

