import 'package:anti_hook_vpn/anti_hook_vpn.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AntiHookVpn Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SecurityScanPage(),
    );
  }
}

class SecurityScanPage extends StatefulWidget {
  const SecurityScanPage({super.key});

  @override
  State<SecurityScanPage> createState() => _SecurityScanPageState();
}

class _SecurityScanPageState extends State<SecurityScanPage>
    with SingleTickerProviderStateMixin {
  SecurityStatus? _lastStatus;
  bool _isScanning = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Auto-scan on launch
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
      _lastStatus = null;
    });
    _pulseController.repeat(reverse: true);

    final status = await AntiHookVpn.checkSecurity();

    _pulseController.stop();
    _pulseController.reset();

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _lastStatus = status;
    });

    // Nếu bị tấn công, hiện dialog block
    if (status.isAttacked) {
      await AntiHookVpn.checkAndBlockIfNeeded(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Security Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              _ScannerOrb(
                isScanning: _isScanning,
                status: _lastStatus,
                pulseAnimation: _pulseAnimation,
              ),
              const SizedBox(height: 40),
              _StatusCards(status: _lastStatus, isScanning: _isScanning),
              const Spacer(),
              _ScanButton(isScanning: _isScanning, onTap: _scan),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Scanner Orb ─────────────────────────────────────────────────────────────

class _ScannerOrb extends StatelessWidget {
  const _ScannerOrb({
    required this.isScanning,
    required this.status,
    required this.pulseAnimation,
  });

  final bool isScanning;
  final SecurityStatus? status;
  final Animation<double> pulseAnimation;

  Color get _orbColor {
    if (isScanning || status == null) return const Color(0xFF3A3A6E);
    return status!.isAttacked
        ? const Color(0xFFD32F2F)
        : const Color(0xFF1B5E20);
  }

  Color get _glowColor {
    if (isScanning || status == null) return const Color(0xFF6060CC);
    return status!.isAttacked
        ? const Color(0xFFFF5252)
        : const Color(0xFF69F0AE);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (_, child) => Transform.scale(
        scale: isScanning ? pulseAnimation.value : 1.0,
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _orbColor,
          boxShadow: [
            BoxShadow(
              color: _glowColor.withValues(alpha: 0.5),
              blurRadius: 60,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: _glowColor.withValues(alpha: 0.2),
              blurRadius: 100,
              spreadRadius: 30,
            ),
          ],
        ),
        child: Center(
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isScanning) {
      return const SizedBox(
        width: 56,
        height: 56,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.white70,
        ),
      );
    }
    if (status == null) {
      return const Icon(Icons.shield_outlined, size: 72, color: Colors.white54);
    }
    return Icon(
      status!.isAttacked ? Icons.gpp_bad_rounded : Icons.verified_user_rounded,
      size: 72,
      color: Colors.white,
    );
  }
}

// ─── Status Cards ─────────────────────────────────────────────────────────────

class _StatusCards extends StatelessWidget {
  const _StatusCards({required this.status, required this.isScanning});

  final SecurityStatus? status;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    if (isScanning) {
      return const Text(
        'Đang quét bảo mật...',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    if (status == null) {
      return const Text(
        'Nhấn Scan để kiểm tra thiết bị',
        style: TextStyle(color: Colors.white54, fontSize: 15),
      );
    }

    return Column(
      children: [
        Text(
          status!.isAttacked ? '⚠ Phát hiện mối đe dọa' : '✓ Thiết bị an toàn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: status!.isAttacked
                ? const Color(0xFFFF5252)
                : const Color(0xFF69F0AE),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _DetectionCard(
                label: 'Frida',
                icon: Icons.bug_report_rounded,
                detected: status!.isFridaDetected,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DetectionCard(
                label: 'VPN / Proxy',
                icon: Icons.vpn_key_rounded,
                detected: status!.isProxyOrVpnDetected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetectionCard extends StatelessWidget {
  const _DetectionCard({
    required this.label,
    required this.icon,
    required this.detected,
  });

  final String label;
  final IconData icon;
  final bool detected;

  @override
  Widget build(BuildContext context) {
    final color = detected
        ? const Color(0xFFFF5252)
        : const Color(0xFF69F0AE);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detected ? 'Detected' : 'Clean',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scan Button ─────────────────────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.isScanning, required this.onTap});

  final bool isScanning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isScanning ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isScanning
              ? const LinearGradient(
                  colors: [Color(0xFF2A2A4A), Color(0xFF2A2A4A)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF6060CC), Color(0xFF9040CC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: isScanning
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6060CC).withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            isScanning ? 'Đang quét...' : 'Scan Now',
            style: TextStyle(
              color: isScanning ? Colors.white38 : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
