import 'package:civils_gpt/constants/AppConstants.dart';
import 'package:civils_gpt/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/dashboardItem.dart';
import '../models/docModel.dart';
import '../services/SqlQuery.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<DocModel> allDocs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppConstants.primaryColour,
        backgroundColor: AppConstants.primaryColour,
        title: const Text(
          "Completed Evaluations",
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: loading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : allDocs.isEmpty
                ? const Center(
                    child: Text('No Documents Found!'),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: AppConstants.modelColor,
                            isDismissible: true,
                            context: context,
                            enableDrag: true,
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      width: 70,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        "File Name: ${allDocs[index].fileName}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                                      child: Row(children: [
                                        const Text("Download Evaluation Matrix: ", style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),),
                                      TextButton(onPressed: (){
                                        PDFService(context: context).shareSavedPdf(allDocs[index].pdfName);
                                      }, child: const Icon(Icons.get_app))
                                      ],),
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Result: ${allDocs[index].result}",
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: DashboardItem(
                            allDocs[index].fileName,
                            allDocs[index].filePath,
                            allDocs[index].result,
                            allDocs[index].date),
                      );
                    },
                    itemCount: allDocs.length),
      ),
    );
  }

  void getData() async {
    Database database = await SqlQuery().openDb();
    List<DocModel> allDocs = await SqlQuery().getDocs(database);
    print(allDocs.length);
    setState(() {
      for (var doc in allDocs) {
        this.allDocs.add(doc);
      }
      loading = false;
    });
  }
}
