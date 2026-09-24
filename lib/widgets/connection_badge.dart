import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

class ConnectionBadge extends StatelessWidget {
  final MqttConnectionStateStatus status;
  final bool isLive;
  final String freshnessText;
  final VoidCallback? onRetry;

  const ConnectionBadge({
    super.key,
    required this.status,
    required this.isLive,
    required this.freshnessText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color bgColor;
    Color textColor;
    String label;
    Widget leadingWidget;

    switch (status) {
      case MqttConnectionStateStatus.connected:
        dotColor = AetherConstants.statusGreen;
        bgColor = AetherConstants.statusGreenBg;
        textColor = AetherConstants.statusGreenText;
        label = 'Connected';
        leadingWidget = Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        );
        break;

      case MqttConnectionStateStatus.connecting:
        dotColor = AetherConstants.statusYellow;
        bgColor = AetherConstants.statusYellowBg;
        textColor = AetherConstants.statusYellowText;
        label = 'Connecting...';
        leadingWidget = SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(dotColor),
          ),
        );
        break;

      case MqttConnectionStateStatus.reconnecting:
        dotColor = AetherConstants.statusOrange;
        bgColor = AetherConstants.statusOrangeBg;
        textColor = AetherConstants.statusOrangeText;
        label = 'Reconnecting...';
        leadingWidget = SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(dotColor),
          ),
        );
        break;

      case MqttConnectionStateStatus.disconnected:
      case MqttConnectionStateStatus.error:
        dotColor = AetherConstants.statusRed;
        bgColor = AetherConstants.statusRedBg;
        textColor = AetherConstants.statusRedText;
        label = 'Disconnected';
        leadingWidget = Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MQTT Connection Pill
        InkWell(
          onTap: status == MqttConnectionStateStatus.disconnected ||
                  status == MqttConnectionStateStatus.error
              ? onRetry
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dotColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leadingWidget,
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (status == MqttConnectionStateStatus.disconnected ||
                    status == MqttConnectionStateStatus.error) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.refresh_rounded, size: 12, color: textColor),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Telemetry Stream Status Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isLive ? const Color(0xFFF1F5F9) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLive ? const Color(0xFFCBD5E1) : const Color(0xFFFDE68A),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                size: 13,
                color: isLive ? const Color(0xFF475569) : const Color(0xFFD97706),
              ),
              const SizedBox(width: 5),
              Text(
                freshnessText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLive ? const Color(0xFF475569) : const Color(0xFFB45309),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
