🌟 TAURUS AI Chatbot

Welcome to TAURUS, an intelligent, modular, voice-enabled AI chatbot built with Flutter and powered by OpenAI’s state-of-the-art language models. Whether you’re chatting via text or voice, Taurus delivers smart, contextual replies in real time.




🚀 Features


🔍 Highlights of Taurus

🧠 Modular Architecture — Handles specialized tasks like calculations or searches using dedicated agents.

🔐 OpenAI Integration — Uses GPT-3.5-turbo via secure API calls.

🎙 Speech-to-Text — Enables voice queries with real-time transcription.

💬 Animated Chat UI — Smooth chat bubbles and typing indicators using Flutter animations.

💾 Chat Memory — Maintains session context for better conversations.




🛠 Tech Stack


🧰 Built with:

 Flutter

 Dart

 OpenAI GPT-3.5

 LangChain

 Flask

 PyTorch

 speech_to_text

 http

 ngrok (for testing)



🏗 Architecture Overview

🧠 Updated System Flow

flowchart TD
    subgraph Frontend [Flutter Mobile App]
        A1[🎤 User Input (Text/Voice)] --> A2[📲 Speech-to-Text Processing]
        A2 --> A3[💬 Chat Interface]
        A3 -->|JSON Request| B1
        B3 -->|Display Response| A3
    end

  
    
    subgraph Backend [Flask Server with LangChain]
        B1[📡 API Handler] --> B2[🧠 LangChain Router]
        B2 -->|Simple Tasks| B3[GPT-3.5 Processor]
        B2 -->|Complex Tasks| B4[GPT-4 + PyTorch Classifier]
        B4 --> B3
    end

    B3 -->|JSON Response| A3




⚙️ Installation & Setup


🚀 Quickstart to run locally


📦 Clone the Repo

git clone https://github.com/yourusername/taurus-ai-chatbot.git
cd taurus-ai-chatbot


🔑 Add API Key

Create a file named .env in the root folder:

OPENAI_API_KEY=sk-...



Optionally use flutter_dotenv to load environment variables securely.


📥 Install Dependencies

flutter pub get

▶️ Run the App

flutter run

🧩 Configuration

⚙️ Customize your setup

🤖 Model Switching:
Change the model in chatbot_ui.dart to either "gpt-4" or "gpt-3.5-turbo".

🌐 API Endpoint:
Update openAIUrl for custom gateways, proxies, or self-hosted LLMs.

🌍 Voice Input Settings:
Adjust speech_to_text language or input modes for better accuracy.




🔌 Optional Backend Integration

🧠 Powered by Flask + LangChain + PyTorch

📊 Classification Layer: Uses Hugging Face + PyTorch to decide task complexity.

🧠 Intelligent Routing: GPT-3.5 for short replies, GPT-4 for deeper tasks.

🌍 Deployment: Deployable via Google App Engine, Cloud Run, or Ngrok for local endpoints.




🤝 Contributing


🙌 We welcome your contributions!

Open issues or pull requests for new features or improvements.

Please follow git flow and test your changes.




📜 License

❌ No License Yet

Currently, this project does not include an official open-source license. You may view and use the code, but redistribution or commercial use is discouraged unless explicitly permitted.




🙏 Acknowledgments


💡 Inspired By:

🤖 OpenAI — GPT models

📱 Flutter — Beautiful cross-platform UI

🧠 LangChain — AI workflow toolkit

🧪 Flask — Python backend framework

🔬 PyTorch — Deep learning framework for ML ops






⚡ Crafted for intuitive, voice-assisted AI conversations. Modular, fast, and scalable.

