import 'package:flutter/material.dart';
import 'pdf_import_screen.dart';

/// A small icon‑button that launches the PDF‑import flow.
class PdfImportButton extends StatelessWidget {
  const PdfImportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Import transactions from PDF',
      icon: const Icon(Icons.upload_file_rounded),
      onPressed: () {
        // Push the full‑screen import page.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PdfImportScreen()),
        );
      },
    );
  }
}