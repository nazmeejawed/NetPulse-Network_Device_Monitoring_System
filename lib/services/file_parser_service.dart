import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/ip_device.dart';

class ParsedDevice {
  final String ip;
  final String label;

  ParsedDevice({required this.ip, this.label = ''});
}

class FileParserService {
  static Future<List<IPDevice>> parseFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    List<List<dynamic>> rows = [];

    if (path.toLowerCase().endsWith('.csv')) {
      final content = await file.readAsString();
      rows = Csv().decode(content);
    } else if (path.toLowerCase().endsWith('.xlsx') || path.toLowerCase().endsWith('.xls')) {
      final bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        final sheetRows = excel.tables[table]?.rows;
        if (sheetRows != null) {
          for (var row in sheetRows) {
            rows.add(row.map((e) => e?.value).toList());
          }
        }
        break; // Only read first sheet
      }
    } else {
      throw Exception('Unsupported file format');
    }

    if (rows.isEmpty) return [];

    // Find headers
    final headerRow = rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
    
    int ipColIndex = -1;
    int labelColIndex = -1;

    for (int i = 0; i < headerRow.length; i++) {
      final header = headerRow[i];
      if (header.contains('ip') || header.contains('host')) {
        ipColIndex = i;
      } else if (header.contains('name') || header.contains('device') || header.contains('label')) {
        labelColIndex = i;
      }
    }

    if (ipColIndex == -1) {
      // If no header found, assume col 0 is IP
      ipColIndex = 0;
      if (rows.length > 1 && rows[0].length > 1) {
        labelColIndex = 1;
      }
    }

    List<IPDevice> devices = [];
    
    int startIndex = 1;
    if (ipColIndex != -1 && rows.isNotEmpty) {
      final firstCell = rows[0][ipColIndex].toString();
      final isIp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$').hasMatch(firstCell);
      if (isIp) startIndex = 0; // The first row is an IP, no header
    }

    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= ipColIndex) continue;

      final ipRaw = row[ipColIndex]?.toString().trim();
      if (ipRaw == null || ipRaw.isEmpty) continue;

      String label = '';
      if (labelColIndex != -1 && row.length > labelColIndex) {
        label = row[labelColIndex]?.toString().trim() ?? '';
      }

      // Simple cleanup
      final ip = ipRaw.replaceAll(RegExp(r'[^\d.]'), '');
      if (ip.isNotEmpty) {
        devices.add(IPDevice(
          id: '\${DateTime.now().microsecondsSinceEpoch}_$i',
          ip: ip,
          label: label,
        ));
      }
    }

    return devices;
  }
}
