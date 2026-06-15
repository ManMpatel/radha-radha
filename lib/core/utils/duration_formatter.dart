class DurationFormatter {
  DurationFormatter._();

  static String format(int totalSeconds) {
    if (totalSeconds <= 0) return '0 sec';
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0) parts.add('${s}s');
    return parts.join(' ');
  }

  static String formatLong(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('$h hour${h > 1 ? 's' : ''}');
    if (m > 0) parts.add('$m minute${m > 1 ? 's' : ''}');
    if (s > 0) parts.add('$s second${s > 1 ? 's' : ''}');
    if (parts.isEmpty) return '0 seconds';
    return parts.join(', ');
  }

  static String formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatPlayback(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
