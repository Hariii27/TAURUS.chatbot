import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';



// Global chat history storage
Map<int, List<Map<String, String>>> globalChatHistory = {};
int _currentPageId = 0; // Unique ID for each chat page

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
  await Firebase.initializeApp(
    options:FirebaseOptions(
      apiKey: "AIzaSyDEel5sdkezt5k8MiDSQ9WCtloHRtS9Ss4",
      authDomain: "taurus-12dd9.firebaseapp.com",
      projectId: "taurus-12dd9",
      storageBucket: "taurus-12dd9.firebasestorage.app",
      messagingSenderId: "428624449697",
      appId: "1:428624449697:web:bd81251818de332e9020e0",
      measurementId: "G-3M2KKYKWSF"
   ),
   
   );
   
   }
   else{
     await Firebase.initializeApp();
   
   }
   print('Firebase initialized');

  runApp(TaurusApp());
}

class TaurusApp extends StatelessWidget {
  const TaurusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TAURUS',
      theme: ThemeData.dark(),
      home: ChatbotScreen(pageId: _currentPageId),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  final int pageId;

  const ChatbotScreen({super.key, required this.pageId});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool _isBotTyping = false;
  bool _hasUserTyped = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Contextual conversation state
  String _currentTopic = "";

  // Animation controller for the welcome message
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    // Load chat history for this page
    if (globalChatHistory.containsKey(widget.pageId)) {
      messages = globalChatHistory[widget.pageId]!;
      if (messages.isNotEmpty) {
        _hasUserTyped = true;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"sender": "User", "message": userMessage});
      _isBotTyping = true;
      if (!_hasUserTyped) {
        _hasUserTyped = true;
        _animationController.forward();
      }
    });

    _controller.clear();

    // Update the current topic if it's empty (first message)
    if (_currentTopic.isEmpty) {
      _currentTopic = userMessage;
    }

    // Replace with your backend URL
    const backendURL = 'https://your-deployed-backend.com/chat';

    try {
      final response = await http.post(
        Uri.parse(backendURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': userMessage, 'context': _currentTopic}),
      );

      if (response.statusCode == 200) {
        final botResponse = json.decode(response.body)['response'];
        setState(() {
          messages.add({"sender": "Taurus", "message": botResponse});
          _isBotTyping = false;
        });
      } else {
        setState(() {
          messages.add({"sender": "Taurus", "message": "Error: Unable to get response."});
          _isBotTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"sender": "Taurus", "message": "Error: High traffic. Please try again later."});
        _isBotTyping = false;
      });
    }

    // Update global chat history
    globalChatHistory[widget.pageId] = messages;
  }

  Future<void> _regenerateResponse(String message) async {
    setState(() {
      _isBotTyping = true;
    });

    const backendURL = 'https://your-deployed-backend.com/regenerate';

    try {
      final response = await http.post(
        Uri.parse(backendURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message, 'context': _currentTopic}),
      );

      if (response.statusCode == 200) {
        final botResponse = json.decode(response.body)['response'];
        setState(() {
          messages.removeLast();
          messages.add({"sender": "Taurus", "message": botResponse});
          _isBotTyping = false;
        });
      } else {
        setState(() {
          messages.add({"sender": "Taurus", "message": "Error: Unable to regenerate response."});
          _isBotTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"sender": "Taurus", "message": "Error: Failed to connect to backend."});
        _isBotTyping = false;
      });
    }

    // Update global chat history
    globalChatHistory[widget.pageId] = messages;
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _startNewChat() {
    // Increment page ID for the new chat
    _currentPageId++;
    // Navigate to a new chat page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(pageId: _currentPageId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taurus '),
        actions: [
          IconButton(
            icon: Icon(Icons.history_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatHistoryScreen(chatHistory: globalChatHistory),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0 && !_hasUserTyped) {
                    return AnimatedOpacity(
                      opacity: _fadeAnimation.value,
                      duration: Duration(milliseconds: 300),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Hi, I'm TAURUS.\nHow can I help you today?",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (index == 0 && _hasUserTyped) {
                    return SizedBox.shrink();
                  }

                  final message = messages[index - 1];
                  final isUser = message["sender"] == "User";

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[600] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message["sender"]!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            message["message"]!,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isBotTyping)
              Padding(
                padding: EdgeInsets.all(8),
                child: SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 25,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask Taurus',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      style: TextStyle(color: Colors.white),
                      onSubmitted: (text) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic_off_sharp : Icons.mic_sharp),
                    onPressed: _startListening,
                  ),
                  IconButton(
                    icon: Icon(Icons.send_sharp),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatHistoryScreen extends StatelessWidget {
  final Map<int, List<Map<String, String>>> chatHistory;

  const ChatHistoryScreen({super.key, required this.chatHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _handleDeleteAllMessages(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chatHistory.length,
        itemBuilder: (context, index) {
          final pageId = chatHistory.keys.elementAt(index);
          final messages = chatHistory[pageId]!;

          return ExpansionTile(
            title: Text("Chat Page ${pageId + 1}"),
            children: messages.map((message) {
              final isUser = message["sender"] == "User";
              return ListTile(
                title: Text(
                  message["message"]!,
                  style: TextStyle(
                    color: isUser ? Colors.blue : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _handleDeleteAllMessages(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Chat History"),
          content: Text("Are you sure you want to delete all chat history?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Clear all chat history
                globalChatHistory.clear();
                Navigator.pop(context);
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}