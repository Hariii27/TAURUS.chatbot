from flask import Flask, request, jsonify
import openai
from flask_cors import CORS
from langchain.schema.runnable import RunnableSequence  # Already imported
from langchain.prompts import PromptTemplate  # Already imported
from langchain_openai import ChatOpenAI  # Already imported
from transformers import pipeline
from dotenv import load_dotenv
import os
# Load environment variables from .env file
load_dotenv()
# Get OpenAI API key securely
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise ValueError("⚠️ OPENAI_API_KEY is missing! Please add it to the .env file.")
# Initialize Flask app
app = Flask(__name__)
CORS(app)
# Load Hugging Face's Zero-Shot Classification Model
classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")
# Define candidate labels for classification (light or complex)
candidate_labels = ['light', 'complex']
# Personal details
personal_details = {
    "Name": "Hari Narayanan",
    "Role": "Software Developer",
    "Interests": "AI, machine learning, cricket"
}
# Function to classify the task type using NLP
def classify_task_type(user_input):
    result = classifier(user_input, candidate_labels)
    return result['labels'][0]
# Initialize LangChain LLMs
gpt3_5_turbo = ChatOpenAI(model="gpt-3.5-turbo", openai_api_key=OPENAI_API_KEY)
gpt4 = ChatOpenAI(model="gpt-4", openai_api_key=OPENAI_API_KEY)
# Define prompt templates
general_prompt_template = "You are a helpful assistant.\nUser Query: {user_input}"
details_prompt_template = """
You are a helpful assistant.
Here are the details about the user:
Name: {name}
Role: {role}
Interests: {interests}
User Query: {user_input}
"""
# Create chains using the pipe operator
gpt3_chain_general = PromptTemplate(
    input_variables=["user_input"],
    template=general_prompt_template
) | gpt3_5_turbo
gpt4_chain_general = PromptTemplate(
    input_variables=["user_input"],
    template=general_prompt_template
) | gpt4
gpt3_chain_details = PromptTemplate(
    input_variables=["name", "role", "interests", "user_input"],
    template=details_prompt_template
) | gpt3_5_turbo
gpt4_chain_details = PromptTemplate(
    input_variables=["name", "role", "interests", "user_input"],
    template=details_prompt_template
) | gpt4
@app.route('/chat', methods=['POST'])
def chat():
    try:
        user_input = request.json.get('message', '').strip()
        if not user_input:
            return jsonify({"error": "Invalid input. Please provide a message."}), 400
        # If user asks about John Doe, use personal details
        if 'john doe' in user_input.lower():
            response_message = gpt3_chain_details.invoke({
                "name": personal_details["name"],
                "role": personal_details["role"],
                "interests": personal_details["interests"],
                "user_input": user_input
            })
        else:
            task_type = classify_task_type(user_input)
            chain = gpt3_chain_general if task_type == 'light' else gpt4_chain_general
            response_message = chain.invoke({"user_input": user_input})
        return jsonify({"response": response_message})
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
if __name__ == '__main__':
    app.run(debug=True)