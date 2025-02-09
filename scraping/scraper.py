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

def scrape_mcqs(url, maxQuestions=250):
    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
    ]
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-popup-blocking")
    chrome_options.add_argument("--disable-blink-features=AutomationControlled")  # Disable automation detection
    chrome_options.add_argument(f"user-agent={random.choice(user_agents)}")  # Randomize user-agent

    driver = webdriver.Chrome(options=chrome_options)
    try:
        logger.info(f"Scraping URL: {url}")
        driver.get(url)
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "entry-content")))

        soup = BeautifulSoup(driver.page_source, 'html.parser')
        mcqs = []
        content = soup.find("div", class_="entry-content")
        if not content:
            logger.error("Error: Unable to find questions section.")
            return []

        questions = content.find_all("p")
        i = 0
        while i < len(questions):
            question_text = questions[i].get_text().split("\n")[0].strip()

            # Skip if it doesn't start with a valid question (numbered or multiple choice)
            if not re.match(r"^\d+[\).]\s|\b[A-Da-d][\).]\s", question_text):
                i += 1
                continue  # Ignore titles or unrelated content

            # Remove the leading question number if present (e.g., "2. " or "3) ")
            question_text = re.sub(r"^\d+[\).]\s*", "", question_text)

            # Check if it's a question-only tag (i.e., no options here)
            if not questions[i].find("br"):
                # This is a question-only tag; check the next tag for additional info
                additional_info = None
                next_tag = questions[i].find_next("div", class_="hk1_style-wrap5")
                if next_tag:
                        # Traverse the nested structure to extract the text
                    inner_div = next_tag.find("div", class_="hk1_style-wrap4") \
                                        .find("div", class_="hk1_style-wrap3") \
                                        .find("div", class_="hk1_style-wrap2") \
                                        .find("div", class_="hk1_style-wrap") \
                                        .find("div", class_="hk1_style") \
                                        .find("div")
                    if inner_div:
                        # Extract the text from the <pre> tag
                        pre_tag = inner_div.find("pre", class_="de1")
                        if pre_tag:
                            additional_info = pre_agent_code_formatting(pre_tag.get_text(separator="\n").strip())

                # Move to the next tag that contains the options
                i += 1
                options_tag = questions[i] if i < len(questions) else None
                if options_tag:
                    options = []
                    
                    # Extract first option (before the first <br>)
                    first_option = options_tag.get_text(separator="\n").split("\n")[0].strip()
                    if first_option and re.match(r'^[a-d]\)', first_option):
                        first_option = re.sub(r'^[a-d]\)', '', first_option).strip()
                        options.append(first_option)

                    # Extract remaining options after <br> tags
                    for br in options_tag.find_all("br"):
                        if br.next_sibling:
                            option_text = br.next_sibling.strip()
                            if option_text:
                                option_text = re.sub(r'^[a-d]\)', '', option_text).strip()  # Remove option letter
                                options.append(option_text)

                    # Find the corresponding answer and explanation
                    answer_button = options_tag.find("span", class_="collapseomatic")
                    if answer_button:
                        answer_id = answer_button.get("id")
                        if answer_id:
                            answer_div = soup.find("div", id=f"target-{answer_id}")
                            if answer_div:
                                answer_text = answer_div.get_text(separator="\n").strip().split("Answer:")[-1].split("\n")[0].strip()
                                explanation = "\n".join(answer_div.get_text(separator="\n").strip().split("\n")[1:]).strip()
                                explanation = re.sub(r'^Explanation:\s*', '', explanation)
                            else:
                                answer_text = None
                                explanation = None
                        else:
                            answer_text = None
                            explanation = None
                    else:
                        answer_text = None
                        explanation = None

                    if question_text and options and answer_text and explanation:
                        mcqs.append({
                            "question": question_text,
                            "options": options,
                            "answer": answer_text,
                            "explanation": explanation,
                            "additional_info": additional_info  # Store the additional info here
                        })

            # If the question has options in the same <p> tag
            else:
                options = []
                for br in questions[i].find_all("br"):
                    if br.next_sibling:
                        option_text = br.next_sibling.strip()
                        if option_text:
                            option_text = re.sub(r'^[a-d]\)', '', option_text).strip()  # Remove option letter
                            options.append(option_text)

                # Extract the answer and explanation
                answer_button = questions[i].find("span", class_="collapseomatic")
                if answer_button:
                    answer_id = answer_button.get("id")
                    if answer_id:
                        answer_div = soup.find("div", id=f"target-{answer_id}")
                        if answer_div:
                            answer_text = answer_div.get_text(separator="\n").strip().split("Answer:")[-1].split("\n")[0].strip()
                            explanation = "\n".join(answer_div.get_text(separator="\n").strip().split("\n")[1:]).strip()
                            explanation = re.sub(r'^Explanation:\s*', '', explanation)
                        else:
                            answer_text = None
                            explanation = None
                    else:
                        answer_text = None
                        explanation = None
                else:
                    answer_text = None
                    explanation = None

                if question_text and options and answer_text and explanation:
                    mcqs.append({
                        "question": question_text,
                        "options": options,
                        "answer": answer_text,
                        "explanation": explanation,
                        "additional_info": None  # No additional info in this case
                    })

            # Stop when the maxQuestions limit is reached
            if len(mcqs) >= maxQuestions:
                break
            i += 1

        logger.info(f"Scraped {len(mcqs)} MCQs successfully.")
        return mcqs

    finally:
        driver.quit()  # Ensure the browser closes after scraping

# ============================== CODE FORMATTING SECTION ==============================

# Remove unnecessary newlines and excessive spaces
def pre_agent_code_formatting(code):
    code = re.sub(r'\n+', '\n', code)  # Reduce multiple newlines to a single newline
    code = re.sub(r'\s+', ' ', code)  # Reduce multiple spaces to a single space
    code = code.replace(' \n', '\n')  # Fix spaces before newlines
    return code.strip()

# Removes unnecessary quotes from formatted code.
def post_agent_code_formatting(code):
    code = re.sub(r'^.*```.*\n?', '', code, flags=re.MULTILINE)
    return re.sub(r'\\(.)', r'\1', code)  # Fix escaped characters


    
# ============================== HINT GENERATION SECTION ==============================

# Function to generate hints using OpenAI with retries
def generate_hints_for_mcqs(mcqs):
    for i, mcq in enumerate(mcqs):
        # Create the prompt
        prompt = f"""
        This prompt has two tasks: 
        1. Detect whether the input contains a code snippet. If so, identify the programming language and format it properly.
        2.  Generate a hint that provides subtle guidance without being too direct or revealing the answer. The hint should feel like a natural clue rather than an explicit instruction.

        ### Formatting Instructions:
        - If a code snippet is detected, **format it using standard programming conventions** exactly as a professional developer would.
        - **Ensure proper indentation and spacing** without extra or missing spaces.
        - **DO NOT wrap the code in quotes, backticks, or code blocks.**
        - **DO NOT include "Formatted Code", "Language:", or any labels before the code.**
        - **DO NOT use triple quotes ('''), backticks (```), or single/double quotes (").**
        - **ONLY return the code, exactly as it should be written in an IDE.**

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
        Additional Info: {mcq['additional_info']}

        Respond in the following format:
        [Code Detected] (Yes/No)

        [Formatted Code]
        <Return the formatted code exactly as it should be written, without quotes>

        [Hint]
        <Generated hint here>
        """


        try:
            response = client.models.generate_content(
                model="gemini-2.0-flash",
                contents=[prompt],
                config=types.GenerateContentConfig(
                    max_output_tokens=500,
                    temperature=0.7
                )
            )

            # Extract response text
            response_text = response.text.strip() if response.text else ""
            
            # Initialize empty fields
            mcq["additional_info"] = ""
            mcq["hint"] = ""

            # Parse response
            if "[Code Detected]" in response_text:
                parts = response_text.split("[Formatted Code]")
                code_detected_section = parts[0]
                hint_section = parts[1] if "[Hint]" in response_text else ""

                if "Yes" in code_detected_section:
                    # Extract the formatted code
                    formatted_code = hint_section.split("[Hint]")[0].strip()
                    hint = hint_section.split("[Hint]")[1].strip() if "[Hint]" in hint_section else ""
                    formatted_code = post_agent_code_formatting(formatted_code)
                    mcq["additional_info"] = formatted_code
                    print(formatted_code)
                    mcq["hint"] = hint
                else:
                    # No code detected, only extract the hint
                    mcq["hint"] = response_text.split("[Hint]")[1].strip() if "[Hint]" in response_text else response_text

        except Exception as e:
            logging.error(f"Error processing question {i + 1}: {e}")
            mcq["additional_info"] = ""
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
    
    url = sys.argv[1]  # Get the URL passed from the command line
    maxQuestions = int(sys.argv[2])  # Get the number of questions to scrape
    category = sys.argv[3]

    # Scrape MCQs
    mcqs = scrape_mcqs(url, maxQuestions=maxQuestions)
    
    # Hint generation
    hints = generate_hints_for_mcqs(mcqs)

    # Use when adjusting the prompt for hint generation
    # mcqs = load_mcqs_from_json('scraped_questions.json')

    if mcqs:
        save_mcqs_to_json(mcqs)
    else:
        logger.error("No MCQs were scraped.")

    # Store MCQs in Firestore
    # if mcqs:
    #     store_in_firestore(mcqs)
    # else:
    #     logger.error("No MCQs to store.")


if __name__ == "__main__":
    main()

