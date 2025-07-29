import 'dart:convert';

import 'package:civils_gpt/providers/ConstantsProvider.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class OpenAi {
  Future<String> searchText(String text, BuildContext context) async {
    final constants =
        Provider.of<ConstantsProvider>(context, listen: false).values;
    final open_ai_key = constants['openAIKey']!;
    final prompt = constants['evaluationSuperPrompt']!;
    print(prompt);
    final combinedText = '$prompt $text'; // Combine the prompt with the input text
    try {
      Response response = await post(Uri.parse(constants['openAIBaseUrl']),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${open_ai_key}'
          },
          body: jsonEncode(<String, dynamic>{
            'model': constants['openAIModel'],
            'messages': [
              {'role': 'user', 'content': combinedText}
            ],
            'temperature': 0.2,
            'top_p': 0.9,
          }));
      if (response.statusCode == 200) {
        Map body_data = jsonDecode(response.body);
        return body_data['choices'][0]['message']['content'] ?? 'Error';
      } else {
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('------------------------');
        return "Error while Processing Request";
      }
    } catch (e) {
      print('Unhandled exception: $e');
    }
    return 'Error';
  }

  Future<String> pdfGenerationText(String text, BuildContext context) async {
    final constants =
        Provider.of<ConstantsProvider>(context, listen: false).values;
    final open_ai_key = constants['openAIKey']!;
    final prompt = constants['pdfGenerationPrompt']!;
    final combinedText = '$prompt$text'; // Combine the prompt with the input text
    try {
      Response response = await post(Uri.parse(constants['openAIBaseUrl']),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${open_ai_key}'
          },
          body: jsonEncode(<String, dynamic>{
            'model': constants['openAIModel'],
            'messages': [
              {'role': 'user', 'content': combinedText}
            ],
            'temperature': 0.2,
            'top_p': 0.9,
          }));
      if (response.statusCode == 200) {
        Map body_data = jsonDecode(response.body);
        return body_data['choices'][0]['message']['content'] ?? 'Error';
      } else {
        return "Error while Processing Request";
      }
    } on RequestFailedException catch (e) {
      print(e.message);
      print(e.statusCode);
    }
    return 'Error';
  }

  Future<String> generateHandwrittenNotes(
      String text, BuildContext context) async {
    final constants =
        Provider.of<ConstantsProvider>(context, listen: false).values;
    final open_ai_key = constants['openAIKey']!;
    final url = Uri.parse(constants['openAIBaseUrl']);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${open_ai_key}',
    };
    final body = jsonEncode({
      'model': constants['openAIModel'],
      'messages': [
        {
          'role': 'user',
          'content': '${constants['handwrittenNotesPrompt']}$text'
        }
      ],
      'temperature': 0.4,
      'n': 1,
      'stop': ['\n'],
    });

    try {
      Response response = await post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Safely access the content and provide a fallback
        final notes = data['choices']?[0]?['message']?['content'] as String? ?? '';
        return notes.trim();
      } else {
        print(response.body);
        // Return a user-friendly error message instead of throwing an exception here
        return 'Error: Failed to generate notes. Status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in generateHandwrittenNotes: $e');
      return 'Error: An exception occurred while generating notes.';
    }
  }

  Future<String> chat(List<Map<String, String>> _messages,String question, BuildContext context) async {
    final constants =
        Provider.of<ConstantsProvider>(context, listen: false).values;
    final open_ai_key = constants['openAIKey']!;
    final prompt = constants['chatPrompt']!;
    List<Map<String, String>> messages = [];
    messages.addAll(_messages);
    messages.add({
      'role':'user',
      'content': prompt + question
    });
    try {
      Response response = await post(Uri.parse(constants['openAIBaseUrl']),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${open_ai_key}'
          },
          body: jsonEncode(<String, dynamic>{
            'model': constants['openAIModel'],
            'messages': messages,
            'temperature': 0.2,
          }));
      if (response.statusCode == 200) {
        Map body_data = jsonDecode(response.body);
        return body_data['choices'][0]['message']['content'] ?? 'Error';
      } else {
        print(response.body);
        return 'Error while fetching results';
      }
    } on RequestFailedException catch (e) {
      print(e.message);
      print(e.statusCode);
    }
    return 'Error while fetching result';
  }

  Future<String> generateQuestion(String subject, String topic, BuildContext context) async {
    final constants =
        Provider.of<ConstantsProvider>(context, listen: false).values;
    final open_ai_key = constants['openAIKey']!;
    final prompt = 'Generate a UPSC CSE mains question for the subject $subject'
        '${topic.isNotEmpty ? ' on the topic $topic' : ''}. Make sure the question is relevant with recent pattern of questions in UPSC.';

    try {
      Response response = await post(Uri.parse(constants['openAIBaseUrl']),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${open_ai_key}'
          },
          body: jsonEncode(<String, dynamic>{
            'model': constants['openAIModel'],
            'messages': [{'role': 'user', 'content': prompt}],
            'temperature': 0.2,
            'top_p': 0.9
          }));
      if (response.statusCode == 200) {
        Map body_data = jsonDecode(response.body);
        return body_data['choices'][0]['message']['content'] ?? 'Error';
      } else {
        print(response.body);
        return 'Error while fetching results';
      }
    } on RequestFailedException catch (e) {
      print(e.message);
      print(e.statusCode);
    }
    return 'Error while fetching result';
  }
}
