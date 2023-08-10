import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'openai_call.dart';
import 'package:file_picker/file_picker.dart';
import 'record_voice.dart';

// The main function that serves as the entry point of the application.
Future main() async {
  await dotenv.load(
      fileName: '.env'); // Loads environment variables from a .env file
  runApp(const MyApp()); // Runs the app
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the primary color theme
      ),
      home: const MyHomePage(), // Sets the home page
    );
  }
}

// The home page widget.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() =>
      MyHomePageState(); // Creates the state for the home page
}

// The state of the home page widget.
class MyHomePageState extends State<MyHomePage> {
  String _query = ''; // Stores the user's query
  String _reply = ''; // Stores the AI assistant's response
  String _voicePromptPath = ''; // Stores the path to the voice prompt
  bool _isLoading = false; // Indicates if a query is being sent
  final TextEditingController _queryController =
      TextEditingController(); // Controller for the query text field
  List<dynamic> messsages = [
    {
      "role": "system",
      "content": "You are a very helpful personal assistant and world class educator (like prof. Richard Feynman and his sense for humor), "
          "here to help and explain all kind of basic and difficult concepts in simple and concisely way."
          "Your output is structured in some general info and the rest in bullet points "
          "starting with numbers like 1., a., i. when necessary. You are able to summarize "
          "long texts."
    }
  ]; // Stores the conversation messages

  @override
  void dispose() {
    _queryController.dispose(); // Disposes the query text field controller
    super.dispose();
  }

  // Sends the query to the OpenAI API and updates the UI with the reply.
  Future<void> _sendQuery() async {
    setState(() {
      _isLoading = true; // Sets the loading state
      messsages.add({
        "role": "user",
        "content": _query
      }); // Adds the user's query to the conversation
    });

    final reply = await sendQuery(
        messsages); // Calls the sendQuery function from openai_call.dart

    setState(() {
      _reply = reply; // Updates the AI assistant's response
      messsages.add({
        "role": "assistant",
        "content": reply
      }); // Adds the assistant's response to the conversation
      _isLoading = false; // Resets the loading state
      _queryController.clear();
      _queryController.text = '';
    });
  }

  Future<void> _recordAudio(String filePath) async {
    setState(() {
      _isLoading = true;
    });
    String transcribedText = await sendAudioFile(filePath);
    setState(() {
      _queryController.text = transcribedText;
      _query = transcribedText;
      //ho_sendQuery();
    });
  }

  Future<void> _voiceRecorerScreen() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const VoiceRecorder()));
    setState(() {
      _voicePromptPath = result;
    });
    _recordAudio(_voicePromptPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Chat with GPT-3.5-Turbo-16k-0613'), // Sets the app bar title
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: TextField(
                maxLines:
                    4, // Sets the maximum number of lines for the query text field
                controller:
                    _queryController, // Binds the controller to the query text field
                onChanged: (value) {
                  setState(() {
                    _query = value; // Updates the user's query
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your query',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          _sendQuery();
                        },
                  child: const Text('Send'),
                ),
                const SizedBox(width: 16), // Add some space between the buttons
                ElevatedButton(
                  onPressed: _voiceRecorerScreen,
                  child: const Text('Voice prompt'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SelectableText(
                                _reply), // Displays the AI assistant's response
                          ),
                        ),
                      )
                    ],
                  ),
            ElevatedButton(
              onPressed: () {
                messsages = [
                  {
                    "role": "system",
                    "content": "You are a very helpful personal assistant and world class educator (like prof. Richard Feynman and his sense for humor), "
                        "here to help and explain all kind of basic and difficult concepts in simple and concisely way."
                        "Your output is structured in some general info and the rest in bullet points "
                        "starting with numbers like 1., a., i. when necessary. You are able to summarize "
                        "long texts."
                        "long texts."
                  }
                ];
              },
              child: const Text('New query'),
            ),
          ],
        ),
      ),
    );
  }
}
