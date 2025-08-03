// lib/pages/QuestionsPage.dart

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:civils_gpt/constants/AppConstants.dart';
import 'package:civils_gpt/services/helper.dart';
import 'package:civils_gpt/services/openAi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum to manage the output choice
enum OutputFormat { onScreen, pdf }

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

  int _selectedMarks = 10;
  OutputFormat _selectedFormat = OutputFormat.onScreen;

  Future<void> _generateQuestion() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _generatedQuestion = '';
    });

    try {
      final topic = _topicController.text.trim();
      final subject = _selectedSubject;
      final question = await OpenAi().generateQuestion(subject, topic, _selectedMarks, context);

      if (_selectedFormat == OutputFormat.onScreen) {
        setState(() {
          _generatedQuestion = question;
        });
      } else {
        await PDFGenerator.generateUPSCQuestionPaper(
          subject: subject,
          question: question,
          marks: _selectedMarks,
        );
      }
    } catch (e) {
      setState(() {
        _generatedQuestion = "An error occurred while generating the question.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24, color: Colors.black87)),
        title: Text(
          'Get Questions to Practice',
          style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputCard(),
                      const SizedBox(height: 30),
                      _buildOutputArea(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
          color: AppConstants.cardColour,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Pick a Subject"),
          CustomDropdown<String>(
            decoration: CustomDropdownDecoration(
                closedFillColor: Colors.white,
                expandedFillColor: Colors.white,
                closedBorderRadius: BorderRadius.circular(16),
                expandedBorderRadius: BorderRadius.circular(16)),
            initialItem: _selectedSubject,
            items: const [
              'General Studies', 'History and Geography of the World and Society', 'Indian Society', 'Indian Heritage and Culture', 'Governance', 'Indian Constitution', 'Polity', 'Social Justice', 'International relations', 'Indian Economy', 'Security and Disaster Management', 'Science & Technology', 'Environment & Ecology', 'Ethics', 'Integrity', 'Aptitude'
            ],
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => _selectedSubject = newValue);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _topicController,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              labelText: 'Additional Topic (Optional)',
              labelStyle: GoogleFonts.poppins(),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppConstants.secondaryColour, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle("Marks"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // <-- Use spaceEvenly for centering
            children: [10, 15, 20].map((marks) => ChoiceChip(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding for better spacing
                child: Text('$marks Marks'),
              ),
              selected: _selectedMarks == marks,
              onSelected: (selected) {
                if (selected) setState(() => _selectedMarks = marks);
              },
              selectedColor: AppConstants.secondaryColour,
              labelStyle: TextStyle(
                  color: _selectedMarks == marks ? Colors.white : Colors.black,
                  fontWeight: _selectedMarks == marks ? FontWeight.bold : FontWeight.normal
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: _selectedMarks == marks ? AppConstants.secondaryColour : Colors.grey.shade300)
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle("Output Format"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // <-- Use spaceEvenly for centering
            children: [
              ChoiceChip(
                label: const Text('On-screen'),
                selected: _selectedFormat == OutputFormat.onScreen,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedFormat = OutputFormat.onScreen);
                },
                selectedColor: AppConstants.secondaryColour,
                labelStyle: TextStyle(
                    color: _selectedFormat == OutputFormat.onScreen ? Colors.white : Colors.black,
                    fontWeight: _selectedFormat == OutputFormat.onScreen ? FontWeight.bold : FontWeight.normal
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: _selectedFormat == OutputFormat.onScreen ? AppConstants.secondaryColour : Colors.grey.shade300)
                ),
              ),
              ChoiceChip(
                label: const Text('UPSC-style PDF'),
                selected: _selectedFormat == OutputFormat.pdf,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedFormat = OutputFormat.pdf);
                },
                selectedColor: AppConstants.secondaryColour,
                labelStyle: TextStyle(
                    color: _selectedFormat == OutputFormat.pdf ? Colors.white : Colors.black,
                    fontWeight: _selectedFormat == OutputFormat.pdf ? FontWeight.bold : FontWeight.normal
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: _selectedFormat == OutputFormat.pdf ? AppConstants.secondaryColour : Colors.grey.shade300)
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildOutputArea() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_generatedQuestion.isNotEmpty && _selectedFormat == OutputFormat.onScreen) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: SelectableText(
          _generatedQuestion,
          style: GoogleFonts.poppins(fontSize: 18, height: 1.5),
          textAlign: TextAlign.left,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Text(
        'Your generated question will appear here.',
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColour,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
            'Generate Question',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}