import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/AppConstants.dart';
import '../services/helper.dart';
import '../services/openAi.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late PDFService _pdfService;
  final OpenAi _openAIService = OpenAi();
  String? _notes;
  bool loading = false;
  var fileName = '';
  var filePath = '';
  var result = '';
  var fileExtension = '';

  Future<void> _generateNotes(BuildContext context) async {
    if (filePath.isNotEmpty) {
      setState(() {
        loading = true;
      });
      final pdfText = await _pdfService.extractText(filePath);
      final notes =
          await _openAIService.generateHandwrittenNotes(pdfText, context);
      setState(() {
        _notes = notes;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _pdfService = PDFService(context: context);
    return Scaffold(
        backgroundColor: AppConstants.primaryColour,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24),
          ),
          title: const Text(
            'Notes Generation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 115.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_notes == null || _notes!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: GestureDetector(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'txt'],
                          );
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            setState(() {
                              fileName = file.name;
                              filePath = file.path!;
                              fileExtension = file.extension!;
                            });
                          }
                        },
                        child: Stack(children: [
                          Container(
                            height: 130,
                            width: MediaQuery.of(context).size.width - 40,
                            decoration: BoxDecoration(
                                color: AppConstants.uploadBoxColour,
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  fileExtension.toLowerCase() == "pdf"
                                      ? FontAwesomeIcons.filePdf
                                      : fileExtension.toLowerCase() == "jpg"
                                          ? FontAwesomeIcons.image
                                          : FontAwesomeIcons.upload,
                                  size: 30,
                                  color: AppConstants.secondaryColour,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, left: 20, right: 20),
                                  child: Text(
                                    fileName.isEmpty
                                        ? "Select File to upload"
                                        : "Selected File: $fileName",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppConstants.uploadTextColour),
                                  ),
                                )
                              ],
                            ),
                          ),
                          DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: const [6, 3, 6, 3],
                              strokeWidth: 2,
                              color: AppConstants.secondaryColour,
                              radius: const Radius.circular(20),
                            ),
                            child: Container(
                              height: 126,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ])),
                  ),
                if (loading) const Center(child: CircularProgressIndicator()),
                if (!loading && _notes != null && _notes!.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Generated Notes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConstants.uploadBoxColour,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          _notes!,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        floatingActionButton: (fileName.isNotEmpty)
            ? FloatingActionButton.extended(
                onPressed: () {
                  if (_notes != null && _notes!.isNotEmpty) {
                    setState(() {
                      _notes = null;
                      filePath = '';
                      fileExtension = '';
                      fileName = '';
                    });
                  } else {
                    _generateNotes(context);
                  }
                },
                backgroundColor: AppConstants.secondaryColour,
                label: Text(
                  (_notes != null && _notes!.isNotEmpty) ? 'Clear' : 'Generate',
                  style: TextStyle(color: AppConstants.primaryColour),
                ),
                icon: Icon(
                  FontAwesomeIcons.circleArrowUp,
                  color: AppConstants.primaryColour,
                ))
            : Container());
  }
}
