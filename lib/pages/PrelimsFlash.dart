import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class PrelimsFlashPage extends StatefulWidget {
  @override
  _PrelimsFlashPageState createState() => _PrelimsFlashPageState();
}

class _PrelimsFlashPageState extends State<PrelimsFlashPage> {
  int questionCount = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  String? questionText;
  List<String> options = [];
  String? selectedAnswer;
  List<Map<String, dynamic>> sessionData = [];
  String? previousQuestion;

  void startSession() async {
    setState(() {
      questionCount = 0;
      correctAnswers = 0;
      incorrectAnswers = 0;
      sessionData.clear();
    });
    fetchQuestion();
  }

  Future<void> fetchQuestion() async {
    if (questionCount >= 100) {
      endSession();
      return;
    }

    final response = await http.post(
        Uri.parse("https://your-api.com/get_prelims_question"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"previous_question": previousQuestion})
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        questionText = data['question'];
        options = List<String>.from(data['options']);
        previousQuestion = questionText;
        questionCount++;
      });
    }
  }

  void submitAnswer(String answer) {
    bool isCorrect = (answer == options[0]); // Assuming first option is correct
    setState(() {
      if (isCorrect) {
        correctAnswers++;
      } else {
        incorrectAnswers++;
      }
      sessionData.add({
        "question": questionText,
        "selected": answer,
        "correct": isCorrect
      });
    });
    fetchQuestion();
  }

  void endSession() {
    double score = (2 * correctAnswers) - (0.666 * incorrectAnswers);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Session Complete"),
          content: Text("Your Score: $score"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK")
            ),
            TextButton(
                onPressed: exportQuestions,
                child: Text("Download Questions")
            )
          ],
        )
    );
  }

  Future<void> exportQuestions() async {
    List<List<String>> csvData = [
      ["Question", "Selected Answer", "Correct"]
    ] + sessionData.map((q) => [q['question'].toString(), q['selected'].toString(), q['correct'].toString()]).toList() as List<List<String>>;

    String csv = const ListToCsvConverter().convert(csvData);
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/prelims_flash.csv");
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Questions downloaded at ${file.path}"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prelims Flash")),
      body: questionText == null
          ? Center(
          child: ElevatedButton(
              onPressed: startSession,
              child: Text("Start Session")
          )
      )
          : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Question $questionCount:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(questionText!, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ...options.map((option) => RadioListTile(
                  title: Text(option),
                  value: option,
                  groupValue: selectedAnswer,
                  onChanged: (val) {
                    setState(() => selectedAnswer = val as String);
                    submitAnswer(val as String);
                  },
                )).toList(),
              ]
          )
      ),
    );
  }
}
