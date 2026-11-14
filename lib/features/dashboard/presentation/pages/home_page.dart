import 'dart:async';
import 'dart:io' show Platform, Process;
import 'dart:ui' show AppExitResponse, AppExitType;

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
import '../../../material/presentation/widgets/material_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/hardware/scale/domain/scale_service.dart';
import '../../../report/presentation/pages/report_page.dart';
import '../../../auth/presentation/widgets/truck_logo.dart';
import '../../../../core/presentation/widgets/admin_password_dialog.dart';
import 'about_page.dart';

part 'home_page_header.dart';
part 'home_page_drawer.dart';
part 'home_page_navigation.dart';
part 'home_page_footer.dart';

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
  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onExitRequested: () async {
        if (!mounted) return AppExitResponse.exit;
        await context.read<ScaleService>().stop();
        if (!mounted) return AppExitResponse.exit;
        await context.read<db.AppDatabase>().close();
        return AppExitResponse.exit;
      },
    );
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

  /// Allows part-file extension methods to schedule state updates without
  /// needing subclass access to the protected [setState].
  void runSetState(VoidCallback fn) => setState(fn);

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    HardwareKeyboard.instance.removeHandler(_handleAppKeyEvent);
    _navDrawerController.dispose();
    _clockTimer.cancel();
    _appShortcutsFocusNode.dispose();
    super.dispose();
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
                          onNavigateToReports: () => _selectNavTab(1),
                          onNavigateToMaterials: () => _selectNavTab(2),
                        ),
                        // Refreshes its report when this flag turns true,
                        // because the IndexedStack keeps it alive across tab
                        // switches and its initState never runs again.
                        ReportPage(isActive: _selectedIndex == 1),
                        // The materials master is only built while its own tab
                        // is selected, so the rest of the shell never needs a
                        // MaterialBloc. The slot itself always stays in the
                        // list so the indices below it cannot shift.
                        _selectedIndex == 2
                            ? const MaterialListPage()
                            : const SizedBox.shrink(),
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
}
