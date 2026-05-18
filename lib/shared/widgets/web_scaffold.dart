import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        actions: [
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl!)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            user!.displayName != null
                                ? user!.displayName![0]
                                : user!.email![0],
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user!.displayName ?? user!.email ?? 'User',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _sidebarOpen = !_sidebarOpen;
            });
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Row(
        children: [
          if (_sidebarOpen)
            _Sidebar(
              onNavigate: () {
                setState(() {
                  _sidebarOpen = false;
                });
              },
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final VoidCallback onNavigate;
  const _Sidebar({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Column(
        children: [
          SizedBox(height: 24),
          _NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              context.go('/');
              onNavigate();
            },
          ),
          _NavItem(
            icon: Icons.category,
            label: 'Categories',
            onTap: () {
              context.go('/categories');
              onNavigate();
            },
          ),
          _NavItem(
            icon: Icons.receipt_long,
            label: 'Expenses',
            onTap: () {
              context.go('/expenses');
              onNavigate();
            },
          ),
          _NavItem(
            icon: Icons.analytics,
            label: 'Analytics',
            onTap: () {
              context.go('/analytics');
              onNavigate();
            },
          ),
          _NavItem(
            icon: Icons.list,
            label: 'Ledger',
            onTap: () {
              context.go('/ledger');
              onNavigate();
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label),
      onTap: onTap,
    );
  }
}
