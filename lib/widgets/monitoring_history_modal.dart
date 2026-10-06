import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/monitoring_history_model.dart';
import '../services/monitoring_history_service.dart';
import '../utils/constants.dart';

enum MonitoringMetric {
  waterLevel,
  temperature,
  humidity,
  airQuality,
}

class MonitoringHistoryModal extends StatefulWidget {
  final int initialDayOffset;

  const MonitoringHistoryModal({
    super.key,
    this.initialDayOffset = 0,
  });

  static Future<void> show(BuildContext context, {int initialDayOffset = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MonitoringHistoryModal(initialDayOffset: initialDayOffset),
    );
  }

  @override
  State<MonitoringHistoryModal> createState() => _MonitoringHistoryModalState();
}

class _MonitoringHistoryModalState extends State<MonitoringHistoryModal> {
  late int _selectedDayOffset;
  MonitoringMetric _selectedMetric = MonitoringMetric.waterLevel;
  int? _hoveredIndex;

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static const _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDayOffset = widget.initialDayOffset.clamp(0, 7);
  }

  String _formatDayOption(int dayOffset) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day).subtract(Duration(days: dayOffset));
    final dayName = _dayNames[target.weekday - 1];
    final dateStr = '${target.day.toString().padLeft(2, '0')} ${_shortMonths[target.month - 1]}';

    if (dayOffset == 0) {
      return 'Hari Ini ($dayName, $dateStr)';
    } else if (dayOffset == 1) {
      return 'Kemarin ($dayName, $dateStr)';
    } else {
      return '$dayOffset Hari Lalu ($dayName, $dateStr)';
    }
  }

  String _formatSelectedDayFull(int dayOffset) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day).subtract(Duration(days: dayOffset));
    final dayName = _dayNames[target.weekday - 1];
    final dateStr = '${target.day.toString().padLeft(2, '0')} ${_shortMonths[target.month - 1]} ${target.year}';
    return '$dayName, $dateStr';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    // Ambil 24 titik data pada HARI YANG DIPILIH
    final records = MonitoringHistoryService.instance.getRecordsForDayOffset(_selectedDayOffset);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle Drag bar
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0x3038BDF8) : const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                size: 18,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Riwayat Smart Monitoring',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rekap 24 jam • ${_formatSelectedDayFull(_selectedDayOffset)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Close Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: borderColor),

              // Content Body (Clean & Spacious Layout)
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  children: [
                    // 1. Dropdown Pilihan Hari Tertentu
                    _buildDayDropdownRow(isDark, textPrimary, textSecondary, records.length),

                    const SizedBox(height: 14),

                    // 2. Metric Tabs (Air, Suhu, Kelembaban, Kualitas Udara)
                    _buildMetricSelector(isDark),

                    const SizedBox(height: 16),

                    // 3. Stats Summary (Max, Min, Avg) Hari Itu
                    _buildStatsSummaryCards(records, isDark),

                    const SizedBox(height: 18),

                    // 4. Interactive Chart Card 24 Jam
                    _buildChartCard(records, isDark, textPrimary, textSecondary),

                    const SizedBox(height: 20),

                    // 5. Hourly Table Logs 24 Jam
                    _buildHourlyLogsSection(records, isDark, textPrimary, textSecondary),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // A. DROPDOWN PILIHAN HARI
  // ==========================================
  Widget _buildDayDropdownRow(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    int recordCount,
  ) {
    final dayOptions = List.generate(8, (i) => {
      'offset': i,
      'label': _formatDayOption(i),
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 18,
            color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDayOffset,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                items: dayOptions.map((opt) {
                  return DropdownMenuItem<int>(
                    value: opt['offset'] as int,
                    child: Text(opt['label'] as String),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDayOffset = val;
                      _hoveredIndex = null;
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x3038BDF8) : const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$recordCount Jam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // B. METRIC SELECTOR TABS
  // ==========================================
  Widget _buildMetricSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildMetricChip(
            label: 'Air & Banjir',
            icon: Icons.waves_rounded,
            metric: MonitoringMetric.waterLevel,
            activeColor: const Color(0xFF0284C7),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildMetricChip(
            label: 'Suhu Udara',
            icon: Icons.thermostat_rounded,
            metric: MonitoringMetric.temperature,
            activeColor: const Color(0xFFEA580C),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildMetricChip(
            label: 'Kelembaban',
            icon: Icons.water_drop_rounded,
            metric: MonitoringMetric.humidity,
            activeColor: const Color(0xFF059669),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildMetricChip(
            label: 'Kualitas Udara',
            icon: Icons.air_rounded,
            metric: MonitoringMetric.airQuality,
            activeColor: const Color(0xFF7C3AED),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required IconData icon,
    required MonitoringMetric metric,
    required Color activeColor,
    required bool isDark,
  }) {
    final isSelected = _selectedMetric == metric;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMetric = metric;
          _hoveredIndex = null;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // C. STATS SUMMARY ROW (MAX, MIN, AVG HARI ITU)
  // ==========================================
  Widget _buildStatsSummaryCards(List<MonitoringHistoryRecord> records, bool isDark) {
    if (records.isEmpty) return const SizedBox.shrink();

    final values = records.map((r) => _getMetricValue(r)).toList();
    final maxVal = values.reduce(max);
    final minVal = values.reduce(min);
    final avgVal = values.reduce((a, b) => a + b) / values.length;
    final unit = _getMetricUnit();

    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            title: 'Tertinggi',
            value: '${maxVal.toStringAsFixed(1)} $unit',
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFFEF4444),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStatCard(
            title: 'Terendah',
            value: '${minVal.toStringAsFixed(1)} $unit',
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStatCard(
            title: 'Rata-Rata',
            value: '${avgVal.toStringAsFixed(1)} $unit',
            icon: Icons.show_chart_rounded,
            color: const Color(0xFF0284C7),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // D. INTERACTIVE CHART CARD 24 JAM
  // ==========================================
  Widget _buildChartCard(
    List<MonitoringHistoryRecord> records,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (records.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'Belum ada data untuk hari ini.',
          style: GoogleFonts.plusJakartaSans(color: textSecondary),
        ),
      );
    }

    final accentColor = _getMetricColor();
    final unit = _getMetricUnit();

    // Nilai yang sedang di-hover/tap
    MonitoringHistoryRecord? activeRecord;
    if (_hoveredIndex != null && _hoveredIndex! >= 0 && _hoveredIndex! < records.length) {
      activeRecord = records[_hoveredIndex!];
    } else {
      activeRecord = records.last;
    }

    final activeHour = activeRecord.timestamp.hour.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live point inspection tooltip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pukul $activeHour:00 WIB',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${_getMetricValue(activeRecord).toStringAsFixed(1)} $unit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (activeRecord.isRaining)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x250284C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.water_drop, size: 10, color: Color(0xFF0284C7)),
                              const SizedBox(width: 3),
                              Text(
                                'Hujan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Geser grafik untuk cek jam',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Custom Painted Bezier Chart
          SizedBox(
            height: 160,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (details) => _updateHover(details.localPosition, constraints.maxWidth, records.length),
                  onPanUpdate: (details) => _updateHover(details.localPosition, constraints.maxWidth, records.length),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 160),
                    painter: _MonitoringChartPainter(
                      records: records,
                      metric: _selectedMetric,
                      accentColor: accentColor,
                      isDark: isDark,
                      hoveredIndex: _hoveredIndex ?? (records.length - 1),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Timeline Hours (00:00 - 23:00)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['00:00', '06:00', '12:00', '18:00', '23:00'].map((label) {
              return Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _updateHover(Offset localPos, double width, int count) {
    if (count <= 1 || width <= 0) return;
    final clampedX = localPos.dx.clamp(0.0, width);
    final index = ((clampedX / width) * (count - 1)).round();
    setState(() {
      _hoveredIndex = index.clamp(0, count - 1);
    });
  }

  // ==========================================
  // E. HOURLY LOGS LIST / TABLE (24 JAM HARI ITU)
  // ==========================================
  Widget _buildHourlyLogsSection(
    List<MonitoringHistoryRecord> records,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    // Urutkan dari jam terbaru (23:00 ke 00:00)
    final reversedList = records.reversed.toList();
    final unit = _getMetricUnit();
    final accentColor = _getMetricColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAFTAR LOG DATA PER JAM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: textSecondary,
              ),
            ),
            Text(
              '${records.length} rekaman',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reversedList.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) {
              final rec = reversedList[index];
              final val = _getMetricValue(rec);
              final hourStr = rec.timestamp.hour.toString().padLeft(2, '0');

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          rec.isRaining ? Icons.water_drop_rounded : Icons.access_time_rounded,
                          size: 14,
                          color: rec.isRaining ? const Color(0xFF0284C7) : textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pukul $hourStr:00 WIB',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        if (rec.isRaining) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Hujan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${val.toStringAsFixed(1)} $unit',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(rec, isDark),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(MonitoringHistoryRecord rec, bool isDark) {
    String text;
    Color color;

    switch (_selectedMetric) {
      case MonitoringMetric.waterLevel:
        text = rec.floodStatus;
        color = rec.waterLevelCm >= 35
            ? const Color(0xFFEF4444)
            : (rec.waterLevelCm >= 20 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
        break;
      case MonitoringMetric.airQuality:
        text = rec.airQualityStatus;
        color = rec.mq135Raw > 3000
            ? const Color(0xFFEF4444)
            : (rec.mq135Raw > 1500 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
        break;
      case MonitoringMetric.temperature:
        text = rec.temperatureC > 32 ? 'Panas' : 'Normal';
        color = rec.temperatureC > 32 ? const Color(0xFFEA580C) : const Color(0xFF10B981);
        break;
      case MonitoringMetric.humidity:
        text = rec.humidityPercent > 80 ? 'Lembap' : 'Ideal';
        color = const Color(0xFF0284C7);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  double _getMetricValue(MonitoringHistoryRecord r) {
    switch (_selectedMetric) {
      case MonitoringMetric.waterLevel:
        return r.waterLevelCm;
      case MonitoringMetric.temperature:
        return r.temperatureC;
      case MonitoringMetric.humidity:
        return (r.humidityPercent as num).toDouble();
      case MonitoringMetric.airQuality:
        return r.mq135Raw.toDouble();
    }
  }

  String _getMetricUnit() {
    switch (_selectedMetric) {
      case MonitoringMetric.waterLevel:
        return 'cm';
      case MonitoringMetric.temperature:
        return '°C';
      case MonitoringMetric.humidity:
        return '%';
      case MonitoringMetric.airQuality:
        return 'ADC';
    }
  }

  Color _getMetricColor() {
    switch (_selectedMetric) {
      case MonitoringMetric.waterLevel:
        return const Color(0xFF0284C7);
      case MonitoringMetric.temperature:
        return const Color(0xFFEA580C);
      case MonitoringMetric.humidity:
        return const Color(0xFF059669);
      case MonitoringMetric.airQuality:
        return const Color(0xFF7C3AED);
    }
  }
}

// ==========================================
// CUSTOM PAINTER: SMOOTH BEZIER CHART
// ==========================================
class _MonitoringChartPainter extends CustomPainter {
  final List<MonitoringHistoryRecord> records;
  final MonitoringMetric metric;
  final Color accentColor;
  final bool isDark;
  final int hoveredIndex;

  _MonitoringChartPainter({
    required this.records,
    required this.metric,
    required this.accentColor,
    required this.isDark,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final values = records.map((r) {
      switch (metric) {
        case MonitoringMetric.waterLevel:
          return r.waterLevelCm;
        case MonitoringMetric.temperature:
          return r.temperatureC;
        case MonitoringMetric.humidity:
          return (r.humidityPercent as num).toDouble();
        case MonitoringMetric.airQuality:
          return r.mq135Raw.toDouble();
      }
    }).toList();

    double minVal = values.reduce(min);
    double maxVal = values.reduce(max);
    if ((maxVal - minVal).abs() < 0.001) {
      maxVal += 1.0;
      minVal -= 1.0;
    }

    // Grid lines (3 horizontal lines)
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      final y = size.height * (i / 2.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dx = records.length > 1 ? size.width / (records.length - 1) : 0.0;
    final points = <Offset>[];

    for (int i = 0; i < records.length; i++) {
      final normY = 1.0 - ((values[i] - minVal) / (maxVal - minVal));
      final py = (normY * (size.height - 20)) + 10;
      points.add(Offset(i * dx, py));
    }

    // Gradient fill path
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.35),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Stroke spline path
    final strokePath = Path();
    strokePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      strokePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(strokePath, linePaint);

    // Highlight hovered point & indicator line
    if (hoveredIndex >= 0 && hoveredIndex < points.length) {
      final target = points[hoveredIndex];

      final guidePaint = Paint()
        ..color = accentColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(target.dx, 0), Offset(target.dx, size.height), guidePaint);

      final outerDot = Paint()..color = accentColor;
      final innerDot = Paint()..color = isDark ? const Color(0xFF0F172A) : Colors.white;

      canvas.drawCircle(target, 6, outerDot);
      canvas.drawCircle(target, 3.5, innerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _MonitoringChartPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.metric != metric ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.isDark != isDark;
  }
}
