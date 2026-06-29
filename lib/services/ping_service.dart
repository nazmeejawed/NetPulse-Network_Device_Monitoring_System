import 'dart:io';

class PingResult {
  final bool isOnline;
  final double? pingMs;

  PingResult({required this.isOnline, this.pingMs});
}

class PingService {
  static bool isValidIP(String ip) {
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipv4Regex.hasMatch(ip)) return false;
    
    final parts = ip.split('.');
    for (String part in parts) {
      final intValue = int.tryParse(part);
      if (intValue == null || intValue < 0 || intValue > 255) {
        return false;
      }
    }
    return true;
  }

  static Future<PingResult> ping(String ip) async {
    try {
      final stopwatch = Stopwatch()..start();
      ProcessResult result;

      if (Platform.isWindows) {
        result = await Process.run('ping', ['-n', '1', '-w', '2000', ip]);
      } else if (Platform.isMacOS) {
        // macOS -W is in seconds
        result = await Process.run('ping', ['-c', '1', '-W', '2', ip]);
      } else {
        // Linux -W is in seconds
        result = await Process.run('ping', ['-c', '1', '-W', '2', ip]);
      }
      
      stopwatch.stop();
      final stdout = result.stdout.toString().toLowerCase();

      bool isOnline = false;
      if (Platform.isWindows) {
        isOnline = stdout.contains('ttl=');
      } else {
        isOnline = stdout.contains('1 packets received') ||
            stdout.contains('1 received') ||
            stdout.contains('0% packet loss') ||
            stdout.contains('0.0% packet loss');
      }

      if (isOnline) {
        // Try to parse ms
        final regex = RegExp(r'time[=<](\d+(?:\.\d+)?)\s*ms', caseSensitive: false);
        final match = regex.firstMatch(result.stdout.toString());
        double? ms;
        if (match != null && match.group(1) != null) {
          ms = double.tryParse(match.group(1)!);
        }
        // Fallback to stopwatch if regex fails
        ms ??= stopwatch.elapsedMilliseconds.toDouble();
        return PingResult(isOnline: true, pingMs: ms);
      }

      return PingResult(isOnline: false, pingMs: null);
    } catch (e) {
      return PingResult(isOnline: false, pingMs: null);
    }
  }
}
