import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/interactive_cat_mascot.dart';
import '../widgets/pressable_scale.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final GlobalKey _emailFieldKey = GlobalKey();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  CatMascotState _mascotState = CatMascotState.idle;
  double _lookProgress = 0.5;

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);

    _emailController.addListener(_onEmailTextChanged);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _emailController.removeListener(_onEmailTextChanged);

    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (_isLoading) return;
    if (_emailFocusNode.hasFocus) {
      setState(() {
        _errorMessage = null;
        _mascotState = _emailController.text.isEmpty
            ? CatMascotState.emailFocused
            : CatMascotState.emailTyping;
      });
      _updateCursorLookProgress();
    } else {
      _checkFallbackState();
    }
  }

  void _onPasswordFocusChange() {
    if (_isLoading) return;
    if (_passwordFocusNode.hasFocus) {
      setState(() {
        _errorMessage = null;
        _mascotState = _isPasswordVisible
            ? CatMascotState.passwordVisible
            : CatMascotState.passwordHidden;
      });
    } else {
      _checkFallbackState();
    }
  }

  void _onEmailTextChanged() {
    if (_emailFocusNode.hasFocus) {
      if (_mascotState != CatMascotState.emailTyping) {
        setState(() {
          _mascotState = CatMascotState.emailTyping;
        });
      }
      _updateCursorLookProgress();
    }
  }

  void _checkFallbackState() {
    if (!_emailFocusNode.hasFocus && !_passwordFocusNode.hasFocus) {
      setState(() {
        _mascotState = CatMascotState.idle;
      });
    }
  }

  /// Measure the cursor's exact horizontal position within the text field
  void _updateCursorLookProgress() {
    final text = _emailController.text;
    final selection = _emailController.selection;
    final int cursorOffset = selection.isValid && selection.baseOffset >= 0
        ? selection.baseOffset.clamp(0, text.length)
        : text.length;

    double calculatedProgress = 0.5;

    if (text.isEmpty || cursorOffset == 0) {
      calculatedProgress = 0.15; // Looking towards the left start of field
    } else {
      try {
        final textStyle = GoogleFonts.plusJakartaSans(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: text.substring(0, cursorOffset),
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        // Get RenderBox width or approximate available text box width (approx 240px)
        double fieldWidth = 240.0;
        final renderBox = _emailFieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          fieldWidth = (renderBox.size.width - 90.0).clamp(100.0, 500.0);
        }

        // Normalize text width to 0.15 (left) ... 0.88 (right)
        final double ratio = (textPainter.width / fieldWidth).clamp(0.0, 1.0);
        calculatedProgress = 0.18 + ratio * 0.70;
      } catch (_) {
        calculatedProgress = 0.5;
      }
    }

    if ((_lookProgress - calculatedProgress).abs() > 0.02) {
      setState(() {
        _lookProgress = calculatedProgress;
      });
    }
  }

  void _togglePasswordVisibility() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
      if (_passwordFocusNode.hasFocus) {
        _mascotState = _isPasswordVisible
            ? CatMascotState.passwordVisible
            : CatMascotState.passwordHidden;
      }
    });
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mascotState = CatMascotState.loading;
    });

    final result = await AuthService.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.success) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isLoading = false;
        _mascotState = CatMascotState.success;
      });

      // Show brief celebratory moment before navigating
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 280),
        ),
      );
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? 'Login gagal, periksa email dan password.';
        _mascotState = CatMascotState.error;
      });

      // Reset error state back to idle after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted && _mascotState == CatMascotState.error) {
          setState(() {
            _mascotState = CatMascotState.idle;
          });
        }
      });
    }
  }

  void _autoFillDemoAccount(String email, String pass) {
    HapticFeedback.selectionClick();
    setState(() {
      _emailController.text = email;
      _passwordController.text = pass;
      _errorMessage = null;
    });
    _updateCursorLookProgress();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const primaryBlue = Color(0xFF00A3E0);
    const darkNavy = Color(0xFF0E2A47);
    const borderColor = Color(0xFFE5EDF5);
    const bgColor = Color(0xFFF6FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Sky & Landmark Silhouette Background Painter
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: CustomPaint(
              painter: _CitySilhouttePainter(),
            ),
          ),

          // 2. Scrollable Body containing Mascot & White Card
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Top spacing so the cat head and card sit comfortably lower under the sky
                  const SizedBox(height: 32),

                  // Interactive 3D Cat Mascot layout with natural desk-resting integration
                  InteractiveCatMascotCardLayout(
                    state: _mascotState,
                    lookProgress: _lookProgress,
                    cardChild: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140E2A47),
                            blurRadius: 24,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Subtitle
                          Text(
                            'Selamat datang!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: darkNavy,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Masuk untuk melanjutkan ke Smart City Tegal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF748391),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Error message banner
                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 1. Email Field
                          Container(
                            key: _emailFieldKey,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFDFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _emailFocusNode.hasFocus
                                    ? primaryBlue
                                    : borderColor,
                                width: _emailFocusNode.hasFocus ? 1.6 : 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: darkNavy,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.mail_outline_rounded,
                                  color: _emailFocusNode.hasFocus
                                      ? primaryBlue
                                      : const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                hintText: 'Masukkan email kamu',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA0AEC0),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 2. Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFDFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _passwordFocusNode.hasFocus
                                    ? primaryBlue
                                    : borderColor,
                                width: _passwordFocusNode.hasFocus ? 1.6 : 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: !_isPasswordVisible,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleLogin(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: darkNavy,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: _passwordFocusNode.hasFocus
                                      ? primaryBlue
                                      : const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _isPasswordVisible
                                        ? primaryBlue
                                        : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                hintText: 'Masukkan password',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA0AEC0),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // 3. Login Action Button ("Masuk →")
                          PressableScale(
                            onTap: _isLoading ? null : _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Masuk',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Quick Demo Account Auto-Fill Pill
                          Center(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildDemoChip('user@gmail.com', 'pass1234', 'Demo User'),
                                _buildDemoChip('admin@tegal.go.id', 'admin123', 'Admin'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer "Belum punya akun? Daftar"
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Belum punya akun? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registrasi mandiri segera tersedia. Gunakan akun demo untuk masuk.',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Daftar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom padding when keyboard appears
                          SizedBox(height: bottomInset > 0 ? bottomInset + 16 : 16),
                        ],
                      ),
                    ),
                  ),
                  // Bottom margin so rounded card corners float nicely
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String email, String pass, String label) {
    return GestureDetector(
      onTap: () => _autoFillDemoAccount(email, pass),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded, size: 13, color: Color(0xFF00A3E0)),
            const SizedBox(width: 4),
            Text(
              '$label: $email',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle sky silhouette of Kota Tegal landmark in soft pastel blue
class _CitySilhouttePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFCEE7F8),
          Color(0xFFEAF4FC),
          Color(0xFFF6FAFC),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(skyRect);

    canvas.drawRect(skyRect, skyPaint);

    // Subtle background city & water tower silhouette
    final silPaint = Paint()
      ..color = const Color(0xFF88BFE8).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.72);

    // Left city buildings
    path.lineTo(size.width * 0.12, size.height * 0.72);
    path.lineTo(size.width * 0.12, size.height * 0.58);
    path.lineTo(size.width * 0.20, size.height * 0.58);
    path.lineTo(size.width * 0.20, size.height * 0.65);
    path.lineTo(size.width * 0.28, size.height * 0.65);

    // Tegal Water Tower / Landmark (Menara Air) in the center-right
    const towerX = 0.75;
    path.lineTo(size.width * (towerX - 0.08), size.height * 0.68);
    path.lineTo(size.width * (towerX - 0.05), size.height * 0.44);
    path.lineTo(size.width * (towerX - 0.07), size.height * 0.40);
    path.lineTo(size.width * (towerX - 0.05), size.height * 0.32);
    path.lineTo(size.width * (towerX + 0.05), size.height * 0.32);
    path.lineTo(size.width * (towerX + 0.07), size.height * 0.40);
    path.lineTo(size.width * (towerX + 0.05), size.height * 0.44);
    path.lineTo(size.width * (towerX + 0.08), size.height * 0.68);

    // Right buildings
    path.lineTo(size.width * 0.90, size.height * 0.68);
    path.lineTo(size.width * 0.90, size.height * 0.60);
    path.lineTo(size.width, size.height * 0.60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, silPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
