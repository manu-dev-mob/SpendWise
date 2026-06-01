import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:expense_web/core/theme/theme_provider.dart';
import 'package:expense_web/core/theme/app_theme.dart';

class WebScaffold extends StatefulWidget {
  final Widget body;
  final String title;

  const WebScaffold({super.key, required this.body, required this.title});

  @override
  State<WebScaffold> createState() => _WebScaffoldState();
}

class _WebScaffoldState extends State<WebScaffold> {
  bool _sidebarOpen = false;
  User? user;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    photoUrl = user?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1000;
    final bool displaySidebar = isDesktop || _sidebarOpen;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: isDesktop
            ? null
            : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _sidebarOpen = !_sidebarOpen;
            });
          },
        ),
        title: Row(
          children: [
            if (isDesktop) ...[
              // Premium Logo
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'SpendWise',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 48),
            ],
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                    child: photoUrl == null
                        ? Text(
                      (user!.displayName != null && user!.displayName!.isNotEmpty)
                          ? user!.displayName![0].toUpperCase()
                          : user!.email![0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user!.displayName ?? user!.email ?? 'User',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    tooltip: 'Log out',
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      body: Row(
        children: [
          if (displaySidebar)
            _Sidebar(
              currentPath: GoRouterState.of(context).uri.toString(),
              isDesktop: isDesktop,
              onNavigate: () {
                if (!isDesktop) {
                  setState(() {
                    _sidebarOpen = false;
                  });
                }
              },
            ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: widget.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentPath;
  final bool isDesktop;
  final VoidCallback onNavigate;

  const _Sidebar({
    required this.currentPath,
    required this.isDesktop,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  active: currentPath == '/dashboard' || currentPath == '/',
                  onTap: () {
                    context.go('/dashboard');
                    onNavigate();
                  },
                ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.category_rounded,
                  label: 'Categories',
                  active: currentPath == '/categories',
                  onTap: () {
                    context.go('/categories');
                    onNavigate();
                  },
                ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Expenses',
                  active: currentPath == '/expenses',
                  onTap: () {
                    context.go('/expenses');
                    onNavigate();
                  },
                ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.analytics_rounded,
                  label: 'Analytics',
                  active: currentPath == '/analytics',
                  onTap: () {
                    context.go('/analytics');
                    onNavigate();
                  },
                ),
                const SizedBox(height: 8),
                _NavItem(
                  icon: Icons.format_list_bulleted_rounded,
                  label: 'Ledger',
                  active: currentPath == '/ledger',
                  onTap: () {
                    context.go('/ledger');
                    onNavigate();
                  },
                ),
              ],
            ),
          ),

          // Theme Switcher & Bottom Section
          Divider(color: Theme.of(context).dividerColor, height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 20,
                      color: isDark ? Colors.indigoAccent : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppTheme.primaryDark,
                ),
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
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.12),
                theme.primaryColor.withOpacity(0.04),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            border: active
                ? Border(
              left: BorderSide(
                color: theme.primaryColor,
                width: 4,
              ),
            )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: active
                    ? theme.primaryColor
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  color: active
                      ? theme.primaryColor
                      : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
