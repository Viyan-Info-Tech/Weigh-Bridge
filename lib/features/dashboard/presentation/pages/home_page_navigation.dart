part of 'home_page.dart';

extension _HomePageNavigation on _HomePageState {
  bool _handleAppKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_isNavMenuOpen && event.logicalKey == LogicalKeyboardKey.escape) {
      _closeNavMenu();
      return true;
    }
    return false;
  }

  void _toggleNavMenu() {
    if (_isNavMenuOpen) {
      _closeNavMenu();
    } else {
      runSetState(() {
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
    runSetState(() {
      _isNavMenuOpen = false;
      _isNavMenuClosing = true;
    });
    _navDrawerController.reverse().then((_) {
      if (!mounted) return;
      runSetState(() => _isNavMenuClosing = false);
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

    // Tabs that expose configuration or business data stay password-gated.
    // About (4) is informational and opens directly; Weighment (0) is the
    // default operator workspace.
    const protectedTabs = {1, 2, 3}; // Reports, Materials, Settings.
    if (protectedTabs.contains(index)) {
      final authenticated = await showAdminPasswordDialog(context);
      if (!authenticated || !mounted) return;
    }

    runSetState(() => _selectedIndex = index);
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
}
