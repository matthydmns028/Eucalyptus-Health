import 'package:flutter/material.dart';

class Patient {
  const Patient({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.patientId,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String patientId;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}

enum TaskKind { medication, glucose, habit, hydration }

class RoutineTask {
  RoutineTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.tag,
    this.kind = TaskKind.habit,
    this.done = false,
    this.dose,
    this.at,
  });

  final String id;
  final String title;
  String subtitle;
  String? tag;
  final IconData icon;
  final TaskKind kind;
  bool done;

  /// Medication label, e.g. "Lisinopril 10mg". Used to rebuild the subtitle.
  final String? dose;

  /// Scheduled / reminder time.
  TimeOfDay? at;
}

enum VitalType { heartRate, bloodPressure, spo2, glucose }

class VitalEntry {
  const VitalEntry(this.type, this.a, [this.b]);
  final VitalType type;
  final int a;
  final int? b;
}

class GlucoseEntry {
  const GlucoseEntry(this.value, this.context);
  final int value;
  final String context;
}

class NoteEntry {
  const NoteEntry(this.text, this.pain, this.time);
  final String text;
  final int pain;
  final DateTime time;
}

class NewRoutine {
  const NewRoutine({required this.medication, required this.name, this.time});
  final bool medication;
  final String name;
  final TimeOfDay? time;
}

class SummaryRow {
  const SummaryRow(this.label, this.value, this.range, this.ok);
  final String label;
  final String value;
  final String range;
  final bool ok;
}
