import 'package:flutter/material.dart';

import 'change_admin_password_dialog.dart';
import 'settings_form_field.dart';

/// Card for managing the Administrator Password and reviewing protected areas.
class AdminPasswordCard extends StatelessWidget {
  const AdminPasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.admin_panel_settings_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF0D3B82),
      title: 'Administrator Password',
      subtitle:
          'Manage administrative security credentials and access restrictions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Main Security Status Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 620;

                final statusInfo = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFBBF7D0),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF16A34A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'System Access Protected',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF86EFAC),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF16A34A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF15803D),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Administrative password secures master data, audit reports, financial summaries, and system configuration from unauthorized access.',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final changePasswordButton = FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final changed = await showChangeAdminPasswordDialog(
                      context,
                    );
                    if (changed && context.mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Administrator password changed successfully.',
                              ),
                            ],
                          ),
                          backgroundColor: Color(0xFF16A34A),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_reset_rounded, size: 18),
                  label: const Text('Change Password'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B82),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      statusInfo,
                      const SizedBox(height: 14),
                      changePasswordButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: statusInfo),
                    const SizedBox(width: 16),
                    changePasswordButton,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Protected Modules Overview ──
          Row(
            children: [
              const Icon(
                Icons.security_rounded,
                size: 14,
                color: Color(0xFF0D3B82),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Modules Protected by Administrator Password',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoCols = constraints.maxWidth > 520;
              final items = [
                const _ProtectedItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Customers Directory',
                  subtitle: 'Creating, editing, or removing customer accounts',
                ),
                const _ProtectedItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Materials Catalog',
                  subtitle:
                      'Altering materials, units, and base classifications',
                ),
                const _ProtectedItem(
                  icon: Icons.bar_chart_rounded,
                  title: 'Reports & Export',
                  subtitle: 'Viewing weighment records, slips, and exports',
                ),
                const _ProtectedItem(
                  icon: Icons.tune_rounded,
                  title: 'Scale & Configuration',
                  subtitle: 'Modifying scale settings and bill prefixes',
                ),
              ];

              if (!isTwoCols) {
                return Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      items[i],
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: items[0]),
                      const SizedBox(width: 10),
                      Expanded(child: items[1]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: items[2]),
                      const SizedBox(width: 10),
                      Expanded(child: items[3]),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // ── Security Tip Callout ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF1D4ED8),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Default administrator password upon first installation is "123". Ensure you set a unique password.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      color: Color(0xFF1E40AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectedItem extends StatelessWidget {
  const _ProtectedItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF0D3B82)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
