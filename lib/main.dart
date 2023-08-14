import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'openai_call.dart';
import 'record_voice.dart';
import 'widgets.dart';
import 'write_read_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'my_utils.dart';

Map<String, dynamic> _label = {
  'mode':
      'education', // 1. Initializing the 'mode' label with the default value 'education'
  'creativity':
      '1', // 2. Initializing the 'creativity' label with the default value '1'
  'model':
      'gpt-3.5-turbo-16k-0613' // 3. Initializing the 'model' label with the default value 'gpt-3.5-turbo-16k-0613'
};

final Map<String, dynamic> _initialPrompts = {
  'kids-boys-10y': [
    {
      "role": "system",
      "content": "You are a very helpful personal assistant and a world-class, patient educator for kids. "
          "You are educating 10 years old boy. Your responses should easy understandable for her "
          " not be too long and not trivial. Don't make up answers If you do not know something, "
          "you can say: "
          "'I do not know. Give me more details.' Your responses should be in Croatian language."
    }
  ],
  'kids-girls-13y': [
    {
      "role": "system",
      "content": "You are a very helpful personal assistant and a world-class, patient educator for kids. "
          "You are educating 13 years old girl. Your responses should easy understandable for her "
          " not be too long and not trivial. Don't make up answers If you do not know something, "
          "you can say: "
          "'I do not know. Give me more details.' Your responses should be in Croatian language."
    }
  ],
  'short': [
    {
      "role": "system",
      "content":
          "You are a very helpful personal assistant with critical thinking and are trying to"
              "give responses around 300 characters"
    }
  ],
  'normal': [
    {
      "role": "system",
      "content":
          "You are a very helpful personal assistant with critical thinking"
    }
  ],
  'education': [
    {
      "role": "system",
      "content": "You are a very helpful personal assistant and world class educator (like prof. Richard Feynman and his sense for humor), "
          "here to help and explain all kind of basic and difficult concepts in simple and concisely way."
          "Your output is structured in some general info and the rest in bullet points "
          "starting with numbers like 1., a., i. when necessary. You are able to summarize "
          "long texts."
    }
  ]
};

List<dynamic> _messages = [
  {
    "role": "system",
    "content": "You are a very helpful personal assistant and world class educator (like prof. Richard Feynman and his sense for humor), "
        "here to help and explain all kind of basic and difficult concepts in simple and concisely way."
        "Your output is structured in some general info and the rest in bullet points "
        "starting with numbers like 1., a., i. when necessary. You are able to summarize "
        "long texts."
  }
]; // Stores the conversation _messages

Future<void> loadLabelMap() async {
  var statusStorage = await Permission.storage.status;
  if (!statusStorage.isGranted) {
    await Permission.storage.request();
  }
  _label = await loadMapFromFile(); // 4. Loading label map from file
  _messages = deepCopyList(_initialPrompts[
      _label['mode']]); // 5. Loading initial prompts based on the 'mode' label
}

// The main function that serves as the entry point of the application.
Future main() async {
  await dotenv.load(
      fileName: '.env'); // Loads environment variables from a .env file
  WidgetsFlutterBinding.ensureInitialized();
  await loadLabelMap();
  runApp(const MyApp()); // Runs the app
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
  const MyHomePage({Key? key});

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

  int _selectedIndex = 0;

  final List<String> _modes = [
    'kids-boys-10y',
    'kids-girls-13y',
    'short',
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

  FocusNode _focusNode = FocusNode();

  Future loadLabelMap() async {
    _label = await loadMapFromFile(); // 6. Loading label map from file
  }

  @override
  void dispose() {
    _queryController.dispose(); // Disposes the query text field controller
    super.dispose();
  }

  // Sends the query to the OpenAI API and updates the UI with the reply.
  Future<void> _sendQuery() async {
    setState(() {
      _isLoading = true; // Sets the loading state
      _messages.add({
        "role": "user",
        "content": _query
      }); // 7. Adding user query to the conversation messages
    });

    final reply = await sendQuery(
        _messages,
        _label['model'],
        _label[
            'creativity']); // Calls the sendQuery function from openai_call.dart

    setState(() {
      _reply = reply; // Updates the AI assistant's response
      // Adds the assistant's response to the conversation
      _isLoading = false; // Resets the loading state
      _messages.add({
        "role": "assistant",
        "content": reply
      }); // 8. Adding assistant's response to the conversation messages
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
    });
    _sendQuery();
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
                  focusNode: _focusNode,
                  maxLines: null,
                  controller: _queryController,
                  onChanged: (value) {
                    setState(() {
                      _query = value; // Updates the user's query
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
                          _focusNode.unfocus();
                        },
                  child: const Icon(Icons.send),
                ),
                const SizedBox(width: 16), // Add some space between the buttons
                ElevatedButton(
                  onPressed: () {
                    // Add your code here
                    _voiceRecorerScreen();
                    _focusNode.unfocus();
                  },
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
                setState(() {
                  _messages = deepCopyList(_initialPrompts[
                      _label['mode']]); // 9. Resets the conversation messages
                });
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
            label: _label[
                'mode'], // 10. Displaying the current 'mode' label in the bottom navigation bar
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.spa,
            ),
            label: _label[
                'creativity'], // 11. Displaying the current 'creativity' label in the bottom navigation bar
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.precision_manufacturing,
            ),
            label: _label[
                'model'], // 12. Displaying the current 'model' label in the bottom navigation bar
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
                        direction: Axis.vertical,
                        children: <ChoiceChip>[
                          for (var mode in _modes)
                            ChoiceChip(
                              label: Text(mode),
                              selected: _modes[index] == mode,
                              onSelected: (bool selected) {
                                setState(() {
                                  _label['mode'] =
                                      mode; // 13. Updates the 'mode' label based on the selected value
                                });
                                saveMapToFile(
                                    _label); // Saves the label map to file
                                _messages = deepCopyList(_initialPrompts[_label[
                                    'mode']]); // 14. Updates the conversation messages based on the new 'mode' label
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    if (index == 1) // creativity
                      SliderWidget(
                        value: double.parse(_label[
                            'creativity']!), // 15. Converts the 'creativity' label to double for the SliderWidget
                        onChanged: (value) {
                          setState(() {
                            _label['creativity'] = value.toStringAsFixed(
                                1); // 16. Updates the 'creativity' label based on the slider value
                          });
                          saveMapToFile(_label); // Saves the label map to file
                        },
                        onSendPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    if (index == 2) // gpt-model
                      Wrap(
                        direction: Axis.vertical,
                        children: <ChoiceChip>[
                          for (var model in _models)
                            ChoiceChip(
                              label: Text(model),
                              selected: _label['model'] == model,
                              onSelected: (bool selected) {
                                setState(() {
                                  _label['model'] =
                                      model; // 17. Updates the 'model' label based on the selected value
                                });
                                saveMapToFile(
                                    _label); // Saves the label map to file
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
