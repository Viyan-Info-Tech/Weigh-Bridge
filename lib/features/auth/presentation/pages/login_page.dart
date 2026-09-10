import 'package:flutter/material.dart';

import '../widgets/auth_branding_panel.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop / Widescreen: Side-by-side split screen
          if (constraints.maxWidth >= 900) {
            return Row(
              children: [
                // Left 58%: Branding Panel
                const Expanded(flex: 58, child: AuthBrandingPanel()),

                // Right 42%: Login Form Panel
                Expanded(
                  flex: 42,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: const LoginForm(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Compact / Small Window View: Graceful single-column layout
          return Container(
            color: const Color(0xFFF8FAFC),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: const LoginForm(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
