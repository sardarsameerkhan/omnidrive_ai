import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatelessWidget {
  final String portalRole;
  final Color themeAccent;

  const DashboardScreen({
    Key? key,
    required this.portalRole,
    required this.themeAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely retrieve the current authenticated session details from Supabase
    final User? user = Supabase.instance.client.auth.currentUser;
    final String userEmail = user?.email ?? 'anonymous@omnidrive.ai';

    return Scaffold(
      body: Row(
        children: [
          // 1. Sleek Workspace Navigation Sidebar
          Container(
            width: 260,
            color: const Color(0xff14171C),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, color: themeAccent, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'OMNIDRIVE AI',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: themeAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    portalRole,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeAccent, letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                // Profile Session Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff0B0D10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: themeAccent.withOpacity(0.2),
                        child: Icon(Icons.person, color: themeAccent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          userEmail,
                          style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Sign Out Operational Command Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.white10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('DISCONNECT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Core Main Feed Canvas Area
          Expanded(
            child: Container(
              color: const Color(0xff0B0D10),
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPERATIONAL LIVE STREAM FEED',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeAccent, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to the Next-Gen Workspace Grid',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  // Placeholder Metrics Cards Layout Row
                  Row(
                    children: [
                      _buildMetricCard('Ecosystem Status', 'Operational', Icons.analytics_outlined),
                      const SizedBox(width: 24),
                    _buildMetricCard('Active Transits', '0 Units Running', Icons.local_shipping_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xff14171C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}