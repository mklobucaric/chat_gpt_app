import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> sendQuery(List<dynamic> messsages) async {
  String? _apiKey = dotenv.env['OPENAI_API_KEY'];

  final url = 'https://api.openai.com/v1/chat/completions';
  print(url);
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey'
  };

  final body = jsonEncode({
    'model': 'gpt-3.5-turbo-16k',
    'messages': messsages,
    // 'max_tokens': 1024,
    'temperature': 0.7,
    'n': 1,
    // 'stop': '\n'
  });
  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);
  final data = jsonDecode(response.body);
  final choices = data['choices'];
  final text = choices[0]['message']['content'];
  return text;
}