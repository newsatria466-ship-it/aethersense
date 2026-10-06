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
  final int initialDays;

  const MonitoringHistoryModal({
    super.key,
    this.initialDays = 7,
  });

  static Future<void> show(BuildContext context, {int initialDays = 7}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MonitoringHistoryModal(initialDays: initialDays),
    );
  }

  @override
  State<MonitoringHistoryModal> createState() => _MonitoringHistoryModalState();
}

class _DailyRecordGroup {
  final DateTime date;
  final String dateKey; // 'YYYY-MM-DD'
  final String dayName; // 'Selasa'
  final String dateFormatted; // '06 Okt 2026'
  final String relativeLabel; // 'Hari Ini', 'Kemarin', '2 Hari Lalu'
  final List<MonitoringHistoryRecord> records;

  _DailyRecordGroup({
    required this.date,
    required this.dateKey,
    required this.dayName,
    required this.dateFormatted,
    required this.relativeLabel,
    required this.records,
  });
}

class _MonitoringHistoryModalState extends State<MonitoringHistoryModal> {
  late int _selectedDays;
  MonitoringMetric _selectedMetric = MonitoringMetric.waterLevel;
  int? _hoveredIndex;
  final Set<String> _expandedDayKeys = {};

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static const _indonesianDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialDays;
  }

  String _formatRangeOptionLabel(int days) {
    final now = DateTime.now();
    final endStr = '${now.day.toString().padLeft(2, '0')} ${_shortMonths[now.month - 1]}';
    if (days == 1) {
      return 'Hari Ini ($endStr • 24 Jam)';
    }
    final start = now.subtract(Duration(days: days - 1));
    final startStr = '${start.day.toString().padLeft(2, '0')} ${_shortMonths[start.month - 1]}';
    return '$days Hari Terakhir ($startStr – $endStr)';
  }

  String _formatFullDateRange(int days) {
    final now = DateTime.now();
    final endStr = '${now.day.toString().padLeft(2, '0')} ${_shortMonths[now.month - 1]} ${now.year}';
    if (days == 1) {
      return '$endStr (Hari Ini • 24 Jam)';
    }
    final start = now.subtract(Duration(days: days - 1));
    final startStr = '${start.day.toString().padLeft(2, '0')} ${_shortMonths[start.month - 1]} ${start.year}';
    return '$startStr – $endStr ($days Hari)';
  }

  List<_DailyRecordGroup> _groupRecordsByDay(List<MonitoringHistoryRecord> records) {
    final Map<String, List<MonitoringHistoryRecord>> groupedMap = {};
    for (final r in records) {
      final k = '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2, '0')}-${r.timestamp.day.toString().padLeft(2, '0')}';
      groupedMap.putIfAbsent(k, () => []).add(r);
    }

    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    final groups = groupedMap.entries.map((entry) {
      final dayRecs = List<MonitoringHistoryRecord>.from(entry.value);
      // Urutkan dari jam terbaru ke terlama untuk tampilan detail per jam
      dayRecs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final dt = dayRecs.first.timestamp;
      final k = entry.key;

      String rel;
      if (k == todayKey) {
        rel = 'Hari Ini';
      } else if (k == yesterdayKey) {
        rel = 'Kemarin';
      } else {
        final diffDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(dt.year, dt.month, dt.day))
            .inDays;
        rel = diffDays > 0 ? '$diffDays Hari Lalu' : 'Hari Ini';
      }

      final dayName = _indonesianDays[dt.weekday - 1];
      final dateFormatted = '${dt.day.toString().padLeft(2, '0')} ${_shortMonths[dt.month - 1]} ${dt.year}';

      return _DailyRecordGroup(
        date: dt,
        dateKey: k,
        dayName: dayName,
        dateFormatted: dateFormatted,
        relativeLabel: rel,
        records: dayRecs,
      );
    }).toList();

    // Urutkan groups dari hari terbaru ke hari terdahulu
    groups.sort((a, b) => b.date.compareTo(a.date));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final records = MonitoringHistoryService.instance.getRecordsForDays(_selectedDays);
    final dailyGroups = _groupRecordsByDay(records);

    // Buka hari pertama (hari terbaru) secara otomatis jika belum ada yang terbuka
    if (_expandedDayKeys.isEmpty && dailyGroups.isNotEmpty) {
      _expandedDayKeys.add(dailyGroups.first.dateKey);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.96,
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
                          'Rekap per hari • Log tiap jam • Max 7 Hari',
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

              // Content Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  children: [
                    // 1. Dropdown Rentang Hari & Badge Tanggal Dinamis
                    _buildRangeDropdownRow(isDark, textPrimary, textSecondary, records.length),

                    const SizedBox(height: 14),

                    // 2. Metric Tabs (Air, Suhu, Kelembaban, Udara)
                    _buildMetricSelector(isDark),

                    const SizedBox(height: 16),

                    // 3. Stats Summary (Max, Min, Avg) Keseluruhan Rentang
                    _buildStatsSummaryCards(records, isDark),

                    const SizedBox(height: 18),

                    // 4. Interactive Chart Card dengan Penanda Tanggal X-Axis
                    _buildChartCard(records, isDark, textPrimary, textSecondary),

                    const SizedBox(height: 22),

                    // 5. Tampilan Rekap Data Per Hari (Grouped Day-by-Day)
                    _buildDailyGroupedSection(dailyGroups, isDark, textPrimary, textSecondary),
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
  // A. DROPDOWN RENTANG HARI & BADGE TANGGAL
  // ==========================================
  Widget _buildRangeDropdownRow(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    int recordCount,
  ) {
    final rangeOptions = [
      {'days': 7, 'label': _formatRangeOptionLabel(7)},
      {'days': 6, 'label': _formatRangeOptionLabel(6)},
      {'days': 5, 'label': _formatRangeOptionLabel(5)},
      {'days': 4, 'label': _formatRangeOptionLabel(4)},
      {'days': 3, 'label': _formatRangeOptionLabel(3)},
      {'days': 2, 'label': _formatRangeOptionLabel(2)},
      {'days': 1, 'label': _formatRangeOptionLabel(1)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                Icons.date_range_rounded,
                size: 18,
                color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedDays,
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
                    items: rangeOptions.map((opt) {
                      return DropdownMenuItem<int>(
                        value: opt['days'] as int,
                        child: Text(opt['label'] as String),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDays = val;
                          _hoveredIndex = null;
                          _expandedDayKeys.clear();
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
                  '$_selectedDays Hari',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Date Range Subtitle Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1F38BDF8) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0x3538BDF8) : const Color(0xFFBFDBFE),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 14,
                color: isDark ? AetherConstants.cyanAccent : const Color(0xFF0284C7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Rentang Kalender: ${_formatFullDateRange(_selectedDays)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$recordCount Jam Total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
  // C. STATS SUMMARY ROW (MAX, MIN, AVG)
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
  // D. INTERACTIVE CHART CARD DENGAN DAY MARKERS
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
          'Belum ada data untuk rentang ini.',
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
                    _formatDateTime(activeRecord.timestamp),
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

          const SizedBox(height: 10),

          // X-Axis Day Markers
          _buildChartDayMarkers(records, isDark, textSecondary),
        ],
      ),
    );
  }

  Widget _buildChartDayMarkers(List<MonitoringHistoryRecord> records, bool isDark, Color textSecondary) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Dapatkan tanggal unik secara kronologis
    final seen = <String>{};
    final distinctDays = <DateTime>[];
    for (final r in records) {
      final k = '${r.timestamp.year}-${r.timestamp.month}-${r.timestamp.day}';
      if (seen.add(k)) {
        distinctDays.add(r.timestamp);
      }
    }

    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: distinctDays.map((dt) {
          final isToday = '${dt.year}-${dt.month}-${dt.day}' == todayKey;
          final label = isToday
              ? 'Hari Ini'
              : '${dt.day.toString().padLeft(2, '0')} ${_shortMonths[dt.month - 1]}';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: isToday
                ? BoxDecoration(
                    color: (isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday
                    ? (isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue)
                    : textSecondary,
              ),
            ),
          );
        }).toList(),
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
  // E. TAMPILAN REKAP DATA PER HARI (DAY-BY-DAY)
  // ==========================================
  Widget _buildDailyGroupedSection(
    List<_DailyRecordGroup> groups,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    final accentColor = _getMetricColor();
    final unit = _getMetricUnit();
    final allExpanded = _expandedDayKeys.length >= groups.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Buka/Tutup Semua Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_day_rounded, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  'REKAP DATA PER HARI (${groups.length} HARI)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  if (allExpanded) {
                    _expandedDayKeys.clear();
                  } else {
                    _expandedDayKeys.addAll(groups.map((g) => g.dateKey));
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  allExpanded ? 'Tutup Semua' : 'Buka Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // List Kartu Per Hari
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = groups[index];
            final isExpanded = _expandedDayKeys.contains(group.dateKey);

            // Perhitungan statistik harian untuk metrik yang aktif
            final vals = group.records.map((r) => _getMetricValue(r)).toList();
            final avgVal = vals.isNotEmpty ? vals.reduce((a, b) => a + b) / vals.length : 0.0;
            final maxVal = vals.isNotEmpty ? vals.reduce(max) : 0.0;
            final minVal = vals.isNotEmpty ? vals.reduce(min) : 0.0;
            final hasRain = group.records.any((r) => r.isRaining);

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isExpanded
                      ? accentColor.withValues(alpha: 0.5)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isExpanded ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Hari (Bisa Di-tap)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedDayKeys.remove(group.dateKey);
                        } else {
                          _expandedDayKeys.add(group.dateKey);
                        }
                      });
                    },
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(16),
                      bottom: Radius.circular(isExpanded ? 0 : 16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: group.relativeLabel == 'Hari Ini'
                                          ? (isDark ? const Color(0x3038BDF8) : const Color(0xFFE0F2FE))
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      group.relativeLabel == 'Hari Ini'
                                          ? Icons.today_rounded
                                          : Icons.event_note_rounded,
                                      size: 16,
                                      color: group.relativeLabel == 'Hari Ini'
                                          ? (isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue)
                                          : textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${group.dayName}, ${group.dateFormatted}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: group.relativeLabel == 'Hari Ini'
                                                  ? const Color(0xFF0284C7).withValues(alpha: 0.15)
                                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              group.relativeLabel,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                color: group.relativeLabel == 'Hari Ini'
                                                    ? const Color(0xFF0284C7)
                                                    : textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '• ${group.records.length} Jam data',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Avg: ${avgVal.toStringAsFixed(1)} $unit',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Daily Highlights Badges (Min, Max, Avg, Cuaca)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildDailyBadge(
                                  label: 'Min: ${minVal.toStringAsFixed(1)} $unit',
                                  color: const Color(0xFF10B981),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                                _buildDailyBadge(
                                  label: 'Max: ${maxVal.toStringAsFixed(1)} $unit',
                                  color: const Color(0xFFEF4444),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                                _buildDailyBadge(
                                  label: hasRain ? '🌧 Sempat Hujan' : '☀️ Cerah',
                                  color: hasRain ? const Color(0xFF0284C7) : const Color(0xFFF59E0B),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 6),
                                _buildDailyStatusBadge(maxVal, avgVal, isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Detail 24 Log Jam untuk hari ini (Saat di-expand)
                  if (isExpanded) ...[
                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    ),
                    Container(
                      color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LOG WAKTU',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            'KONDISI & NILAI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: group.records.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, rIndex) {
                        final rec = group.records[rIndex];
                        final val = _getMetricValue(rec);
                        final hourStr = '${rec.timestamp.hour.toString().padLeft(2, '0')}:00';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    rec.isRaining ? Icons.water_drop_rounded : Icons.access_time_rounded,
                                    size: 13,
                                    color: rec.isRaining ? const Color(0xFF0284C7) : textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pukul $hourStr',
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
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyBadge({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDailyStatusBadge(double maxVal, double avgVal, bool isDark) {
    String text;
    Color color;

    switch (_selectedMetric) {
      case MonitoringMetric.waterLevel:
        if (maxVal >= 35) {
          text = 'Siaga Banjir';
          color = const Color(0xFFEF4444);
        } else if (maxVal >= 20) {
          text = 'Waspada';
          color = const Color(0xFFF59E0B);
        } else {
          text = 'Kondisi Aman';
          color = const Color(0xFF10B981);
        }
        break;
      case MonitoringMetric.airQuality:
        if (avgVal > 3000) {
          text = 'Kualitas Buruk';
          color = const Color(0xFFEF4444);
        } else if (avgVal > 1500) {
          text = 'Polusi Ringan';
          color = const Color(0xFFF59E0B);
        } else {
          text = 'Udara Baik';
          color = const Color(0xFF10B981);
        }
        break;
      case MonitoringMetric.temperature:
        if (maxVal > 33) {
          text = 'Cuaca Panas';
          color = const Color(0xFFEA580C);
        } else {
          text = 'Suhu Normal';
          color = const Color(0xFF10B981);
        }
        break;
      case MonitoringMetric.humidity:
        if (avgVal > 80) {
          text = 'Lembap Tinggi';
          color = const Color(0xFF0284C7);
        } else {
          text = 'Kelembaban Normal';
          color = const Color(0xFF059669);
        }
        break;
    }

    return _buildDailyBadge(label: text, color: color, isDark: isDark);
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

  String _formatDateTime(DateTime dt) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dayName = days[dt.weekday - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minStr = dt.minute.toString().padLeft(2, '0');
    return '$dayName, ${dt.day}/${dt.month} $hour:$minStr';
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

    final dx = size.width / (records.length - 1);
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
