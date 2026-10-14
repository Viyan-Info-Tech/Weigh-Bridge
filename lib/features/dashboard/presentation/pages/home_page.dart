import 'dart:async';
import 'dart:io' show Platform, Process;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../bill/presentation/pages/bill_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../report/presentation/pages/report_page.dart';
import '../../../auth/presentation/widgets/truck_logo.dart';
import '../../../../core/presentation/widgets/admin_password_dialog.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isNavMenuOpen = false;

  /// True while the drawer is sliding out. The dim scrim unmounts instantly
  /// on close (so it can never linger invisibly over the UI), while the
  /// drawer panel itself stays mounted until the reverse animation finishes.
  bool _isNavMenuClosing = false;
  final FocusNode _appShortcutsFocusNode = FocusNode(
    debugLabel: 'applicationNavigationShortcuts',
  );
  final GlobalKey<BillPageState> _billPageKey = GlobalKey<BillPageState>();

  /// Slide/fade animation for the left navigation drawer (~280 ms).
  late final AnimationController _navDrawerController;
  late final Animation<Offset> _navDrawerSlide;
  late final Animation<double> _navDrawerScrim;

  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleAppKeyEvent);
    _navDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final curved = CurvedAnimation(
      parent: _navDrawerController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _navDrawerSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(curved);
    _navDrawerScrim = Tween<double>(begin: 0, end: 0.45).animate(curved);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleAppKeyEvent);
    _navDrawerController.dispose();
    _clockTimer.cancel();
    _appShortcutsFocusNode.dispose();
    super.dispose();
  }

  /// Closes the navigation drawer on Escape.
  ///
  /// The weighment page gates its own global keys on [isActive], which is
  /// false while the drawer is open, so this is the only Escape consumer
  /// and the form can never be cleared by the same keystroke.
  bool _handleAppKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_isNavMenuOpen && event.logicalKey == LogicalKeyboardKey.escape) {
      _closeNavMenu();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _appShortcutsFocusNode,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          // The navigation drawer overlays the normal layout via a Stack
          // so opening it never pushes, resizes, or shifts the header,
          // content, or footer.
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. Top Application Header
                  _buildAppHeader(context),

                  // 2. Main Active Content Screen
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        BillPage(
                          key: _billPageKey,
                          // While the navigation drawer is open or sliding
                          // out, the weighment page ignores global keys so
                          // Escape closes the drawer instead of clearing
                          // the form.
                          isActive:
                              _selectedIndex == 0 &&
                              !_isNavMenuOpen &&
                              !_isNavMenuClosing,
                          onExit: () => _confirmLogout(context),
                        ),
                        const ReportPage(),
                        const SettingsPage(),
                        const AboutPage(),
                      ],
                    ),
                  ),

                  // 3. Bottom Footer Bar
                  _buildAppFooter(context),
                ],
              ),

              // 4. Left navigation drawer overlay (hidden by default)
              if (_isNavMenuOpen || _isNavMenuClosing) ...[
                // Translucent scrim over the whole application; a tap
                // outside the drawer closes it. It unmounts the moment a
                // close begins so no invisible barrier can linger.
                if (_isNavMenuOpen)
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _navDrawerScrim,
                      child: GestureDetector(
                        key: const Key('nav_drawer_scrim'),
                        behavior: HitTestBehavior.translucent,
                        onTap: _closeNavMenu,
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ),
                // Full-height drawer sliding in from the left window edge.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 300,
                  child: SlideTransition(
                    position: _navDrawerSlide,
                    child: _buildNavDrawer(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Top Application Header (Live Date/Time, User Profile)
  Widget _buildAppHeader(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(_currentTime);
    final timeStr = DateFormat('hh:mm:ss a').format(_currentTime);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          // Left: Navigation menu toggle + application branding.
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: Tooltip(
              message: _isNavMenuOpen
                  ? 'Close navigation menu'
                  : 'Open navigation menu',
              child: InkWell(
                key: const Key('nav_menu_toggle'),
                onTap: _toggleNavMenu,
                hoverColor: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isNavMenuOpen
                        ? const Color(0xFFEFF6FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isNavMenuOpen
                          ? const Color(0xFF0D53FC)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isNavMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                    size: 26,
                    color: _isNavMenuOpen
                        ? const Color(0xFF0D53FC)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Application name + subtitle (logo image intentionally omitted).
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'VIYAN ',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextSpan(
                      text: 'WEIGHBRIDGE',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Color(0xFF0284C7),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Accurate Weighing  Reliable Business',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right: Live Date
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Live Clock
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 19,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // User Profile Pill
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final username = state.user?.username ?? 'Admin';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 18,
                      color: Color(0xFF1E293B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      username,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 2. Left navigation drawer (Gmail-style sliding panel).
  ///
  /// Hidden by default and opened with the header toggle. It reuses
  /// [_selectNavTab] and [_confirmLogout], so navigation, the admin password
  /// gate, and the exit confirmation behave exactly as before.
  Widget _buildNavDrawer(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _closeNavMenu();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Material(
        key: const Key('nav_drawer'),
        color: Colors.white,
        elevation: 16,
        shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.35),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            border: Border(
              right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    const ViyanWeighbridgeLogo(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'VIYAN ',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: Color(0xFF0F172A),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                TextSpan(
                                  text: 'WEIGHBRIDGE',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: Color(0xFF0284C7),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Accurate Weighing  Reliable Business',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Divider(height: 1, color: Color(0xFFE2E8F0)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDrawerMenuItem(
                        icon: Icons.scale_rounded,
                        label: 'Weighment',
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onDrawerMenuSelected(0),
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Reports',
                        isSelected: _selectedIndex == 1,
                        onTap: () => _onDrawerMenuSelected(1),
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        isSelected: _selectedIndex == 2,
                        onTap: () => _onDrawerMenuSelected(2),
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                        isSelected: _selectedIndex == 3,
                        onTap: () => _onDrawerMenuSelected(3),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ),
                      _buildDrawerMenuItem(
                        icon: Icons.power_settings_new_rounded,
                        label: 'Exit',
                        isDestructive: true,
                        onTap: () {
                          _closeNavMenu();
                          _confirmLogout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: _buildDrawerContactCard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(
                Icons.support_agent_rounded,
                size: 15,
                color: Color(0xFF0F52BA),
              ),
              SizedBox(width: 6),
              Text(
                'Contact ViyanInfo',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDrawerContactRow(
            icon: Icons.phone_outlined,
            value: '+91 6379723465',
            onTap: () => _copyContactValue('+91 6379723465'),
          ),
          _buildDrawerContactRow(
            icon: Icons.email_outlined,
            value: 'viyanninfo@gmail.com',
            onTap: () => _copyContactValue('viyanninfo@gmail.com'),
          ),
          _buildDrawerContactRow(
            icon: Icons.email_outlined,
            value: 'rithiknathan@gmail.com',
            onTap: () => _copyContactValue('rithiknathan@gmail.com'),
          ),
          _buildDrawerContactRow(
            icon: Icons.language_outlined,
            value: 'www.viyaninfo.com',
            onTap: _openWebsite,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerContactRow({
    required IconData icon,
    required String value,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F52BA)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 12, color: const Color(0xFF94A3B8)),
        ],
      ),
    );

    if (onTap == null) return rowContent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: rowContent,
      ),
    );
  }

  Future<void> _copyContactValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$value copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openWebsite() async {
    const formattedUrl = 'https://www.viyaninfo.com';
    bool launched = false;

    if (kIsWeb || !Platform.isWindows) {
      try {
        final uri = Uri.parse(formattedUrl);
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    } else {
      try {
        final result = await Process.run('rundll32', [
          'url.dll,FileProtocolHandler',
          formattedUrl,
        ]);
        launched = result.exitCode == 0;
      } catch (_) {}
    }

    if (!launched && mounted) {
      _copyContactValue('www.viyaninfo.com');
    }
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final Color iconColor;
    final Color textColor;
    final Color background;
    if (isDestructive) {
      iconColor = const Color(0xFFDC2626);
      textColor = const Color(0xFFDC2626);
      background = Colors.transparent;
    } else if (isSelected) {
      iconColor = const Color(0xFF0D53FC);
      textColor = const Color(0xFF0D53FC);
      background = const Color(0xFFEFF6FF);
    } else {
      iconColor = const Color(0xFF475569);
      textColor = const Color(0xFF1E293B);
      background = Colors.transparent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          hoverColor: isDestructive
              ? const Color(0xFFFEF2F2)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleNavMenu() {
    if (_isNavMenuOpen) {
      _closeNavMenu();
    } else {
      setState(() {
        _isNavMenuOpen = true;
        _isNavMenuClosing = false;
      });
      _navDrawerController.forward();
    }
  }

  void _closeNavMenu() {
    if (!_isNavMenuOpen) return;
    // Drop the open flag (and its scrim) immediately, then slide the panel
    // out and unmount it on completion so the closing animation stays
    // visible instead of the drawer vanishing instantly.
    setState(() {
      _isNavMenuOpen = false;
      _isNavMenuClosing = true;
    });
    _navDrawerController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _isNavMenuClosing = false);
      // Hand keyboard focus back to the weighment form when it is visible
      // so function-key workflows keep working after the drawer closes.
      if (_selectedIndex == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _billPageKey.currentState?.requestFocus();
        });
      }
    });
  }

  Future<void> _onDrawerMenuSelected(int index) async {
    _closeNavMenu();
    await _selectNavTab(index);
  }

  Future<void> _selectNavTab(int index) async {
    if (index == _selectedIndex) return;

    if (index != 0) {
      final authenticated = await showAdminPasswordDialog(context);
      if (!authenticated || !mounted) return;
    }

    setState(() => _selectedIndex = index);
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _billPageKey.currentState?.requestFocus();
      });
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 10),
            Text(
              'Exit Application',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out and exit your session?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final authBloc = context.read<AuthBloc>();
              authBloc.add(const LogoutRequested());
              await authBloc.stream.firstWhere(
                (state) => state.status == AuthStatus.unauthenticated,
              );
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Exit',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Bottom Application Footer
  Widget _buildAppFooter(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 15,
                color: Color(0xFF0284C7),
              ),
              SizedBox(width: 8),
              Text(
                'Viyan Weighbridge',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => setState(() => _selectedIndex = 3),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: const Text(
                'v0.0.1',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
