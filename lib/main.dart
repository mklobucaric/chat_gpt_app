import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'openai_call.dart';
import 'record_voice.dart';
import 'widgets.dart';

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
  String selectedText = '';
  // final List<String> _modes = ['mode', 'creativity', 'model'];
  int _selectedIndex = 0;
//  final List<String> _label = ['normal', '1', 'gpt-3.5-turbo'];
  final Map<String, dynamic> _label = {
    'mode': 'education',
    'creativity': '1',
    'model': 'gpt-3.5-turbo-16k-0613'
  };
  final List<String> _modes = [
    'boys-10y',
    'girls-13y',
    'normal',
    'education',
  ];
  final List<String> _models = [
    'gpt-3.5-turbo',
    'gpt-3.5-turbo-0613',
    'gpt-3.5-turbo-16k',
    'gpt-3.5-turbo-16k-0613',
    'gpt-4',
    'gpt-4-0613',
  ];

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
      // _queryController.clear();
      // _queryController.text = '';
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
      _sendQuery();
    });
  }

  Future<void> _voiceRecorerScreen() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const VoiceRecorder()));
    setState(() {
      if (result != null) {
        _voicePromptPath = result;
      } else {
        _voicePromptPath = '';
      }
    });
    if (_voicePromptPath != '') {
      _recordAudio(_voicePromptPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal assistant'),
        centerTitle: true, // Sets the app bar title
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: GestureDetector(
                onDoubleTap: () {
                  _queryController.clear(); // Clears the text field
                },
                child: TextField(
                  maxLines: null,
                  controller: _queryController,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                        'Enter your query or voice prompt\nDouble click to clear',
                  ),
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
                  child: const Icon(Icons.send),
                ),
                const SizedBox(width: 16), // Add some space between the buttons
                ElevatedButton(
                  onPressed: _voiceRecorerScreen,
                  child: const Icon(
                    Icons.interpreter_mode,
                  ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.school,
            ),
            label: _label['mode'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.spa,
            ),
            label: _label['creativity'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.precision_manufacturing,
            ),
            label: _label['model'],
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _selectedIndex = index;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Wrap(
                  direction: Axis.vertical,
                  children: <Widget>[
                    if (index == 0) // education
                      Wrap(
                        children: <ChoiceChip>[
                          for (var mode in _modes)
                            ChoiceChip(
                              label: Text(mode),
                              selected: _modes[index] == mode,
                              onSelected: (bool selected) {
                                setState(() {
                                  _label['mode'] = mode;
                                });
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    if (index == 1) // creativity
                      SliderWidget(
                        value: double.parse(_label['creativity']),
                        onChanged: (value) {
                          setState(() {
                            _label['creativity'] = value.toStringAsFixed(1);
                          });
                        },
                        onSendPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    if (index == 2) // gpt-model
                      Wrap(
                        children: <ChoiceChip>[
                          for (var model in _models)
                            ChoiceChip(
                              label: Text(model),
                              selected: _label['model'] == model,
                              onSelected: (bool selected) {
                                setState(() {
                                  _label['model'] = model;
                                });
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
