part of 'home_page.dart';

extension _HomePageDrawer on _HomePageState {
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
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            border: Border(
              right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompactHeight = constraints.maxHeight < 580;

              final menuItems = [
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
                  icon: Icons.category_rounded,
                  label: 'Materials',
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onDrawerMenuSelected(2),
                ),
                _buildDrawerMenuItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onDrawerMenuSelected(3),
                ),
                _buildDrawerMenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onDrawerMenuSelected(4),
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
                    _exitApplication();
                  },
                ),
              ];

              final contactCardWidget = Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                child: _buildDrawerContactCard(context),
              );

              return Column(
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
                                text: const TextSpan(
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
                              const SizedBox(height: 2),
                              const Text(
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
                  if (isCompactHeight)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [...menuItems, contactCardWidget],
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: menuItems),
                      ),
                    ),
                    contactCardWidget,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 18,
                  color: Color(0xFF0F52BA),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Contact ViyanInfo',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Support and enquiries',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),
          _buildDrawerContactRow(
            icon: Icons.person_rounded,
            value: 'Rithick Nathan',
            isHighlight: true,
            tooltip: 'Copy contact name',
            onTap: () => _copyContactValue('Rithick Nathan'),
          ),
          const SizedBox(height: 2),
          _buildDrawerContactRow(
            icon: Icons.phone_outlined,
            value: '+91 6379723465',
            tooltip: 'Copy phone number',
            onTap: () => _copyContactValue('+91 6379723465'),
          ),
          const SizedBox(height: 2),
          _buildDrawerContactRow(
            icon: Icons.email_outlined,
            value: 'viyaninfo@gmail.com',
            tooltip: 'Copy email address',
            onTap: () => _copyContactValue('viyaninfo@gmail.com'),
          ),
          const SizedBox(height: 2),
          _buildDrawerContactRow(
            icon: Icons.email_outlined,
            value: 'rithicknathan@gmail.com',
            tooltip: 'Copy support email',
            onTap: () => _copyContactValue('rithicknathan@gmail.com'),
          ),
          const SizedBox(height: 2),
          _buildDrawerContactRow(
            icon: Icons.language_outlined,
            value: 'www.viyaninfo.com',
            isLink: true,
            trailingIcon: Icons.open_in_new_rounded,
            tooltip: 'Visit website',
            onTap: _openWebsite,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerContactRow({
    required IconData icon,
    required String value,
    bool isHighlight = false,
    bool isLink = false,
    VoidCallback? onTap,
    IconData? trailingIcon,
    String? tooltip,
  }) {
    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: Row(
        children: [
          Icon(
            icon,
            size: isHighlight ? 16 : 15,
            color: const Color(0xFF0F52BA),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: isHighlight ? 12.8 : 12.0,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                color: isHighlight
                    ? const Color(0xFF0F172A)
                    : (isLink
                          ? const Color(0xFF0F52BA)
                          : const Color(0xFF1E293B)),
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: const Color(0xFF0F52BA),
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(
              trailingIcon,
              size: 13,
              color: isLink ? const Color(0xFF0F52BA) : const Color(0xFF94A3B8),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return rowContent;

    final interactive = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: const Color(0xFFEFF6FF),
        onTap: onTap,
        child: rowContent,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: interactive,
      );
    }
    return interactive;
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
}
