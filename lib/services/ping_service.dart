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
      ProcessResult result;

      if (Platform.isWindows) {
        result = await Process.run('ping', ['-n', '1', '-w', '5000', ip]);
      } else if (Platform.isMacOS) {
        // macOS -W is in milliseconds on newer versions, but seconds on older.
        // Use -t (timeout) 5 seconds for the whole operation.
        result = await Process.run('ping', ['-c', '1', '-t', '5', ip]);
      } else {
        // Linux -W is in seconds
        result = await Process.run('ping', ['-c', '1', '-W', '5', ip]);
      }

      final output = result.stdout.toString();
      final stdout = output.toLowerCase();

      bool isOnline = false;
      if (Platform.isWindows) {
        isOnline = stdout.contains('ttl=');
      } else {
        // ICMP error messages (TTL exceeded, destination unreachable) also
        // contain "bytes from" but are NOT successful replies. Exclude them.
        final hasICMPError = stdout.contains('time to live exceeded') ||
            stdout.contains('ttl exceeded') ||
            stdout.contains('destination unreachable') ||
            stdout.contains('host unreachable') ||
            stdout.contains('network unreachable') ||
            stdout.contains('no route to host');

        // Check for actual reply: "bytes from" WITHOUT ICMP errors,
        // combined with 0% packet loss
        final hasReply = stdout.contains('bytes from') && !hasICMPError;
        final hasZeroLoss = stdout.contains('0% packet loss') || 
            stdout.contains('0.0% packet loss');

        isOnline = hasReply && hasZeroLoss;

        // Fallback: check packet received count (only if no ICMP errors)
        if (!isOnline && !hasICMPError) {
          isOnline = stdout.contains('1 packets received') ||
              stdout.contains('1 received');
        }
      }

      if (isOnline) {
        double? ms;

        // 1. Try to parse from the reply line: "time=XX.X ms"
        final replyRegex = RegExp(r'time[=<](\d+(?:\.\d+)?)\s*ms', caseSensitive: false);
        final replyMatch = replyRegex.firstMatch(output);
        if (replyMatch != null && replyMatch.group(1) != null) {
          ms = double.tryParse(replyMatch.group(1)!);
        }

        // 2. Fallback: parse from round-trip summary line:
        //    "round-trip min/avg/max/stddev = 33.554/33.554/33.554/nan ms"
        if (ms == null) {
          final summaryRegex = RegExp(
            r'round-trip\s+\S+\s*=\s*[\d.]+/([\d.]+)/[\d.]+/',
            caseSensitive: false,
          );
          final summaryMatch = summaryRegex.firstMatch(output);
          if (summaryMatch != null && summaryMatch.group(1) != null) {
            ms = double.tryParse(summaryMatch.group(1)!);
          }
        }

        // 3. Last resort: parse from "rtt min/avg/max/mdev" (Linux format)
        if (ms == null) {
          final rttRegex = RegExp(
            r'rtt\s+\S+\s*=\s*[\d.]+/([\d.]+)/[\d.]+/',
            caseSensitive: false,
          );
          final rttMatch = rttRegex.firstMatch(output);
          if (rttMatch != null && rttMatch.group(1) != null) {
            ms = double.tryParse(rttMatch.group(1)!);
          }
        }

        return PingResult(isOnline: true, pingMs: ms);
      }

      return PingResult(isOnline: false, pingMs: null);
    } catch (e) {
      return PingResult(isOnline: false, pingMs: null);
    }
  }
}
