import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  final String apiUrl = "https://api.groq.com/chat/completions"; // Replace with actual API URL
  final String apiKey = "your-api-key"; // Replace with your API key

  Future<Map<String, dynamic>> getPoultryAdvice(String temperature, String humidity, String farmState) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "llama-3.3-70b-versatile",
      "messages": [
        {
          "role": "system",
          "content": "You are an assistant specialized in poultry farm management. Your role is, based on the data on my temperature, humidity and poultry farm state, comment and give me advice on what to do based on that data. Be friendly, use simple language, be your users' poultry farm help. Send the response in a json format having structure {\"comment\": string, \"advice\": string}."
        },
        {
          "role": "user",
          "content": "Temperature: $temperature, Humidity: $humidity, Farm State: $farmState"
        }
      ],
      "temperature": 1,
      "max_tokens": 300,
      "top_p": 1,
      "response_format": {"type": "json_object"},
    });

    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message'];
    } else {
      throw Exception('Failed to fetch advice: ${response.statusCode}');
    }
  }
}
