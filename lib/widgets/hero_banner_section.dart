import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/telemetry_data.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class HeroBannerSection extends StatefulWidget {
  final TelemetryData? telemetry;
  final MqttConnectionStateStatus connectionStatus;
  final VoidCallback onCheckUpdate;
  final VoidCallback onMenuTap;
  final VoidCallback onRetryConnection;
  final bool hasUpdate;
  final String currentVersion;

  const HeroBannerSection({
    super.key,
    required this.telemetry,
    required this.connectionStatus,
    required this.onCheckUpdate,
    required this.onMenuTap,
    required this.onRetryConnection,
    this.hasUpdate = false,
    this.currentVersion = '1.0.3',
  });

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection>
    with SingleTickerProviderStateMixin {
  int _activeSensorPage = 0;
  final PageController _pageController = PageController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Selected Landmark Background Image
  String _selectedImage = 'assets/images/hero-alun-alun.jpeg';
  String _selectedLandmarkName = 'ALUN-ALUN KOTA TEGAL';
  String _selectedCoordinates = '6°52\'S 109°08\'E';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _switchLandmark(String imagePath, String name, String coords) {
    setState(() {
      _selectedImage = imagePath;
      _selectedLandmarkName = name;
      _selectedCoordinates = coords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected =
        widget.connectionStatus == MqttConnectionStateStatus.connected;
    final isConnecting =
        widget.connectionStatus == MqttConnectionStateStatus.connecting;

    return Stack(
      children: [
        // 1. Background Image with Hero Fade
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: SizedBox(
            height: 540,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _selectedImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF0F172A),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white24, size: 48),
                      ),
                    );
                  },
                ),

                // Ambient Particles Overlay (Sparkles / Bokeh Effect)
                CustomPaint(
                  painter: _AmbientParticlesPainter(),
                ),

                // Cinematic Dark Vignette & Gradient Overlays
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xD9070A12), // Deep dark at top for header contrast
                        Color(0x55070A12), // Clearer middle to see the landmark
                        Color(0xAA070A12), // Transition
                        Color(0xFF0A0F1D), // Matches scaffold background
                      ],
                      stops: [0.0, 0.35, 0.70, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Foreground Interactive UI
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Brand Logo + Connection Pill + Menu
                _buildHeader(isConnected, isConnecting),

                const SizedBox(height: 28),

                // Hero Titles: NAFAS KOTA BAHARI
                _buildHeroTitle(),

                const SizedBox(height: 24),

                // Glassmorphism Card 1: DHT22 / Telemetry Carousel Card
                _buildDht22Card(),

                const SizedBox(height: 12),

                // Glassmorphism Card 2: ESP32-S3 Node Status Card
                _buildEsp32NodeCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Header with Tegal EcoSense logo, glowing connected pill, and hamburger menu
  Widget _buildHeader(bool isConnected, bool isConnecting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand: Double-ring cyan icon + TEGAL ECOSENSE
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AetherConstants.cyanAccent.withValues(alpha: 0.8),
                  width: 1.8,
                ),
                gradient: RadialGradient(
                  colors: [
                    AetherConstants.cyanAccent.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AetherConstants.cyanAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'TEGAL ECOSENSE',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),

        // Right Action Elements: Connected Pill & Menu Button
        Row(
          children: [
            // Status Pill (Glass with green glowing dot)
            GestureDetector(
              onTap: widget.onRetryConnection,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x331E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isConnected
                            ? const Color(0x5510B981)
                            : isConnecting
                                ? const Color(0x55F59E0B)
                                : const Color(0x55EF4444),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated pulsing dot
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected
                                    ? AetherConstants.statusGreen
                                    : isConnecting
                                        ? AetherConstants.statusYellow
                                        : AetherConstants.statusRed,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isConnected
                                            ? AetherConstants.statusGreen
                                            : isConnecting
                                                ? AetherConstants.statusYellow
                                                : AetherConstants.statusRed)
                                        .withValues(
                                            alpha: _pulseAnimation.value * 0.8),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected
                              ? 'CONNECTED'
                              : isConnecting
                                  ? 'CONNECTING'
                                  : 'OFFLINE',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Frosted Circular Menu / Update Button
            GestureDetector(
              onTap: widget.onMenuTap,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x401E293B),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Red dot badge if update available
                  if (widget.hasUpdate)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Big Bold Typography matching user screenshot
  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NAFAS KOTA\nBAHARI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.08,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'RUANG TERBUKA, DATA REALTIME',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showLandmarkSelector(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x351E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AetherConstants.cyanAccent.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AetherConstants.cyanAccent,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '$_selectedLandmarkName • $_selectedCoordinates',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AetherConstants.cyanAccent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.unfold_more_rounded,
                  color: AetherConstants.cyanAccent,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLandmarkSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: BoxDecoration(
                color: const Color(0xF00F172A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'PILIH LANDMARK KOTA TEGAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AetherConstants.cyanAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLandmarkTile(
                    ctx,
                    title: 'Alun-Alun Kota Tegal',
                    subtitle: 'Ruang Terbuka Hijau & Masjid Agung',
                    coords: '6°52\'S 109°08\'E',
                    assetPath: 'assets/images/hero-alun-alun.jpeg',
                  ),
                  _buildLandmarkTile(
                    ctx,
                    title: 'Jalan Pancasila Tegal',
                    subtitle: 'Kawasan Wisata Sejarah & Taman Kota',
                    coords: '6°52\'S 109°08\'E',
                    assetPath: 'assets/images/jalan-pancasila.jpeg',
                  ),
                  _buildLandmarkTile(
                    ctx,
                    title: 'Masjid Agung Kota Tegal',
                    subtitle: 'Simbol Religi & Ikon Kota Bahari',
                    coords: '6°52\'S 109°08\'E',
                    assetPath: 'assets/images/masjid-agung.jpeg',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandmarkTile(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required String coords,
    required String assetPath,
  }) {
    final isSelected = _selectedImage == assetPath;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          assetPath,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AetherConstants.cyanAccent : Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: const Color(0xFF94A3B8),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AetherConstants.cyanAccent)
          : null,
      onTap: () {
        _switchLandmark(assetPath, title.toUpperCase(), coords);
        Navigator.pop(ctx);
      },
    );
  }

  /// Glassmorphic DHT22 Sensor Card with Carousel
  Widget _buildDht22Card() {
    final t = widget.telemetry;
    final humidityStr =
        t != null ? '${t.humidityPercent.toStringAsFixed(1)}%' : '--.-%';
    final tempStr =
        t != null ? '${t.temperatureC.toStringAsFixed(1)}°C' : '--.-°C';
    final airStr = t != null ? t.airQualityStatus : 'Normal / Baik';
    final waterStr =
        t != null ? '${t.waterLevelCm.toStringAsFixed(1)} cm' : '--.- cm';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0x55141E33),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AetherConstants.cyanAccent.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: DHT22 SENSOR label + Droplet Circular Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeSensorPage == 0
                        ? 'DHT22 SENSOR'
                        : _activeSensorPage == 1
                            ? 'TEMPERATURE SENSOR'
                            : _activeSensorPage == 2
                                ? 'MQ-135 AIR QUALITY'
                                : 'WATER LEVEL SENSOR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AetherConstants.cyanAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AetherConstants.cyanAccent.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                      color: AetherConstants.cyanAccent.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Icon(
                        _activeSensorPage == 0
                            ? Icons.water_drop_outlined
                            : _activeSensorPage == 1
                                ? Icons.thermostat_rounded
                                : _activeSensorPage == 2
                                    ? Icons.air_rounded
                                    : Icons.waves_rounded,
                        color: AetherConstants.cyanAccent,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Middle Carousel Section
              SizedBox(
                height: 58,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() {
                      _activeSensorPage = idx;
                    });
                  },
                  children: [
                    // Slide 1: Kelembaban
                    _buildCarouselItem(
                      label: 'KELEMBABAN',
                      value: humidityStr,
                      subtitle: 'Uap Air Relatif',
                      secondary: tempStr,
                    ),
                    // Slide 2: Suhu
                    _buildCarouselItem(
                      label: 'TEMPERATUR',
                      value: tempStr,
                      subtitle: 'Suhu Lingkungan',
                      secondary: humidityStr,
                    ),
                    // Slide 3: Kualitas Udara
                    _buildCarouselItem(
                      label: 'KUALITAS UDARA',
                      value: airStr,
                      subtitle: 'Sensor MQ-135',
                      secondary: t != null ? '${t.mq135SensorMv.toStringAsFixed(0)} mV' : '-- mV',
                    ),
                    // Slide 4: Tinggi Air
                    _buildCarouselItem(
                      label: 'TINGGI AIR',
                      value: waterStr,
                      subtitle: 'Status: ${t?.floodStatus ?? "Aman"}',
                      secondary: t != null ? '${t.waterDistanceCm.toStringAsFixed(1)} cm' : '-- cm',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Carousel Dots Indicator
              Row(
                children: List.generate(4, (index) {
                  final isSelected = index == _activeSensorPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 5),
                    width: isSelected ? 20 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem({
    required String label,
    required String value,
    required String subtitle,
    required String secondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Label & Big Telemetry Value
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        // Right: Subtitle descriptor & secondary metric
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              secondary,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AetherConstants.cyanAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Glassmorphic ESP32-S3 Node Card
  Widget _buildEsp32NodeCard() {
    final t = widget.telemetry;
    final rssiStr = t != null ? '${t.wifiRssiDbm} dBm' : '-- dBm';
    final uptimeStr =
        t != null ? AetherFormatters.formatUptime(t.uptimeSeconds) : '--:--:--';
    final deviceName = t != null ? t.deviceId : 'ESP32-S3 NODE';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x44141E33),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Device Node specs
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.memory_rounded,
                        color: AetherConstants.cyanAccent,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deviceName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFCBD5E1),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.wifi_rounded,
                        color: AetherConstants.statusGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rssiStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Up: $uptimeStr',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: Microcontroller Node Illustration / Icon with glowing pulse
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x400F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AetherConstants.cyanAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.router_rounded,
                        color: AetherConstants.cyanAccent.withValues(alpha: 0.8),
                        size: 24,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AetherConstants.statusGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for glowing ambient bokeh particles overlaying the hero image
class _AmbientParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    final particles = [
      {'x': 0.15, 'y': 0.12, 'r': 2.5, 'alpha': 0.6},
      {'x': 0.82, 'y': 0.10, 'r': 3.0, 'alpha': 0.7},
      {'x': 0.72, 'y': 0.22, 'r': 2.0, 'alpha': 0.5},
      {'x': 0.25, 'y': 0.35, 'r': 1.8, 'alpha': 0.4},
      {'x': 0.90, 'y': 0.38, 'r': 2.8, 'alpha': 0.6},
      {'x': 0.60, 'y': 0.55, 'r': 2.2, 'alpha': 0.5},
      {'x': 0.12, 'y': 0.75, 'r': 3.2, 'alpha': 0.7},
      {'x': 0.78, 'y': 0.78, 'r': 2.0, 'alpha': 0.5},
      {'x': 0.35, 'y': 0.88, 'r': 2.5, 'alpha': 0.6},
    ];

    for (final p in particles) {
      final dx = (p['x'] as double) * size.width;
      final dy = (p['y'] as double) * size.height;
      final radius = p['r'] as double;
      final alpha = (p['alpha'] as double) * 255;

      // Glow halo
      particlePaint.color = const Color(0xFF38BDF8).withAlpha((alpha * 0.4).round());
      canvas.drawCircle(Offset(dx, dy), radius * 2.2, particlePaint);

      // Core point
      particlePaint.color = const Color(0xFFE0F2FE).withAlpha(alpha.round());
      canvas.drawCircle(Offset(dx, dy), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
