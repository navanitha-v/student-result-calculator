// main.dart
// Paste this whole file into DartPad (or lib/main.dart of a Flutter project)
// and press Run. If you edit the code afterwards, use "Run" / hot RESTART
// rather than hot reload, since several widgets below use const constructors.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ResultCalculatorApp());
}

class ResultCalculatorApp extends StatelessWidget {
  const ResultCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Result Calculator',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
      ),
      home: const DualPhoneScreen(),
    );
  }
}

// ---------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------
const Color kPrimary = Color(0xFF6C4CE0);
const Color kPrimaryDark = Color(0xFF5936C9);
const Color kBeigeBg = Color(0xFFF3ECD8);
const Color kAccentRed = Color(0xFFE0325C);
const Color kChassis = Color(0xFF1E1E1E);
const Color kTextDark = Color(0xFF1F2937);
const Color kTextGrey = Color(0xFF8B93A1);
const Color kFieldBorder = Color(0xFFE3E6EE);

const List<Color> kSubjectColors = [
  Color(0xFF8B5CF6), // purple
  Color(0xFF3B82F6), // blue
  Color(0xFF14B8A6), // teal
  Color(0xFFF97316), // orange
  Color(0xFFEC4899), // pink
];

const List<String> kSubjectLabels = [
  'Subject 1',
  'Subject 2',
  'Subject 3',
  'Subject 4',
  'Subject 5',
];

// ---------------------------------------------------------------------
// Root: two phone mockups, side by side, sharing form state
// ---------------------------------------------------------------------
class DualPhoneScreen extends StatefulWidget {
  const DualPhoneScreen({super.key});

  @override
  State<DualPhoneScreen> createState() => _DualPhoneScreenState();
}

class _DualPhoneScreenState extends State<DualPhoneScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController rollCtrl = TextEditingController();
  final List<TextEditingController> markCtrls =
      List.generate(5, (_) => TextEditingController());

  String resultName = 'Student Name';
  String resultRoll = '--';
  List<double> resultMarks = List.filled(5, 0);

  void _calculate() {
    setState(() {
      resultName =
          nameCtrl.text.trim().isEmpty ? 'Student Name' : nameCtrl.text.trim();
      resultRoll = rollCtrl.text.trim().isEmpty ? '--' : rollCtrl.text.trim();
      resultMarks =
          markCtrls.map((c) => double.tryParse(c.text.trim()) ?? 0).toList();
    });
  }

  void _reset() {
    setState(() {
      nameCtrl.clear();
      rollCtrl.clear();
      for (final c in markCtrls) {
        c.clear();
      }
      resultName = 'Student Name';
      resultRoll = '--';
      resultMarks = List.filled(5, 0);
    });
  }

  double get total => resultMarks.fold(0.0, (sum, m) => sum + m);
  double get average => resultMarks.isEmpty ? 0 : total / resultMarks.length;

  String get grade {
    if (average > 90) return 'A+';
    if (average > 80) return 'A';
    if (average > 70) return 'B+';
    if (average > 60) return 'B';
    if (average > 50) return 'C';
    return 'F';
  }

  String get passFail => average > 50 ? 'Pass' : 'Fail';

  @override
  void dispose() {
    nameCtrl.dispose();
    rollCtrl.dispose();
    for (final c in markCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 40,
              runSpacing: 40,
              children: [
                PhoneFrame(
                  child: InputFormScreen(
                    nameCtrl: nameCtrl,
                    rollCtrl: rollCtrl,
                    markCtrls: markCtrls,
                    onCalculate: _calculate,
                  ),
                ),
                PhoneFrame(
                  child: ResultScreen(
                    name: resultName,
                    roll: resultRoll,
                    marks: resultMarks,
                    total: total,
                    average: average,
                    grade: grade,
                    passFail: passFail,
                    onReset: _reset,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// PhoneFrame: rounded chassis + notch + fake status bar
// ---------------------------------------------------------------------
class PhoneFrame extends StatelessWidget {
  final Widget child;
  static const double phoneWidth = 330;
  static const double phoneHeight = 690;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: phoneWidth,
      height: phoneHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kChassis,
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .0.28),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _StatusBar(),
                  Expanded(child: child),
                  // home indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Notch
          Positioned(
            top: 0,
            child: Container(
              width: 130,
              height: 24,
              decoration: const BoxDecoration(
                color: kChassis,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fake iOS-style status bar: time + signal/wifi/battery icons.
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 18, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '9:41',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: kTextDark,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 15, color: kTextDark),
              SizedBox(width: 5),
              Icon(Icons.wifi, size: 15, color: kTextDark),
              SizedBox(width: 5),
              Icon(Icons.battery_full, size: 15, color: kTextDark),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// SCREEN 1: Input form
// ---------------------------------------------------------------------
class InputFormScreen extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController rollCtrl;
  final List<TextEditingController> markCtrls;
  final VoidCallback onCalculate;

  const InputFormScreen({
    super.key,
    required this.nameCtrl,
    required this.rollCtrl,
    required this.markCtrls,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Heading block (top ~25%) ----
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kPrimaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Student Result Calculator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Enter student details and mark details',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ---- Form body ----
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Student Name'),
                const SizedBox(height: 8),
                _IconTextField(
                  icon: Icons.person,
                  iconColor: kSubjectColors[0],
                  hint: 'Enter student name',
                  controller: nameCtrl,
                ),
                const SizedBox(height: 16),

                const _FieldLabel('Roll Number'),
                const SizedBox(height: 8),
                _IconTextField(
                  icon: Icons.badge_outlined,
                  iconColor: kSubjectColors[1],
                  hint: 'Enter roll number',
                  controller: rollCtrl,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Student Marks (Out of 100)',
                      style: TextStyle(
                        color: kAccentRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Icon(Icons.menu_book_rounded, color: kAccentRed, size: 20),
                  ],
                ),
                const SizedBox(height: 12),

                for (int i = 0; i < kSubjectLabels.length; i++) ...[
                  _SubjectMarkRow(
                    label: kSubjectLabels[i],
                    color: kSubjectColors[i],
                    controller: markCtrls[i],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),

        // ---- Calculate button ----
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Material(
            color: kPrimary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onCalculate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Calculate Result',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: kTextDark,
      ),
    );
  }
}

class _IconTextField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String hint;
  final TextEditingController controller;

  const _IconTextField({
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kFieldBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: iconColor.withOpacity(0.14),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: kTextGrey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
              style: const TextStyle(fontSize: 13.5, color: kTextDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectMarkRow extends StatelessWidget {
  final String label;
  final Color color;
  final TextEditingController controller;

  const _SubjectMarkRow({
    required this.label,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: color.withValues(alpha: .0.14),
          child: Icon(Icons.school_outlined, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kFieldBorder),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                hintText: 'Enter marks',
                hintStyle: TextStyle(color: kTextGrey, fontSize: 12.5),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13, color: kTextDark),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// SCREEN 2: Result
// ---------------------------------------------------------------------
class ResultScreen extends StatelessWidget {
  final String name;
  final String roll;
  final List<double> marks;
  final double total;
  final double average;
  final String grade;
  final String passFail;
  final VoidCallback onReset;

  const ResultScreen({
    super.key,
    required this.name,
    required this.roll,
    required this.marks,
    required this.total,
    required this.average,
    required this.grade,
    required this.passFail,
    required this.onReset,
  });

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final bool isPass = passFail == 'Pass';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Top bar with back arrow ----
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 20, 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: const [
              Icon(Icons.arrow_back, color: kTextDark),
              SizedBox(width: 8),
              Text(
                'Result',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Name / roll card ----
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kPrimary.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: kPrimary.withOpacity(0.16),
                        child: const Icon(Icons.school, color: kPrimary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Roll No: $roll',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: kTextGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Table ----
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kFieldBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey.shade200),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1.4),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: kPrimary.withOpacity(0.08)),
                        children: const [
                          _TableHeaderCell('Subject'),
                          _TableHeaderCell('Mark'),
                        ],
                      ),
                      for (int i = 0; i < kSubjectLabels.length; i++)
                        TableRow(
                          children: [
                            _TableCell(kSubjectLabels[i]),
                            _TableCell(_fmt(marks.length > i ? marks[i] : 0)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Stat boxes: 2x2 ----
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        icon: Icons.calculate_outlined,
                        color: kPrimary,
                        label: 'Total',
                        value: _fmt(total),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        icon: Icons.show_chart,
                        color: const Color(0xFF3B82F6),
                        label: 'Average',
                        value: _fmt(average),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xFFF97316),
                        label: 'Grade',
                        value: grade,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatBox(
                        icon: isPass
                            ? Icons.check_circle_outline
                            : Icons.highlight_off,
                        color: isPass ? const Color(0xFF16A34A) : kAccentRed,
                        label: 'Result',
                        value: passFail,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ---- Calculate again ----
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimary, width: 1.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: kPrimary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Calculate Again',
                      style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: kPrimary,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: kTextDark),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatBox({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
