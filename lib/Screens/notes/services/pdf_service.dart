import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/notes_model.dart';

class PdfService extends GetxService {
  Future<void> generatePdf(Note note) async {
    final pdf = pw.Document();
    
    // Add fonts
    final font = await _getFont(note.blocks.first.fontFamily);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                note.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Blocks
              for (var block in note.blocks)
                _buildBlockWidget(block, font),
            ],
          );
        },
      ),
    );
    
    // Preview and print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
  
  pw.Widget _buildBlockWidget(TextBlock block, pw.Font font) {
    double fontSize;
    pw.FontWeight fontWeight;
    pw.TextStyle? style;
    
    switch (block.type) {
      case BlockType.title:
        fontSize = 20;
        fontWeight = pw.FontWeight.bold;
        break;
      case BlockType.subheading:
        fontSize = 16;
        fontWeight = pw.FontWeight.bold;
        break;
      case BlockType.monospace:
        fontSize = 14;
        fontWeight = pw.FontWeight.normal;
        style = pw.TextStyle(
          font: _getMonospaceFont(),
          fontSize: fontSize,
        );
        break;
      case BlockType.body:
      default:
        fontSize = 14;
        fontWeight = pw.FontWeight.normal;
        break;
    }
    
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(
        block.text,
        style: style ?? pw.TextStyle(
          fontSize: fontSize,
          font: font,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
  
  Future<pw.Font> _getFont(FontFamily fontFamily) async {
    switch (fontFamily) {
      case FontFamily.serif:
        return pw.Font.courier();
      case FontFamily.monospace:
        return pw.Font.courier();
      case FontFamily.poppins:
        // You would load custom font here
        return pw.Font.courier();
      case FontFamily.roboto:
        return pw.Font.courier();
      case FontFamily.sansSerif:
      default:
        return pw.Font.helvetica();
    }
  }
  
  pw.Font _getMonospaceFont() {
    return pw.Font.courier();
  }
}