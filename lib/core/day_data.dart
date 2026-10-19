import 'dart:math' as math;

/// Deterministic fake history so tapping another day in the week strip
/// always shows the same "past log" for that date.
class DaySnapshot {
  const DaySnapshot({
    required this.hr,
    required this.hrSeries,
    required this.sys,
    required this.dia,
    required this.glucose,
    required this.sleepMin,
    required this.deepMin,
    required this.sleepScore,
    required this.water,
    required this.medDone,
    required this.glucoseDone,
    required this.eveningDone,
  });

  final int hr;
  final List<int> hrSeries;
  final int sys;
  final int dia;
  final int glucose;
  final int sleepMin;
  final int deepMin;
  final int sleepScore;
  final double water;
  final bool medDone;
  final bool glucoseDone;
  final bool eveningDone;
}

DaySnapshot snapshotFor(DateTime d) {
  final r = math.Random(d.year * 10000 + d.month * 100 + d.day);
  final hr = 64 + r.nextInt(12);
  final sleep = 390 + r.nextInt(100);
  return DaySnapshot(
    hr: hr,
    hrSeries: List.generate(7, (_) => 62 + r.nextInt(16))..[6] = hr,
    sys: 112 + r.nextInt(14),
    dia: 70 + r.nextInt(10),
    glucose: 84 + r.nextInt(20),
    sleepMin: sleep,
    deepMin: 90 + r.nextInt(60),
    sleepScore: 78 + r.nextInt(20),
    water: 1.0 + r.nextInt(7) * 0.25,
    medDone: r.nextDouble() < 0.85,
    glucoseDone: r.nextDouble() < 0.85,
    eveningDone: r.nextDouble() < 0.8,
  );
}

String fmtMinutes(int m) => '${m ~/ 60}h ${m % 60}m';
