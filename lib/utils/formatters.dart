import 'package:intl/intl.dart';

final NumberFormat compactNumber = NumberFormat.compact(locale: 'en_US');
final NumberFormat decimalNumber = NumberFormat.decimalPattern('en_US');

String formatCount(num value) => decimalNumber.format(value.round());

String formatCompactCount(num value) => compactNumber.format(value);

String shortText(String text, {int maxLength = 120}) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength).trimRight()}...';
}
