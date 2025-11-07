/// Number Formatter Utility
/// Provides formatting for numbers like followers, views, etc.
class FNumberFormatter {
  /// Format follower count to K, M format
  /// Examples: 1200 -> 1.2K, 1500000 -> 1.5M
  static String formatFollowers(int count) {
    if (count >= 1000000) {
      final millions = count / 1000000;
      return '${millions.toStringAsFixed(millions >= 10 ? 0 : 1)}M followers';
    } else if (count >= 1000) {
      final thousands = count / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}K followers';
    }
    return '$count followers';
  }

  /// Format number to compact format (K, M, B)
  /// Examples: 1200 -> 1.2K, 1500000 -> 1.5M
  static String formatCompact(int count) {
    if (count >= 1000000000) {
      final billions = count / 1000000000;
      return '${billions.toStringAsFixed(billions >= 10 ? 0 : 1)}B';
    } else if (count >= 1000000) {
      final millions = count / 1000000;
      return '${millions.toStringAsFixed(millions >= 10 ? 0 : 1)}M';
    } else if (count >= 1000) {
      final thousands = count / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}K';
    }
    return count.toString();
  }

  /// Format duration from milliseconds to readable format
  /// Examples: 180000 -> 3:00, 3600000 -> 1:00:00
  static String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return formatDurationFromDuration(duration);
  }

  /// Format duration from Duration object to readable format
  /// Examples: Duration(minutes: 3) -> 3:00, Duration(hours: 1) -> 1:00:00
  static String formatDurationFromDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

