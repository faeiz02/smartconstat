import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/constat_model.dart';
import '../../utils/date_formatter.dart';

class PdfService {
  static Future<void> generateAccidentReport(
      ConstatModel constat, Uint8List? croquisBytes) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 20),
              _buildGeneralInfo(constat),
              pw.SizedBox(height: 15),
              _buildVehicleColumns(constat),
              pw.SizedBox(height: 15),
              _buildCroquisSection(croquisBytes),
              pw.SizedBox(height: 15),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ftusa',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal)),
            pw.Text('fédération tunisienne des sociétés d\'assurances',
                style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
        pw.Text('constat amiable d\'accident automobile',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildGeneralInfo(ConstatModel constat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
      child: pw.Row(
        children: [
          _infoField('1. date',
              DateFormatter.formatDate(constat.dateTime ?? DateTime.now())),
          _infoField('2. lieu', constat.lieu ?? 'N/A'),
          _infoField('3. blessés', constat.blesses == true ? 'OUI' : 'NON'),
        ],
      ),
    );
  }

  static pw.Widget _buildVehicleColumns(ConstatModel constat) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _vehicleColumn('VÉHICULE A', PdfColors.yellow200, constat, true),
        pw.SizedBox(width: 10),
        _circumstancesColumn(constat),
        pw.SizedBox(width: 10),
        _vehicleColumn('VÉHICULE B', PdfColors.green200, constat, false),
      ],
    );
  }

  static pw.Widget _vehicleColumn(
      String title, PdfColor bgColor, ConstatModel constat, bool isA) {
    final nom = isA ? constat.nomA : constat.nomB;
    final prenom = isA ? constat.prenomA : constat.prenomB;
    final assureur = isA ? constat.assureurA : constat.assureurB;
    final immat = isA ? constat.immatriculationA : constat.immatriculationB;

    return pw.Expanded(
      flex: 2,
      child: pw.Container(
        color: bgColor,
        padding: const pw.EdgeInsets.all(8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              color: PdfColors.black,
              child: pw.Text(title,
                  style: pw.TextStyle(
                      color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            _subHeader('6. Société d\'Assurance'),
            pw.Text(assureur ?? 'N/A', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            _subHeader('7. Identité du Conducteur'),
            pw.Text('${nom ?? ""} ${prenom ?? ""}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            _subHeader('9. Identité du Véhicule'),
            pw.Text(immat ?? 'N/A', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _circumstancesColumn(ConstatModel constat) {
    return pw.Expanded(
      flex: 1,
      child: pw.Column(
        children: [
          pw.Text('12. circonstances',
              style: const pw.TextStyle(
                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          ...List.generate(
              17,
              (index) => pw.Container(
                    height: 12,
                    width: 12,
                    margin: const pw.EdgeInsets.symmetric(vertical: 2),
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey)),
                    child: pw.Center(
                        child: pw.Text('${index + 1}',
                            style: const pw.TextStyle(fontSize: 6))),
                  )),
        ],
      ),
    );
  }

  static pw.Widget _buildCroquisSection(Uint8List? croquisBytes) {
    return pw.Container(
      height: 180,
      width: double.infinity,
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
      child: pw.Stack(
        children: [
          pw.Positioned.fill(
            child: pw.GridView(
              crossAxisCount: 20,
              children: List.generate(
                  200,
                  (index) => pw.Container(
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.grey100, width: 0.5)))),
            ),
          ),
          if (croquisBytes != null)
            pw.Center(child: pw.Image(pw.MemoryImage(croquisBytes))),
          pw.Positioned(
              left: 10,
              top: 10,
              child: pw.Text('13. croquis de l\'accident',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10))),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _signatureBlock('Signature conducteur A'),
        _signatureBlock('Signature conducteur B'),
      ],
    );
  }

  // Utilities
  static pw.Widget _infoField(String label, String value) {
    return pw.Expanded(
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
          pw.Text(label,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ]));
  }

  static pw.Widget _subHeader(String text) {
    return pw.Text(text,
        style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline));
  }

  static pw.Widget _signatureBlock(String label) {
    return pw.Container(
      height: 60,
      width: 150,
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
    );
  }
}
