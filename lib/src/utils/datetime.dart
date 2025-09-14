


class DateTimeUtils {
 static String getDrivingTimeFromMillis(int? duration) {
  int milliseconds = duration ?? 0;
  int seconds = milliseconds ~/ 1000;
  int minutes = seconds ~/ 60;
  int hours = minutes ~/ 60;

  seconds = seconds % 60; // Remaining seconds
  minutes = minutes % 60; // Remaining minutes

  return '${hours.toString().padLeft(2, '0')}h '
      '${minutes.toString().padLeft(2, '0')}m '
      '${seconds.toString().padLeft(2, '0')}s';
}

}
