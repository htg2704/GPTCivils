class DocModel {
  final int id;
  final String pdfName;
  final String fileName;
  final String filePath;
  final String result;
  final String date;

  DocModel(
      {required this.id,
        required this.pdfName,
      required this.fileName,
      required this.filePath,
      required this.result,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pdfName': pdfName,
      'fileName': fileName,
      'filePath': filePath,
      'result': result,
      'date': date
    };
  }
}
