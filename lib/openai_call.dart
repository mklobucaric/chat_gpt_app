import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Sends the query to the OpenAI API and returns the reply.
Future<String> sendQuery(
    List<dynamic> messages, String model, String temperature) async {
  String? apiKey = dotenv.env[
      'OPENAI_API_KEY']; // Retrieves the OpenAI API key from the environment

  const url =
      'https://api.openai.com/v1/chat/completions'; // URL for the OpenAI API
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer $apiKey' // Sets the authorization header with the API key
  };

  final body = jsonEncode({
    'model': model, // Specifies the model to use
    'messages': messages, // Sets the conversation messages
    'temperature': double.parse(
        temperature), // Controls the randomness of the generated response
    'n': 1, // Specifies the number of responses to generate
  });
  final response = await http.post(Uri.parse(url),
      headers: headers, body: body); // Sends a POST request to the OpenAI API
  final data = jsonDecode(response.body); // Parses the response body as JSON

  final choices =
      data['choices']; // Retrieves the generated choices from the response
  final text = choices[0]['message']
      ['content']; // Retrieves the generated text from the first choice

  return utf8.decode(text.codeUnits); // Returns the generated text
}

// Sends the audio file to the OpenAI API and returns the transcribed text.
Future<String> sendAudioFile(String filePath) async {
  String? _apiKey = dotenv.env['OPENAI_API_KEY'];
  const url = 'https://api.openai.com/v1/audio/transcriptions';
  final headers = {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'multipart/form-data'
  };

  final request = http.MultipartRequest('POST', Uri.parse(url));
  request.headers.addAll(headers);
  request.fields['model'] = 'whisper-1';
  request.fields['language'] = 'en';
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  final response = await request.send(); // Sends the multipart request
  final data = await response.stream
      .bytesToString(); // Reads the response stream as a string

  final text =
      jsonDecode(data)['text']; // Parses the 'text' field from the response

  return utf8.decode(text.codeUnits); // Returns the transcribed text
}
