import 'package:flutter/material.dart';
import '../auth/auth_state.dart';
import 'dashboard_page.dart';
import 'contests_page.dart';
import 'lessons_page.dart';
import 'notifications_page.dart';

class ShellPage extends StatefulWidget {
  final AuthState auth;
  const ShellPage({super.key, required this.auth});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _kPrimary     = Color(0xFF2E7D32);
  static const _kSidebarBg   = Color(0xFF1B5E20);
  static const _kSidebarText = Colors.white70;

  static const _navItems = [
    (Icons.dashboard_rounded,     'Dashboard'),
    (Icons.emoji_events_rounded,  'Contests'),
    (Icons.school_rounded,        'Lessons'),
    (Icons.notifications_rounded, 'Notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 900;

    final pages = [
      const DashboardPage(),
      const ContestsAdminPage(),
      const LessonsAdminPage(),
      const NotificationsAdminPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      body: Row(
        children: [
          // ── Sidebar ─────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: compact ? 64 : 220,
            color: _kSidebarBg,
            child: Column(
              children: [
                // Logo
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: compact ? Alignment.center : Alignment.centerLeft,
                  child: compact
                      ? const Text('🌱', style: TextStyle(fontSize: 28))
                      : const Row(
                          children: [
                            Text('🌱', style: TextStyle(fontSize: 22)),
                            SizedBox(width: 10),
                            Text('Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                ),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 8),
                // Nav items
                ...List.generate(_navItems.length, (i) {
                  final item    = _navItems[i];
                  final selected = i == _index;
                  return _NavItem(
                    icon:     item.$1,
                    label:    item.$2,
                    selected: selected,
                    compact:  compact,
                    onTap:    () => setState(() => _index = i),
                  );
                }),
                const Spacer(),
                const Divider(color: Colors.white12, height: 1),
                // Admin info
                if (!compact)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: _kPrimary,
                          child: Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.auth.adminEmail,
                            style: const TextStyle(
                                color: _kSidebarText, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Logout
                Tooltip(
                  message: 'Log out',
                  child: InkWell(
                    onTap: widget.auth.logout,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 16),
                      child: Row(
                        mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.white54, size: 20),
                          if (!compact) ...[
                            const SizedBox(width: 10),
                            const Text('Log out', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _navItems[_index].$2,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: _kPrimary, size: 8),
                            SizedBox(width: 6),
                            Text('Live data',
                                style: TextStyle(
                                    color: _kPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: pages[_index]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: compact ? label : '',
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2E7D32) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              SizedBox(
                width: compact ? 0 : 16,
              ),
              Icon(icon,
                  color: selected ? Colors.white : Colors.white54,
                  size: 20),
              if (!compact) ...[
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
