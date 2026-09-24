import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

class EmptyTelemetryView extends StatefulWidget {
  final MqttConnectionStateStatus connectionStatus;
  final VoidCallback onRetry;

  const EmptyTelemetryView({
    super.key,
    required this.connectionStatus,
    required this.onRetry,
  });

  @override
  State<EmptyTelemetryView> createState() => _EmptyTelemetryViewState();
}

class _EmptyTelemetryViewState extends State<EmptyTelemetryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected =
        widget.connectionStatus == MqttConnectionStateStatus.connected;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated Pulse Icon
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isConnected
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFFDE68A),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isConnected
                          ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isConnected
                      ? Icons.radar_rounded
                      : Icons.wifi_find_rounded,
                  color: isConnected
                      ? AetherConstants.primaryBlue
                      : AetherConstants.statusYellow,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Primary Title
            Text(
              isConnected
                  ? 'Menunggu Telemetri ESP32'
                  : 'Menghubungkan ke Broker...',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AetherConstants.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle Description
            Text(
              isConnected
                  ? 'Menunggu paket data telemetri pertama dari perangkat ESP32 pada topik aethersense/+/telemetry...'
                  : 'Sedang membangun koneksi MQTT ke broker.hivemq.com (port 1883)...',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.5,
                color: AetherConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Connection State Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected
                        ? 'MQTT Siap • Listening Telemetry'
                        : 'MQTT Handshake...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),

            if (!isConnected) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Coba Hubungkan Ulang',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AetherConstants.primaryBlue,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
