part of 'home_page.dart';

extension _HomePageHeader on _HomePageState {
  Widget _buildAppHeader(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(_currentTime);
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);

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
}
