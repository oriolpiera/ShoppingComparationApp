/// Port for the current wall-clock time, exposed to the Application layer so
/// that time-sensitive logic (filenames, timestamps) can be tested with a
/// fixed clock.
abstract class Clock {
  /// Returns the current instant in UTC.
  DateTime nowUtc();
}
