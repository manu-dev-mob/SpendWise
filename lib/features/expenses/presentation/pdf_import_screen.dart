import 'package:expense_web/core/services/bank_statement_import_service.dart';
import 'package:expense_web/features/expenses/presentation/pdf_import_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
class PdfImportScreen extends StatefulWidget {
  const PdfImportScreen({super.key});

  @override
  State<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends State<PdfImportScreen> {
  final BankStatementImportService _service = BankStatementImportService();
  Uint8List? _pdfBytes;
  String? _fileName;
  String _password='';
  bool _loading = false;
  String? _error;
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true
    );
    if(result == null) return;
    final file = result.files.single;
    setState(() {
      _pdfBytes = file.bytes;
      _fileName = file.name;
      _error = null;
    });
  }
  Future<void> _parsePdf() async{
    if(_pdfBytes == null){
      setState(() {
        _error = 'please select a PDF first';
      });
      return;
    }
    try{
      final transactions = await _service.parseAdcbStatement(bytes: _pdfBytes!, password: _password);
      print('*********** ${transactions.length}****************');

      if(!mounted) return;
      Navigator.push(context,MaterialPageRoute(builder: (_)=> PdfImportPreviewScreen(transactions: transactions)));
    }
    catch(e){
      setState(() {
        _error = e.toString();
      });
    }
    finally{
      setState(() {
        _loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Import Bank Statement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(icon: const Icon(Icons.upload_file),onPressed: _pickPdf, label: const Text('Select PDF')),
            const SizedBox(height: 20,),
            if(_fileName != null) Text('Selected: $_fileName'),
            const SizedBox(height: 20,),
            TextField(obscureText: true,decoration: const InputDecoration(
              labelText: 'PDF Password (if required)',
            ),
            onChanged: (value){
              _password = value;
            },),
            const SizedBox(height:20),
            if(_error != null) Text(_error!, style: const TextStyle(color: Colors.red,)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading? null : _parsePdf,
              child: _loading? const CircularProgressIndicator(): const Text('Parse Statement'),
            ),
          ],
        ),
      ),
    );
  }
}
