import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/telemetry_data.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';
import 'monitoring_history_modal.dart';
import 'overview_carousel_card.dart';

class HeroBannerSection extends StatefulWidget {
  final TelemetryData? telemetry;
  final MqttConnectionStateStatus connectionStatus;
  final VoidCallback onCheckUpdate;
  final VoidCallback onToggleTheme;
  final VoidCallback onMenuTap;
  final VoidCallback onRetryConnection;
  final bool isDarkMode;
  final bool hasUpdate;
  final String currentVersion;

  const HeroBannerSection({
    super.key,
    required this.telemetry,
    required this.connectionStatus,
    required this.onCheckUpdate,
    required this.onToggleTheme,
    required this.onMenuTap,
    required this.onRetryConnection,
    required this.isDarkMode,
    this.hasUpdate = false,
    this.currentVersion = '1.0.4',
  });

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  // Selected Landmark
  String _selectedImage = 'assets/images/hero-alun-alun.jpeg';
  String _selectedLandmarkName = 'Alun-Alun Kota Tegal';
  String _selectedCoordinates = '6°52\'S 109°08\'E';

  void _switchLandmark(String imagePath, String name, String coords) {
    setState(() {
      _selectedImage = imagePath;
      _selectedLandmarkName = name;
      _selectedCoordinates = coords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final isConnected = widget.connectionStatus == MqttConnectionStateStatus.connected;
    final isConnecting = widget.connectionStatus == MqttConnectionStateStatus.connecting;

    final headerBg = isDark ? AetherConstants.surfaceDark : Colors.white;
    final headerBorder = isDark ? AetherConstants.borderDark : AetherConstants.borderLight;
    final textPrimary = isDark ? AetherConstants.textPrimaryDark : AetherConstants.textPrimaryLight;
    final textSecondary = isDark ? AetherConstants.textSecondaryDark : AetherConstants.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Clean App Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: headerBg,
            border: Border(
              bottom: BorderSide(color: headerBorder, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: App Brand & Version
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x2538BDF8) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tegal EcoSense',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Smart City Tegal • v${widget.currentVersion}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: Action Buttons (Theme Toggle, Connection Pill, Menu)
              Row(
                children: [
                  // Theme Toggle Button (Light / Dark Switch)
                  IconButton(
                    onPressed: widget.onToggleTheme,
                    tooltip: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
                      size: 22,
                    ),
                  ),

                  // Connection Status Pill
                  GestureDetector(
                    onTap: widget.onRetryConnection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? (isDark ? const Color(0x3010B981) : const Color(0xFFECFDF5))
                            : isConnecting
                                ? (isDark ? const Color(0x30F59E0B) : const Color(0xFFFFFBEB))
                                : (isDark ? const Color(0x30EF4444) : const Color(0xFFFEF2F2)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isConnected
                              ? (isDark ? const Color(0x6610B981) : const Color(0xFFA7F3D0))
                              : isConnecting
                                  ? (isDark ? const Color(0x66F59E0B) : const Color(0xFFFDE68A))
                                  : (isDark ? const Color(0x66EF4444) : const Color(0xFFFECACA)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected
                                  ? AetherConstants.statusGreen
                                  : isConnecting
                                      ? AetherConstants.statusYellow
                                      : AetherConstants.statusRed,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected
                                ? 'Terhubung'
                                : isConnecting
                                    ? 'Menghubungkan'
                                    : 'Offline',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isConnected
                                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                                  : isConnecting
                                      ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E))
                                      : (isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Menu / Update Button
                  IconButton(
                    onPressed: widget.onMenuTap,
                    tooltip: 'Menu & Info',
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.more_vert_rounded,
                          color: textSecondary,
                          size: 22,
                        ),
                        if (widget.hasUpdate)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Clean Hero Image Banner (Alun-Alun Tegal)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Real Photo
                  Image.asset(
                    _selectedImage,
                    fit: BoxFit.cover,
                  ),

                  // Soft Clean Vignette Gradient for high readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),

                  // Content inside Banner
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Interactive Landmark Badge
                        InkWell(
                          onTap: () => _showLandmarkSelector(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF38BDF8),
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$_selectedLandmarkName • $_selectedCoordinates',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.expand_more_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Title: Nafas Kota Bahari
                        Text(
                          'Nafas Kota Bahari',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Ruang Terbuka Hijau & Pemantauan IoT Realtime',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Dropdown Riwayat Data di sudut kanan atas foto
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _buildHistoryDropdownPill(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Quick Landmark Switcher Chips (Scrollable Horizontal & Anti-Truncate)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              _buildLandmarkChip(
                label: 'Alun-Alun Tegal',
                imagePath: 'assets/images/hero-alun-alun.jpeg',
                coords: '6°52\'S 109°08\'E',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildLandmarkChip(
                label: 'Jalan Pancasila',
                imagePath: 'assets/images/jalan-pancasila.jpeg',
                coords: '6°52\'S 109°08\'E',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildLandmarkChip(
                label: 'Masjid Agung Tegal',
                imagePath: 'assets/images/masjid-agung.jpeg',
                coords: '6°52\'S 109°08\'E',
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. Interactive Auto-Sliding Carousel Card (Banjir, Lampu, Iklim, IoT)
        OverviewCarouselCard(
          telemetry: widget.telemetry,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLandmarkChip({
    required String label,
    required String imagePath,
    required String coords,
    required bool isDark,
  }) {
    final isSelected = _selectedImage == imagePath;
    final primaryColor = isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _switchLandmark(imagePath, label, coords),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? primaryColor.withValues(alpha: 0.22) : const Color(0xFFEFF6FF))
                : (isDark ? AetherConstants.surfaceDark : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AetherConstants.borderDark : AetherConstants.borderLight),
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.location_on_rounded,
                size: 13,
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : primaryColor)
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                ),
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showLandmarkSelector(BuildContext context) {
    final isDark = widget.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AetherConstants.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Pilih Lokasi Landmark Tegal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AetherConstants.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildModalTile(
                ctx,
                title: 'Alun-Alun Kota Tegal',
                subtitle: 'Ruang Terbuka Hijau & Ikon Kota Bahari',
                assetPath: 'assets/images/hero-alun-alun.jpeg',
                coords: '6°52\'S 109°08\'E',
                isDark: isDark,
              ),
              _buildModalTile(
                ctx,
                title: 'Jalan Pancasila Tegal',
                subtitle: 'Kawasan Wisata Sejarah & Taman Kota',
                assetPath: 'assets/images/jalan-pancasila.jpeg',
                coords: '6°52\'S 109°08\'E',
                isDark: isDark,
              ),
              _buildModalTile(
                ctx,
                title: 'Masjid Agung Kota Tegal',
                subtitle: 'Simbol Religi Kota Tegal',
                assetPath: 'assets/images/masjid-agung.jpeg',
                coords: '6°52\'S 109°08\'E',
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalTile(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required String assetPath,
    required String coords,
    required bool isDark,
  }) {
    final isSelected = _selectedImage == assetPath;
    final primaryColor = isDark ? AetherConstants.cyanAccent : AetherConstants.primaryBlue;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(assetPath, width: 48, height: 48, fit: BoxFit.cover),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? primaryColor : (isDark ? Colors.white : AetherConstants.textPrimaryLight),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: primaryColor)
          : null,
      onTap: () {
        _switchLandmark(assetPath, title, coords);
        Navigator.pop(ctx);
      },
    );
  }

  Widget _buildHistoryDropdownPill(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Pilih Rentang Riwayat',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      elevation: 8,
      offset: const Offset(0, 42),
      onSelected: (days) {
        MonitoringHistoryModal.show(context, initialDays: days);
      },
      itemBuilder: (ctx) => [
        _buildPopupMenuItem(7, _formatRangeLabel(7), Icons.calendar_month_rounded),
        _buildPopupMenuItem(6, _formatRangeLabel(6), Icons.date_range_rounded),
        _buildPopupMenuItem(5, _formatRangeLabel(5), Icons.date_range_rounded),
        _buildPopupMenuItem(4, _formatRangeLabel(4), Icons.date_range_rounded),
        _buildPopupMenuItem(3, _formatRangeLabel(3), Icons.date_range_rounded),
        _buildPopupMenuItem(2, _formatRangeLabel(2), Icons.date_range_rounded),
        _buildPopupMenuItem(1, _formatRangeLabel(1), Icons.today_rounded),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insights_rounded,
              size: 14,
              color: Color(0xFF38BDF8),
            ),
            const SizedBox(width: 5),
            Text(
              'Riwayat Data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(int days, String label, IconData icon) {
    return PopupMenuItem<int>(
      value: days,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF0284C7),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: days == 7 ? FontWeight.w800 : FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRangeLabel(int days) {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final endStr = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]}';

    if (days == 1) {
      return 'Hari Ini ($endStr • 24 Jam)';
    }

    final start = now.subtract(Duration(days: days - 1));
    final startStr = '${start.day.toString().padLeft(2, '0')} ${months[start.month - 1]}';
    return '$days Hari Terakhir ($startStr – $endStr)';
  }
}

