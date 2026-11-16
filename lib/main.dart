import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const IoTApp());

// ---------------- WARNA ----------------
const Color kBg = Color(0xFF0B1220);
const Color kCard = Color(0xFF151E32);
const Color kOrange = Color(0xFFFF8A4C);
const Color kCyan = Color(0xFF22D3EE);
const Color kGreen = Color(0xFF34D399);
const Color kRed = Color(0xFFF87171);
const Color kMuted = Color(0xFF8A97B1);

class IoTApp extends StatelessWidget {
  const IoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorSchemeSeed: kCyan,
      ),
      home: const DashboardPage(),
    );
  }
}

// ---------------- DATA DUMMY ----------------
class SensorData {
  final String time;
  final double temperature;
  const SensorData(this.time, this.temperature);
}

const List<SensorData> dummyHistory = [
  SensorData('10:00', 28.0),
  SensorData('10:05', 29.0),
  SensorData('10:10', 28.5),
  SensorData('10:15', 30.5),
];

const double dummyTemperature = 30.5;
const int dummyHumidity = 75;
const String dummyBroker = 'broker.hivemq.com';
const String dummyTopic = 'kampus/iot/kelas1/sensor';
const String dummyLastUpdate = '10:15:30';

// ---------------- HALAMAN DASHBOARD ----------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Tap pada status untuk simulasi Connected / Disconnected
  bool isConnected = true;

  @override
  Widget build(BuildContext context) {
    final header = HeaderSection(
      isConnected: isConnected,
      onToggle: () => setState(() => isConnected = !isConnected),
    );
    const temp = GaugeCard(
      icon: Icons.thermostat,
      label: 'Suhu',
      valueText: '$dummyTemperature°C',
      sensor: 'Sensor DHT11',
      progress: dummyTemperature / 50,
      color: kOrange,
    );
    const hum = GaugeCard(
      icon: Icons.water_drop_outlined,
      label: 'Kelembapan',
      valueText: '$dummyHumidity%',
      sensor: 'Sensor DHT11',
      progress: dummyHumidity / 100,
      color: kCyan,
    );
    final mqtt = MqttInfoCard(isConnected: isConnected);
    const chart = ChartCard();
    const history = HistoryList();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1100 : 380),
                  child: isWide
                      ? Column(
                          children: [
                            header,
                            const SizedBox(height: 16),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Expanded(flex: 2, child: temp),
                                  const SizedBox(width: 14),
                                  const Expanded(flex: 2, child: hum),
                                  const SizedBox(width: 14),
                                  Expanded(flex: 3, child: mqtt),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 3, child: chart),
                                  SizedBox(width: 14),
                                  Expanded(flex: 2, child: history),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                Expanded(child: temp),
                                SizedBox(width: 14),
                                Expanded(child: hum),
                              ],
                            ),
                            const SizedBox(height: 14),
                            mqtt,
                            const SizedBox(height: 14),
                            chart,
                            const SizedBox(height: 14),
                            history,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- HEADER + STATUS MQTT ----------------
class HeaderSection extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onToggle;
  const HeaderSection(
      {super.key, required this.isConnected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? kGreen : kRed;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0E7490)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'IoT Monitor',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: color, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_tethering, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Dashboard Monitoring Sensor',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Diperbarui pukul $dummyLastUpdate',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- GAUGE (SUHU & KELEMBAPAN) ----------------
class GaugeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueText;
  final String sensor;
  final double progress;
  final Color color;

  const GaugeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.valueText,
    required this.sensor,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: GaugePainter(progress: progress, color: color),
              child: Center(
                child: Text(
                  valueText,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: color),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(sensor, style: const TextStyle(color: kMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant GaugePainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------- INFO MQTT ----------------
class MqttInfoCard extends StatelessWidget {
  final bool isConnected;
  const MqttInfoCard({super.key, required this.isConnected});

  Widget _item(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: kCyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: kMuted, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MQTT Connection',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          _item(Icons.power_settings_new, 'Status',
              isConnected ? 'Connected' : 'Disconnected'),
          _item(Icons.dns_outlined, 'Broker', dummyBroker),
          _item(Icons.tag, 'Topic', dummyTopic),
          _item(Icons.update, 'Last Update', dummyLastUpdate),
        ],
      ),
    );
  }
}

// ---------------- GRAFIK MONITORING ----------------
class ChartCard extends StatelessWidget {
  const ChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grafik Suhu (°C)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Dummy Data',
                    style: TextStyle(
                        color: kOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(painter: AreaChartPainter(dummyHistory)),
          ),
        ],
      ),
    );
  }
}

class AreaChartPainter extends CustomPainter {
  final List<SensorData> data;
  AreaChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0, bottom = 24.0, top = 10.0, right = 10.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;

    final temps = data.map((e) => e.temperature).toList();
    final minV = temps.reduce(math.min) - 1;
    final maxV = temps.reduce(math.max) + 1;

    // garis bantu horizontal
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = top + h * i / 3;
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      final value = maxV - (maxV - minV) * i / 3;
      _text(canvas, value.toStringAsFixed(0), Offset(4, y - 6));
    }

    final pts = <Offset>[
      for (var i = 0; i < data.length; i++)
        Offset(
          left + w * i / (data.length - 1),
          top + h - ((temps[i] - minV) / (maxV - minV)) * h,
        ),
    ];

    // garis halus
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final cx = (pts[i].dx + pts[i + 1].dx) / 2;
      line.cubicTo(cx, pts[i].dy, cx, pts[i + 1].dy, pts[i + 1].dx,
          pts[i + 1].dy);
    }

    // area gradasi di bawah garis
    final area = Path.from(line)
      ..lineTo(pts.last.dx, top + h)
      ..lineTo(pts.first.dx, top + h)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kOrange.withValues(alpha: 0.35),
          kOrange.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(left, top, w, h));
    canvas.drawPath(area, areaPaint);

    canvas.drawPath(
      line,
      Paint()
        ..color = kOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 6, Paint()..color = kCard);
      canvas.drawCircle(pts[i], 4, Paint()..color = kOrange);
      _text(canvas, data[i].time, Offset(pts[i].dx - 14, top + h + 8));
    }
  }

  void _text(Canvas canvas, String s, Offset o) {
    final tp = TextPainter(
      text: TextSpan(
          text: s, style: const TextStyle(color: kMuted, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, o);
  }

  @override
  bool shouldRepaint(covariant AreaChartPainter old) => old.data != data;
}

// ---------------- RIWAYAT DATA ----------------
class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = dummyHistory.reversed.toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riwayat Pembacaan',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: i == 0 ? 0.09 : 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: kMuted),
                      const SizedBox(width: 8),
                      Text(items[i].time,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(
                    '${items[i].temperature}°C',
                    style: const TextStyle(
                        color: kOrange, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}