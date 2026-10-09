/// Indonesian date/time formatting helpers.
///
/// Deliberately dependency-free: the design only needs a handful of labels and
/// bundling `intl` would risk version conflicts with the Flutter SDK.
abstract final class Formatters {
  Formatters._();

  static const List<String> _weekdaysShort = <String>[
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _weekdaysLong = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _months = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Monday = 0 … Sunday = 6 (matches the weekly strip in the mocks).
  static int mondayIndex(DateTime date) => (date.weekday - 1) % 7;

  static String weekdayShort(DateTime date) =>
      _weekdaysShort[mondayIndex(date)];

  static String weekdayLong(DateTime date) => _weekdaysLong[mondayIndex(date)];

  /// "November 2024"
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// "Sen, 14 Nov"
  static String dayMonth(DateTime date) =>
      '${_weekdaysShort[mondayIndex(date)]}, ${date.day} ${_months[date.month - 1].substring(0, 3)}';

  /// Removes the time-of-day component so date equality comparisons work.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// "Hari Ini" / "Besok" / "Kemarin" / "Sen, 14 Nov"
  static String relativeDay(DateTime date, {DateTime? now}) {
    final DateTime today = dateOnly(now ?? DateTime.now());
    final DateTime target = dateOnly(date);
    final int diff = target.difference(today).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    return dayMonth(date);
  }

  /// "10:00 WIB" — [hhmm] is a 24h `HH:mm` string.
  static String time(String hhmm) {
    final DateTime? parsed = DateTime.tryParse('2000-01-01 $hhmm:00');
    if (parsed == null) return hhmm;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(parsed.hour)}:${two(parsed.minute)} WIB';
  }

  /// "45m" / "1j 30m"
  static String estimate(int minutes) {
    if (minutes < 60) return 'Estimasi ${minutes}m';
    final int hours = minutes ~/ 60;
    final int rest = minutes % 60;
    return rest == 0 ? 'Estimasi ${hours}j' : 'Estimasi ${hours}j ${rest}m';
  }

  /// Time-of-day greeting used in the home headline.
  static String greeting(DateTime time) {
    final int hour = time.hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}