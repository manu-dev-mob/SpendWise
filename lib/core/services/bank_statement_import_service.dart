import 'dart:typed_data';
import 'package:bank_statement_parser/bank_statement_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class BankStatementImportService {
  ///pdf picker
  Future<Uint8List?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null) return null;
    return result.files.single.bytes;
  }

  ///extraction
  Future<String> extractText({
    required Uint8List bytes,
    String password = '',
  }) async {
    final document = PdfDocument(inputBytes: bytes, password: password);
    final extractor = PdfTextExtractor(document);
    final buffer = StringBuffer();
    for (int i = 0; i < document.pages.count; i++) {
      buffer.writeln(extractor.extractText(startPageIndex: i, endPageIndex: i));
    }
    document.dispose();
    return buffer.toString();
  }

  ///parsing the statement
  Future<List<ParsedTransaction>> parseAdcbStatement({
    required Uint8List bytes,
    String password = '',
  }) async {
    final rawText = await extractText(bytes: bytes, password: password);

    print("EXTRACTED TEXT LENGTH: ${rawText.length}");

    var result = AdcbParser().parse(rawText);

    if (result.isNotEmpty) {
      print("Detected Debit Statement");
      return result;
    }

    result = AdcbCrParser().parse(rawText);

    if (result.isNotEmpty) {
      print("Detected Credit Card Statement");
      return result;
    }

    print("No ADCB statement detected");

    return [];
  }

}
