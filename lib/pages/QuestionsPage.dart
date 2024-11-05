import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:civils_gpt/constants/AppConstants.dart';
import 'package:civils_gpt/services/openAi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final _topicController = TextEditingController();
  String _selectedSubject = 'General Studies';
  String _generatedQuestion = '';
  bool _isLoading = false;

  Future<void> _generateQuestion() async {
    setState(() {
      _isLoading = true;
    });
    final topic = _topicController.text.trim();
    final subject = _selectedSubject;
    final question =  await OpenAi().generateQuestion(subject, topic, context);
    setState(() {
      _generatedQuestion = question;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColour,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24)),
        title: const Text(
          'Generate Questions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              color: AppConstants.textBubbleColour,
              elevation: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Pick a topic",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CustomDropdown<String>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: AppConstants.primaryColour,
                            expandedFillColor: AppConstants.primaryColour,
                            closedBorderRadius: BorderRadius.circular(28),
                            expandedBorderRadius: BorderRadius.circular(28)),
                        initialItem: _selectedSubject,
                        items: const <String>[
                          'General Studies',
                          'History and Geography of the World and Society',
                          'Indian Society',
                          'Indian Heritage and Culture',
                          'Governance',
                          'Indian Constitution',
                          'Polity',
                          'Social Justice',
                          'International relations',
                          'Indian Economy',
                          'Security and Disaster Management',
                          'Science & Technology',
                          'Environment & Ecology',
                          'Ethics',
                          'Integrity',
                          'Aptitude'
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSubject = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10), // Spacing
                    TextField(
                      controller: _topicController,
                      decoration: InputDecoration(
                        fillColor: AppConstants.primaryColour,
                        labelText: 'Additional Information (Optional)',
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24))),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _generateQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColour,
                        // Button color
                        padding: EdgeInsets.symmetric(
                            vertical:
                                _isLoading ? 14 : 17), // Padding for button
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Generate Question',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _generatedQuestion.isNotEmpty
                      ? _generatedQuestion
                      : 'Generated question will appear here',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
