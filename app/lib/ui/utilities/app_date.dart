import "package:intl/intl.dart";


String dateFormatted(DateTime datetime, {String format = 'yyyy/MM/dd', String locale = 'jp_JP'})  {
  // initializeDateFormatting(locale);

  var formatter = DateFormat(format);
  var formatted = formatter.format(datetime); // DateからString
  return formatted;
}
