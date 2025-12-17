// ============================================================================
// File: dashboard_screen.dart
// Description: Dashboard Screen for Post-Authentication
//
// Transformed from: DashboardScreen.tsx
// Displays user session information after successful MFA login
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rdna_client/rdna_struct.dart';

import '../components/drawer_content.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final RDNAUserLoggedIn? eventData;

  const DashboardScreen({
    super.key,
    this.eventData,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _userId;
  String? _sessionId;
  int? _sessionType;
  String? _loginTime;

  @override
  void initState() {
    super.initState();
    _processEventData();
  }

  void _processEventData() {
    if (widget.eventData == null) return;

    final data = widget.eventData!;
    setState(() {
      _userId = data.userId;
      _sessionId = data.challengeResponse?.session?.sessionId;
      _sessionType = data.challengeResponse?.session?.sessionType;
      _loginTime = DateTime.now().toLocal().toString().substring(0, 19);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  '☰',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF3498db),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: DrawerContent(
        sessionData: widget.eventData,
        currentRoute: 'dashboardScreen',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3498db), Color(0xFF2980b9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Successfully Authenticated!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome, ${_userId ?? "User"}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Session Information Card
              _buildInfoCard(
                title: 'Session Information',
                items: [
                  _buildInfoRow('User ID', _userId ?? 'N/A'),
                  _buildInfoRow('Session ID', _sessionId ?? 'N/A'),
                  _buildInfoRow(
                      'Session Type', _sessionType?.toString() ?? 'N/A'),
                  _buildInfoRow('Login Time', _loginTime ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 24),

              // Success Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf0f8f0),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xFF27ae60),
                      width: 4,
                    ),
                  ),
                ),
                child: const Text(
                  'You have successfully completed the MFA authentication flow!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF27ae60),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          const Divider(height: 24),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7f8c8d),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
