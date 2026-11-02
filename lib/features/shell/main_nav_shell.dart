import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/url_launcher_helper.dart';
import '../../widgets/entrance_motion.dart';
import '../../widgets/whatsapp_mark.dart';

class MainNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavShell({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        navigationShell.currentIndex < 4 ? navigationShell.currentIndex : 0;

    return Scaffold(
      body: _BranchMotion(
        branchIndex: navigationShell.currentIndex,
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFEDE9FF),
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Book',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment_rounded),
            label: 'Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering_rounded),
            label: 'Artisan',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'WhatsApp Dispatch',
        onPressed: () {
          UrlLauncherHelper.launchWhatsApp(
            customMessage:
                'Hello ALLFIX Xpress Dispatch HQ, I need assistance with a service booking.',
          );
        },
        backgroundColor: const Color(0xFF1FAF62),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: const EntranceMotion(
          delay: Duration(milliseconds: 80),
          child: WhatsAppMark(size: 27),
        ),
      ),
    );
  }
}

class _BranchMotion extends StatefulWidget {
  final int branchIndex;
  final Widget child;

  const _BranchMotion({required this.branchIndex, required this.child});

  @override
  State<_BranchMotion> createState() => _BranchMotionState();
}

class _BranchMotionState extends State<_BranchMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: 1,
    );
    final curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.018),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void didUpdateWidget(covariant _BranchMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.branchIndex != oldWidget.branchIndex) {
      if (MediaQuery.of(context).disableAnimations) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
