import 'package:civils_gpt/pages/EvaluationPage.dart';
import 'package:civils_gpt/providers/ConstantsProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/AppConstants.dart';
import '../models/docModel.dart';
import '../providers/PremiumProvider.dart';
import '../services/SqlQuery.dart';
import '../services/helper.dart';
import '../services/openAi.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final fileNameController = TextEditingController();
  final promptController = TextEditingController();
  var fileName = '';
  var filePath = '';
  var result = '';
  var fileExtension = '';
  List<DocModel> allDocs = [];
  bool loading = true;
  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  void getData() async {
    Database database = await SqlQuery().openDb();
    List<DocModel> allDocs = await SqlQuery().getDocs(database);

    setState(() {
      this.allDocs.clear();
      for (var doc in allDocs) {
        this.allDocs.add(doc);
      }
      loading = false;
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
                print(FirebaseAuth.instance.currentUser!.uid);
                Navigator.pop(context);
              },
              icon: const Icon(FontAwesomeIcons.arrowLeft, size: 24)),
          title: const Text(
            'Answer Evaluation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'pdf', 'png'],
                    );
                    if (result != null) {
                      PlatformFile file = result.files.first;
                      setState(() {
                        fileName = file.name;
                        filePath = file.path!;
                        fileNameController.text = fileName;
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
                      dashPattern: const [6, 3, 6, 3],
                      borderType: BorderType.RRect,
                      strokeWidth: 2,
                      color: AppConstants.secondaryColour,
                      radius: const Radius.circular(20),
                      child: Container(
                        height: 126,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ]),
                ),
              ),
              if (fileName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: SearchBar(
                    elevation: const WidgetStatePropertyAll(0),
                    controller: promptController,
                    hintText: 'Any Relevant query for Evaluation',
                  ),
                ),
              if (fileName.isEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: SizedBox(
                      height: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recent Files",
                                style: TextStyle(
                                    color: AppConstants.onSurfaceColour,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              if (allDocs.isNotEmpty)
                                Text(
                                  "${allDocs.length} ${allDocs.length == 1 ? "File" : "Files"}",
                                  style: TextStyle(
                                      color: AppConstants.onSurfaceColour,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                )
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                                itemCount: allDocs.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: SizedBox(
                                      height: 70,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            allDocs[index]
                                                    .fileName
                                                    .toLowerCase()
                                                    .contains("pdf")
                                                ? Icons.picture_as_pdf
                                                : Icons.image,
                                            size: 40,
                                            color: AppConstants.pdfIconColor,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                allDocs[index].fileName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppConstants
                                                        .listTextColour,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              size: 30,
                                              color: AppConstants.pdfIconColor,
                                            ),
                                            onPressed: () async {
                                              var db =
                                                  await SqlQuery().openDb();
                                              await SqlQuery().deleteDoc(
                                                  allDocs[index], db);
                                              setState(() {
                                                loading = true;
                                              });
                                              getData();
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
        floatingActionButton: fileName.isEmpty
            ? Container()
            : Consumer<PremiumProvider>(builder:
                (BuildContext context, PremiumProvider value, Widget? child) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(userID)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return FloatingActionButton.extended(
                          backgroundColor: AppConstants.secondaryColour,
                          onPressed: () async {
                            if (filePath != '' &&
                                (value.premium || value.counter > 0)) {
                              BuildContext progressContext = context;
                              showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  progressContext = context;
                                  return const CupertinoAlertDialog(
                                    title: Text('Generating Response...'),
                                  );
                                },
                              );
                            print("hello _ " + Provider.of<ConstantsProvider>(context, listen: false).values.toString());
                              var text = await PDFService(context: context)
                                  .extractText(filePath);
                              var openAi = await OpenAi().searchText(
                                  '${promptController.text} $text', context);
                              var pdfResponse = await OpenAi().pdfGenerationText('${promptController.text} $text', context);
                              DateTime now = DateTime.now();
                              String formattedTimestamp = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_"
                                  "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
                              String generatedFileName = "evaluation_matrix_$formattedTimestamp.pdf";
                              await PDFService(context: context).generatePdf(pdfResponse, generatedFileName);
                              updateDatabase();
                              Navigator.pop(progressContext);
                              var db = await SqlQuery().openDb();
                              var id = await SqlQuery().countDocs(db) + 1;
                              await SqlQuery().insertDoc(
                                  DocModel(
                                      id: id,
                                      pdfName: generatedFileName,
                                      fileName: fileName,
                                      filePath: filePath,
                                      result: openAi,
                                      date:
                                          '${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()}'),
                                  db);

                              setState(() {
                                result = openAi;
                                promptController.clear();
                                fileName = '';
                                filePath = '';
                                fileExtension = '';
                                loading = true;
                              });
                              getData();
                              Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const EvaluationPage()));
                            } else if (!(value.premium ||
                                snapshot.data!.data()!["freeEvaluations"] >
                                    0)) {
                              Navigator.of(context).pop();
                            }
                          },
                          label: Text(
                            (value.premium ||
                                    snapshot.data!.data()!["freeEvaluations"] >
                                        0)
                                ? 'Proceed'
                                : 'Upgrade to Premium',
                            style: TextStyle(color: AppConstants.primaryColour),
                          ),
                          icon: Icon(
                            FontAwesomeIcons.circleArrowUp,
                            color: AppConstants.primaryColour,
                          ));
                    } else {
                      return Container();
                    }
                  },
                );
              }));
  }

  void updateDatabase() async {

    var userId = FirebaseAuth.instance.currentUser!.uid;
    int counter = await getCounter(userId);
    if (counter > 0) {
      counter--;
      PremiumProvider premiumProvider =
      Provider.of<PremiumProvider>(context, listen: false);
      premiumProvider.decrementCounter();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(<String, dynamic>{"freeEvaluations": counter});
    }
  }

  Future<int> getCounter(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    print(snapshot.data()!["freeEvaluations"]);
    return snapshot.data()!["freeEvaluations"];
  }
}
