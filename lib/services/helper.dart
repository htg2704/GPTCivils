import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as imglib;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/ConstantsProvider.dart';
import '../providers/PremiumProvider.dart';

class LoginHelper {
  void checkPremiumStatus(PremiumProvider premiumProvider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        if (userDoc.data() == null) {
          FirebaseFirestore.instance.collection("users").doc(user.uid).set(
              <String, dynamic>{"freeEvaluations": 1, "premiumUser": "NO"});
        }
      } catch (e) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set(<String, dynamic>{"freeEvaluations": 1, "premiumUser": "NO"});
      }
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (userDoc.data()!["premiumUser"] != "NO") {
        if (DateTime.now().millisecondsSinceEpoch <
            DateTime.parse(userDoc.data()!["premiumUser"])
                .millisecondsSinceEpoch) {
          premiumProvider.changePremium(DateTime.parse(userDoc.data()!["premiumUser"]).toString(), userDoc.data()!["planID"]);
        } else {
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"premiumUser", "NO"} as Map<Object, Object?>);
        }
      } else {
        if (userDoc.data()!["freeEvaluations"] > 0) {
          premiumProvider.setCounter(userDoc.data()!["freeEvaluations"]);
        }
      }
    }
  }
}

class PaymentHelper {
  final db = FirebaseFirestore.instance;
  Map<String, dynamic>? plan;
  String? code;
  Completer<bool>? _paymentCompleter;
  Future<int> checkDiscountCode(String code, String planID) async {
    final discountCodesCollection = db.collection("discount_codes");
    final discountCodes =
    await discountCodesCollection.where('code', isEqualTo: code).get();
    if (discountCodes.size == 1) {
      if (discountCodes.docs[0].data()["planIDs"].contains(planID)) {
        return discountCodes.docs[0].data()['discount'];
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<void> razorPayCall(int value) async {
    final _razorpay = Razorpay();
    final constants = await db.collection("constants").get();

    var options = {
      'key': constants.docs[0].data()["razorpay_key"],
      'amount': value * 100,
      'name': 'CivilsGPT',
      'description': 'CivilsGPT subscription',
    };

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _razorpay.open(options);
  }


  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      DateTime currentTimestamp = DateTime.now();
      int x = plan!["days"];
      DateTime newTimestamp = currentTimestamp.add(Duration(days: x));

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      final userData = userDoc.data()!;
      if (code!.isNotEmpty && userData.containsKey("history")) {
        if (userData["history"].containsKey(code)) {
          Map<String, dynamic> history = userData["history"];
          history[code!] = history[code]! + 1;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"history": history});
        } else {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"history": {code: 1}});
        }
      } else if (code!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"history": {code: 1}});
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({
        "planID": plan!["planID"],
        "premiumUser": newTimestamp.toString(),
      });

      await FirebaseFirestore.instance.collection("payments").doc().set({
        "paymentID": response.paymentId,
        "userID": user.uid,
      });

      _paymentCompleter?.complete(true); // ✅ Complete with success
    } catch (e) {
      _paymentCompleter?.complete(false); // Optional fallback
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(response.toString());
    _paymentCompleter?.complete(false); // ✅ Complete with failure
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(response.toString());
    _paymentCompleter?.complete(false);
  }


  Future<bool> finalCheckout(String code) async {
    if (code.isEmpty) {
      return true;
    }
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final document = await db.collection("users").doc(userID).get();
    final discountCodesCollection = db.collection("discount_codes");
    final discountCodes =
    await discountCodesCollection.where('code', isEqualTo: code).get();
    int maxUses = discountCodes.docs[0].data()['maxUse'];
    final userData = document.data()!;
    final history = userData["history"];

    if (history != null && history.keys.contains(code)) {
      int currentUses = history[code];
      if (currentUses >= maxUses) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }


  Future<bool> doPayment(int value, PremiumProvider premiumProvider,
      Map<String, dynamic> plan, String code) async {
    this.plan = plan;
    this.code = code;
    bool finalCheck = await finalCheckout(code);
    if (!finalCheck) {
      return false;
    }
    _paymentCompleter = Completer<bool>();
    await razorPayCall(value);
    return _paymentCompleter!.future;
  }
}

class PDFService {
  final BuildContext context;
  late String apiKey;

  PDFService({required this.context}) {
    this.apiKey = Provider.of<ConstantsProvider>(context, listen: false)
        .values['googleCloudVisionApiKey'];
  }

  Future<void> shareSavedPdf(String fileName) async {
    try {
      // Step 1: Get the application directory where the PDF is saved
      Directory directory = await getApplicationDocumentsDirectory();
      String path = '${directory.path}/$fileName';

      // Step 2: Check if the file exists
      File pdfFile = File(path);
      if (await pdfFile.exists()) {
        // Step 3: Share the PDF using the Printing package
        await Printing.sharePdf(
          bytes: await pdfFile.readAsBytes(),  // Read PDF bytes
          filename: fileName,                  // Use the file name for sharing
        );
      } else {
        print("PDF file does not exist at $path");
      }
    } catch (e) {
      print("Error sharing PDF: $e");
    }
  }

  // Main method to extract text from a file path (PDF or Image)
  Future<String> extractText(String filePath) async {
    File file = File(filePath);
    // Check if the file is a PDF or an Image
    if (file.path.toLowerCase().endsWith('.pdf')) {
      return await _extractTextFromPdf(file);
    } else if (file.path.toLowerCase().endsWith('.png') ||
        file.path.toLowerCase().endsWith('.jpg') || file.path.toLowerCase().endsWith('.jpeg')) {
      return await _callGoogleVisionAPI(file);
    } else {
      throw Exception('Unsupported file format');
    }
  }

  // Extract text from PDF
  Future<String> _extractTextFromPdf(File pdfFile) async {
    String combinedText = "";

    try {
      // Open PDF document
      final doc = await PdfDocument.openFile(pdfFile.path);
      final pages = doc.pageCount;
      List<imglib.Image> images = [];

// get images from all the pages
      for (int i = 1; i <= pages; i++) {
        var page = await doc.getPage(i);
        var imgPDF = await page.render();
        var img = await imgPDF.createImageDetached();
        var imgBytes = await img.toByteData(format: ImageByteFormat.png);
        var libImage = imglib.decodeImage(imgBytes!.buffer
            .asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes));
        images.add(libImage!);
      }

// stitch images
      int totalHeight = 0;
      images.forEach((e) {
        totalHeight += e.height;
      });
      int totalWidth = 0;
      images.forEach((element) {
        totalWidth = totalWidth < element.width ? element.width : totalWidth;
      });
      final mergedImage = imglib.Image(width: totalWidth, height: totalHeight);
      int mergedHeight = 0;
      images.forEach((element) {
        imglib.compositeImage(mergedImage, element,
            dstX: 0, dstY: mergedHeight);
        mergedHeight += element.height;
      });

// Save image as a file
      final documentDirectory = await getTemporaryDirectory();
      File imgFile = File('${documentDirectory.path}/pages.png');
      File(imgFile.path).writeAsBytes(imglib.encodeJpg(mergedImage));
      combinedText = await _callGoogleVisionAPI(imgFile);
      return combinedText;
    } catch (e) {
      print(e);
      return "";
    }
  }

  // Call Google Vision API to extract text from an image
  Future<String> _callGoogleVisionAPI(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Create the request body for TEXT_DETECTION
    Map<String, dynamic> requestBody = {
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION'}
          ]
        }
      ]
    };

    final String url =
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return _extractTextFromResponse(jsonResponse);
    } else {
      throw Exception('Failed to extract text: ${response.statusCode}');
    }
  }

  // Extract text from Google Vision API response
  String _extractTextFromResponse(Map<String, dynamic> jsonResponse) {
    String combinedText = "";

    if (jsonResponse['responses'] != null &&
        jsonResponse['responses'][0]['fullTextAnnotation'] != null) {
      combinedText = jsonResponse['responses'][0]['fullTextAnnotation']['text'];
    }

    return combinedText;
  }

  Future<void> generatePdf(String response, String fileName) async {
    final pdf = pw.Document();

    // Create a header style
    final headerStyle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    );

    const textStyle = pw.TextStyle(
      fontSize: 10,
    );

    final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');

    // Attempt to match the pattern
    final match = regex.firstMatch(response);

    // Extract the JSON-like content or use the response as-is
    String jsonString;
    if (match != null && match.groupCount > 0) {
      jsonString = match.group(1)!.trim(); // Extract JSON between backticks
    } else {
      jsonString = response.trim(); // Use the whole string if no markers found
    }

    Map<String, dynamic> data = jsonDecode(jsonString);
    List<dynamic>? evaluationData = data["evaluation"];
    String evaluationQuestion = data["question"]??"";
    int maxLen = 0;
    for (var d in evaluationData!) {
      if (maxLen < d['comment'].toString().length) {
        maxLen = d['comment'].toString().length;
      }
    }
    List<pw.TableRow> rows = evaluationData.map((eval) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text((evaluationData.indexOf(eval) + 1).toString(),
                style: textStyle),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(eval['criteria'].toString(),
                style: textStyle, softWrap: true),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(eval['max_score'].toString(), style: textStyle),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(eval['score'].toString(), style: textStyle),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(eval['comment'].toString(),
                style: textStyle, softWrap: true),
          ),
        ],
      );
    }).toList();

    rows = [
      pw.TableRow(
        children: [
          pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Sr No.', style: headerStyle)),
          pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Criteria', style: headerStyle)),
          pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Maximum Marks', style: headerStyle)),
          pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Marks Obtained', style: headerStyle)),
          pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Comments', style: headerStyle)),
        ],
      )
    ] +
        rows;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(mainAxisSize: pw.MainAxisSize.max, children: [
            pw.Container(
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text(
                    'Evaluation Matrix',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  )),
            ),
            if(evaluationQuestion.isNotEmpty)
              pw.Container(
                child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Wrap(children: [
                      pw.Text(
                        'Question: $evaluationQuestion',
                        style: const pw.TextStyle(
                            fontSize: 16),
                        textAlign: pw.TextAlign.center,
                      )
                    ])),
              ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(4),
              },
              children: rows,
            )
          ]);
        },
      ),
    );
    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
  }
}

class LoadConstants {
  void loadConstantsFromFirebase(ConstantsProvider constantsProvider) async {
    final constantDocuments =
    await FirebaseFirestore.instance.collection("constants").get();
    final constants = constantDocuments.docs[0].data();
    constantsProvider.updateConstants(constants);
  }
}

class Helper{
  String parseAnswer(String text){

    try {
      final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
      final match = regex.firstMatch(text);
      String jsonString;
      if (match != null && match.groupCount > 0) {
        jsonString = match.group(1)!.trim();
      } else {
        jsonString = text.trim();
      }
      final parsedJson = json.decode(jsonString);
      return "Improvements: " + parsedJson['improvements'] + "\n Model Answer: " + parsedJson["model_answer"];
    } catch (e) {
      return "Error parsing the response";
    }
  }
}
