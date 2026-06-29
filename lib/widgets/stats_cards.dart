import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';
import '../theme/app_theme.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IPCheckerProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _HoverAnimatedCard(
                title: 'Total Devices',
                value: provider.totalPingCount.toDouble(),
                icon: Icons.devices,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HoverAnimatedCard(
                title: 'Online',
                value: provider.onlineCount.toDouble(),
                icon: Icons.check_circle,
                color: AppTheme.onlineColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HoverAnimatedCard(
                title: 'Offline',
                value: provider.offlineCount.toDouble(),
                icon: Icons.error,
                color: AppTheme.offlineColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HoverAnimatedCard(
                title: 'Average Ping',
                value: provider.avgPingMs,
                suffix: ' ms',
                icon: Icons.speed,
                color: AppTheme.checkingColor,
                isDecimal: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HoverAnimatedCard extends StatefulWidget {
  final String title;
  final double value;
  final String suffix;
  final IconData icon;
  final Color color;
  final bool isDecimal;

  const _HoverAnimatedCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = '',
    this.isDecimal = false,
    Key? key,
  }) : super(key: key);

  @override
  State<_HoverAnimatedCard> createState() => _HoverAnimatedCardState();
}

class _HoverAnimatedCardState extends State<_HoverAnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 28, color: widget.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.value < 0)
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    )
                  else
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: widget.value),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutQuart,
                      builder: (context, val, child) {
                        final displayVal = widget.isDecimal
                            ? val.toStringAsFixed(1)
                            : val.toInt().toString();
                        return Text(
                          '$displayVal${widget.suffix}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
