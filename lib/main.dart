import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'openai_call.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _query = '';
  String _reply = '';
  bool _isLoading = false;
  final TextEditingController _queryController = TextEditingController();
  List<dynamic> messsages = [
    {
      "role": "system",
      "content": "You are a very helpful personal assistant, here to help you with your daily tasks,"
          " and your are the best at explaining difficult concepts in simple and concisely way."
          "Your output is structured in some general info and the rest in bullet points "
          "startig with numbers like 1., a., i. when necessary. You are able to summarize "
          "long texts."
    }
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _sendQuery() async {
    setState(() {
      _isLoading = true;
      // messsages.add({"role": "user", "content": "$_query\n"});
      messsages.add({"role": "user", "content": _query});
    });
    final reply = await sendQuery(messsages);
    setState(() {
      _reply = reply;
      messsages.add({"role": "assistant", "content": reply});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with GPT-3.5-Turbo-16k-0613'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _queryController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              onSubmitted: (value) {
                if (value.isEmpty) {
                  _queryController.clear();
                  _queryController.text = '';
                } else {
                  _sendQuery();
                  _queryController.clear();
                  _queryController.text = '';
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your query',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _sendQuery();
                      _queryController.clear();
                      _queryController.text = '';
                    },
              child: Text('Send'),
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
                            // Text(_reply), shoud be able to copy text

                            child: Text(_reply),
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
                    "content": "You are a very helpful personal assistant, here to help you with your daily tasks,"
                        " and your are the best at explaining difficult concepts in simple and concisely way."
                        "Your output is structured in some general info and the rest in bullet points "
                        "startig with numbers like 1., a., i. when necessary. You are able to summarize "
                        "long texts."
                  }
                ];
              },
              child: Text('New query'),
            ),
          ],
        ),
      ),
    );
  }
}
