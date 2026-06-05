import '../domain/ports/clock.dart';

/// Production [Clock] backed by the host's wall clock.
///
/// Returns [DateTime.now] converted to UTC so callers always get a
/// timezone-free instant.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
