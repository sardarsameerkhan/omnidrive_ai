import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final String portalRole;
  final Color themeAccent;

  const DashboardScreen({
    Key? key,
    required this.portalRole,
    required this.themeAccent,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentSubPageIndex = 0;

  // Safely grab current authenticated user data from Supabase
  final User? user = Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    final String userEmail = user?.email ?? 'developer@omnidrive.ai';

    // Generates the navigation array based on the validated database role
    List<NavigationItem> navItems = _getNavItemsForRole(widget.portalRole);

    // Safeguard index out of bounds on hot reload or role switches
    if (_currentSubPageIndex >= navItems.length) {
      _currentSubPageIndex = 0;
    }

    return Scaffold(
      body: Row(
        children: [
          // ================= SIDEBAR NAVIGATION MENU =================
          Container(
            width: 280,
            color: const Color(0xff14171C),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, color: widget.themeAccent, size: 28),
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
                    color: widget.themeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: widget.themeAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${widget.portalRole} PORTAL',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.themeAccent, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'WORKSPACE MODULES',
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                
                // Generated list navigation buttons
                Expanded(
                  child: ListView.builder(
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _currentSubPageIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          onTap: () => setState(() => _currentSubPageIndex = index),
                          leading: Icon(navItems[index].icon, color: isSelected ? widget.themeAccent : Colors.grey, size: 20),
                          title: Text(
                            navItems[index].title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tileColor: isSelected ? widget.themeAccent.withOpacity(0.08) : Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),

                // User identity profile panel footer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff0B0D10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.themeAccent.withOpacity(0.2),
                        child: Icon(Icons.person, color: widget.themeAccent, size: 20),
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
          
          // ================= MAIN VIEW SCREEN CONTEXT STREAM =================
          Expanded(
            child: Container(
              color: const Color(0xff0B0D10),
              child: navItems[_currentSubPageIndex].viewPage,
            ),
          ),
        ],
      ),
    );
  }

  // Core configuration mapping different pages based on user roles
  List<NavigationItem> _getNavItemsForRole(String role) {
    if (role == 'CUSTOMER') {
      return [
        NavigationItem('Car Part Scanner', Icons.center_focus_strong_outlined, _buildPlaceholderView('📸 Car Part AI Scanner Screen', 'Align components within scanner frame boundaries to identify parts instantly.')),
        NavigationItem('Performance Tracker', Icons.speed_outlined, _buildPlaceholderView('📈 Performance Telemetry Center', 'Track vehicle performance statistics, lap metrics, and diagnostic readings.')),
        NavigationItem('Modification Assistance', Icons.build_circle_outlined, _buildPlaceholderView('🔧 AI Modification Planner', 'Explore curated aftermarket upgrades compatible with your garage profile.')),
        NavigationItem('Marketplace Cart', Icons.shopping_cart_outlined, _buildPlaceholderView('🛒 Shopping Cart checkout stream', 'Review your selected modifications and complete checkout workflows.')),
        NavigationItem('Order History Details', Icons.receipt_long_outlined, _buildPlaceholderView('📦 Order Tracking & Receipts', 'Monitor delivery states and historical item shipments.')),
        NavigationItem('Profile & Garage', Icons.badge_outlined, _buildPlaceholderView('👤 Customer Garage & Profile', 'Manage active vehicles, payment streams, and address coordinates.')),
      ];
    } else if (role == 'VENDOR') {
      return [
        NavigationItem('Manage Inventory', Icons.inventory_2_outlined, _buildPlaceholderView('🏪 Product Catalog Controller', 'List new components, modify stock metrics, and customize item pricing.')),
        NavigationItem('Incoming Store Orders', Icons.assignment_outlined, _buildPlaceholderView('📋 Order Fullfilment Queue', 'Accept customer checkout requests and package parts for driver collection.')),
        NavigationItem('Merchant Profile', Icons.storefront_outlined, _buildPlaceholderView('🏢 Store Settings & Analytics', 'Configure vendor location arrays, business details, and tracking graphs.')),
      ];
    } else if (role == 'RIDER') {
      return [
        NavigationItem('Confirm Active Orders', Icons.local_mall_outlined, _buildPlaceholderView('🏁 Delivery Broadcast Feed', 'Browse available delivery requests nearby and claim assignment rows.')),
        NavigationItem('Pickup & Delivery Nav', Icons.navigation_outlined, _buildPlaceholderView('📍 Navigation & Delivery Steps', 'Access waypoint addresses for vendor part collection and customer drops.')),
        NavigationItem('Update Status Tracking', Icons.published_with_changes_outlined, _buildPlaceholderView('⚡ Live Shipment Status Modifier', 'Transition parcel milestones from Accepted ➔ Collected ➔ Completed.')),
      ];
    } else { 
      // ADMIN PORTAL SPECIFIC MANAGEMENT SCREENS
      return [
        NavigationItem('Global Overview', Icons.analytics_outlined, _buildAdminOverviewScreen()),
        NavigationItem('Approve Applications', Icons.verified_user_outlined, _buildAdminApprovalScreen()),
        NavigationItem('Dispute & Support Desk', Icons.gavel_outlined, _buildAdminDisputeScreen()),
      ];
    }
  }

  // ================= ADMIN VIEW WIDGET LAYOUTS =================

  // 1. GLOBAL SYSTEM METRICS CONTROL PANEL
  Widget _buildAdminOverviewScreen() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SYSTEM COMMAND DASHBOARD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Real-time ecosystem metrics and global system configurations.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 32),
          
          // Analytical status block metrics rows
          Row(
            children: [
              _buildAdminStatCard('TOTAL ACTIVE USERS', '1,248 Users', Icons.people, widget.themeAccent),
              const SizedBox(width: 20),
              _buildAdminStatCard('PENDING VALIDATIONS', '7 Stores / 4 Drivers', Icons.pending_actions, Colors.amberAccent),
              const SizedBox(width: 20),
              _buildAdminStatCard('COMMERCE VOLUME', '\$42,850.00', Icons.monetization_on, Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 40),
          
          const Text('GLOBAL SYSTEM SETTINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff14171C), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
            child: Row(
              children: [
                Icon(Icons.percent, color: widget.themeAccent, size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ecosystem Commission Fee Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Platform cuts automatically applied to incoming Vendor sales streams.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 46,
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '10%',
                      filled: true,
                      fillColor: const Color(0xff0B0D10),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: widget.themeAccent)),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 2. MERCHANT & DRIVER ONBOARDING VERIFICATION DECK
  Widget _buildAdminApprovalScreen() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MERCHANT & DRIVER KYC APPROVALS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Verify business registrations and driver security credentials before authorization onboarding.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 32),
          
          const Text('PENDING APPLICATIONS QUEUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 16),
          
          _buildApprovalRow('Apex Performance Auto Parts Co.', 'vendor@apexparts.com', 'VENDOR'),
          const SizedBox(height: 12),
          _buildApprovalRow('Marcus Vance (Rapid Rider Logistics)', 'marcus.vance@omnidrive.ai', 'RIDER'),
        ],
      ),
    );
  }

  // 3. GLOBAL ESCALATION RESOLUTION PANEL
  Widget _buildAdminDisputeScreen() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GLOBAL ECOSYSTEM ARBITRATION ROOM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Audit dispatch records, track shipping milestones, and settle customer chargeback conflicts.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 32),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff14171C), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
                    SizedBox(width: 10),
                    Text('CRITICAL ESCALATION: Case #OD-99214', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Customer Complaint: "The complete turbocharger kit item arrived without the turbine housing adapter assembly included."', style: TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 10),
                const Text('Vendor Merchant Counter: "Package item was sealed at warehouse station; verified weight scales passed layout shipping thresholds."', style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Text('FORCE CUSTOMER REFUND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Text('DISMISS CONFLICT CASE', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= ADMIN REUSABLE UI BUILDERS =================
  
  Widget _buildAdminStatCard(String title, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xff14171C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: col.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: col, size: 24),
            ),
            const SizedBox(height: 20),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRow(String name, String email, String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff14171C), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: type == 'VENDOR' ? const Color(0xffFF5A00).withOpacity(0.1) : const Color(0xff3B82F6).withOpacity(0.1),
            child: Icon(
              type == 'VENDOR' ? Icons.storefront_outlined : Icons.motorcycle_outlined, 
              color: type == 'VENDOR' ? const Color(0xffFF5A00) : const Color(0xff3B82F6), 
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff10B981), // Fixed Premium Emerald Green Hex Literal
              foregroundColor: Colors.black,             // High contrast dark text
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed: () {},
            child: const Text('AUTHORIZE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent, 
              side: const BorderSide(color: Colors.white10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onPressed: () {},
            child: const Text('DENY', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ================= GENERAL PLACEHOLDER ROW WIDGET =================
  Widget _buildPlaceholderView(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.themeAccent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.layers_outlined, color: widget.themeAccent, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 40),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff14171C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Center(
              child: Text(
                'UI DESIGN STRATUM FOR: $title',
                style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Simple layout tracking dataset model blueprint
class NavigationItem {
  final String title;
  final IconData icon;
  final Widget viewPage;

  NavigationItem(this.title, this.icon, this.viewPage);
}