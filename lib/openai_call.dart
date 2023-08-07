import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> sendQuery(List<dynamic> messsages) async {
  String? apiKey = dotenv.env['OPENAI_API_KEY'];

  const url = 'https://api.openai.com/v1/chat/completions';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };

  final body = jsonEncode({
    'model': 'gpt-3.5-turbo-16k-0613',
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
