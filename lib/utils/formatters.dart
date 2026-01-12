import 'package:intl/intl.dart';

String formatIdr(int value) {
  final format = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return format.format(value);
}
