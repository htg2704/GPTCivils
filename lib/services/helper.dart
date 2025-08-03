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
import 'package:pdfx/pdfx.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/ConstantsProvider.dart';
import '../providers/PremiumProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class LoginHelper {
  Future<void> checkPremiumStatus(PremiumProvider premiumProvider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If there's no user, they are not premium.
      premiumProvider.updatePremiumStatus(newState: PremiumState.notPremium);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      // If the user document doesn't exist, create it.
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "freeEvaluations": 1,
          "premiumUser": "NO"
        });
        premiumProvider.setCounter(1);
        premiumProvider.updatePremiumStatus(newState: PremiumState.notPremium);
        return;
      }

      // --- START OF THE FIX ---
      final userData = userDoc.data()!;
      final premiumUserStatus = userData['premiumUser'];

      if (premiumUserStatus != null && premiumUserStatus != "NO") {
        final expiryDate = DateTime.parse(premiumUserStatus);

        // Check if the premium subscription is still active
        if (DateTime.now().isBefore(expiryDate)) {
          // User IS premium
          premiumProvider.updatePremiumStatus(
            newState: PremiumState.isPremium,
            expiryDate: expiryDate,
            newPlanID: userData['planID'],
          );
        } else {
          // Premium has expired. Update Firestore and the provider.
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({"premiumUser": "NO"});
          premiumProvider.updatePremiumStatus(newState: PremiumState.notPremium);
        }
      } else {
        // User is NOT premium. Set their free counter.
        premiumProvider.setCounter(userData['freeEvaluations'] ?? 0);
        premiumProvider.updatePremiumStatus(newState: PremiumState.notPremium);
      }
      // --- END OF THE FIX ---

    } catch (e) {
      print("Error checking premium status: $e");
      // If any error occurs, default to not premium.
      premiumProvider.updatePremiumStatus(newState: PremiumState.notPremium);
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
      // Open PDF document using pdfx
      final doc = await PdfDocument.openFile(pdfFile.path);
      final pages = doc.pagesCount;
      List<imglib.Image> images = [];

      // Get images from all the pages
      for (int i = 1; i <= pages; i++) {
        final page = await doc.getPage(i);
        final pageImage = await page.render(width: page.width, height: page.height);
        final imgBytes = pageImage?.bytes;
        if (imgBytes != null) {
          final libImage = imglib.decodeImage(imgBytes);
          if (libImage != null) {
            images.add(libImage);
          }
        }
        await page.close();
      }

      // Stitch images
      int totalHeight = 0;
      for (var e in images) {
        totalHeight += e.height;
      }
      int totalWidth = 0;
      for (var element in images) {
        totalWidth = totalWidth < element.width ? element.width : totalWidth;
      }

      if (images.isEmpty) {
        return "";
      }

      final mergedImage = imglib.Image(width: totalWidth, height: totalHeight);
      int mergedHeight = 0;
      for (var element in images) {
        imglib.compositeImage(mergedImage, element, dstY: mergedHeight);
        mergedHeight += element.height;
      }

      // Save image as a file
      final documentDirectory = await getTemporaryDirectory();
      File imgFile = File('${documentDirectory.path}/pages.png');
      await imgFile.writeAsBytes(imglib.encodeJpg(mergedImage));
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

    try { // Add this try-catch block
      final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
      final match = regex.firstMatch(response);

      String jsonString;
      if (match != null && match.groupCount > 0) {
        jsonString = match.group(1)!.trim();
      } else {
        jsonString = response.trim();
      }

      Map<String, dynamic> data = jsonDecode(jsonString);

      // ... (the rest of your pdf generation logic)

    } catch (e) {
      print("Error parsing JSON for PDF generation: $e");
      // Optionally, create a PDF with an error message
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text('Failed to generate evaluation matrix due to an error.'),
            );
          },
        ),
      );
    }

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
class SessionManager {
  static const String _sessionTokenKey = 'sessionToken';

  // Call this function right after a successful login or sign-up
  static Future<void> createNewSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    // Generate a unique token for the new session
    final newSessionToken = UniqueKey().toString();

    // Store the new token locally on the device
    await prefs.setString(_sessionTokenKey, newSessionToken);

    // Update the token in Firestore for this user
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'sessionToken': newSessionToken,
    }, SetOptions(merge: true)); // Use merge to avoid overwriting other data
  }

  // Helper to get the locally stored token
  static Future<String?> getLocalSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionTokenKey);
  }

  // Clear local session data on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await FirebaseAuth.instance.signOut();
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
class PDFGenerator {
  static Future<void> generateUPSCQuestionPaper({
    required String subject,
    required String question,
    required int marks,
  }) async {
    final pdf = pw.Document();

    // Using a default font that supports common characters.
    // For full Unicode support, you would bundle a font like NotoSans.
    final font = await PdfGoogleFonts.notoSansRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  subject,
                  style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Time Allowed: Three Hours', style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text('Maximum Marks: 250', style: pw.TextStyle(font: font, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 10), // Used for margin
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10), // Used for margin

              // Instructions
              pw.Text(
                'Question Paper Specific Instructions',
                style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Please read each of the following instructions carefully before attempting the question:',
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
              pw.SizedBox(height: 15),

              // The Question
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('1. ', style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                    child: pw.Text(
                      question,
                      style: pw.TextStyle(font: font, fontSize: 12, height: 1.5), // Correct property is 'height'
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    '[$marks]',
                    style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Generated by CivilsGPT',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Use the printing package to share or save the PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'UPSC_Mains_Question.pdf');
  }
}