import 'package:civils_gpt/constants/AppConstants.dart';
import 'package:civils_gpt/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import '../models/dashboardItem.dart';
import '../models/docModel.dart';
import '../services/SqlQuery.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage>
    with SingleTickerProviderStateMixin {
  List<DocModel> allDocs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    Database db = await SqlQuery().openDb();
    List<DocModel> docs = await SqlQuery().getDocs(db);
    setState(() {
      allDocs = docs;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar like HomePage
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColour,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Completed Evaluations",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : allDocs.isEmpty
              ? Center(
            child: Text(
              'No Documents Found!',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: allDocs.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, thickness: 1),
              itemBuilder: (context, i) {
                final doc = allDocs[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  onTap: () => _showDetails(context, doc),
                  leading: Icon(
                    Icons.description,
                    color: AppConstants.primaryColour,
                    size: 32,
                  ),
                  title: Text(
                    doc.fileName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    Helper().parseAnswer(doc.result),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  trailing: Text(
                    doc.date,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, DocModel doc) {
    showModalBottomSheet(
      backgroundColor: AppConstants.modelColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  doc.fileName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "Download Matrix:",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.get_app),
                      color: AppConstants.pdfIconColor,
                      onPressed: () {
                        PDFService(context: context)
                            .shareSavedPdf(doc.pdfName);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  Helper().parseAnswer(doc.result),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
