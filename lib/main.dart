import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safety wrapper to run the UI preview without real backend keys
  try {
    await Supabase.initialize(
      url: 'https://wgepkwkrsqmlwciadcuv.supabase.co', 
      anonKey: 'sb_publishable_HEeaKxDwmcyeARxRpNOOjA_3lOAsKC2',                   
    );
  } catch (e) {
    debugPrint('Supabase configuration notice: Keys not configured yet. Running in UI preview mode.');
  }

  runApp(const OmniDriveApp());
}

class OmniDriveApp extends StatelessWidget {
  const OmniDriveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniDrive AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0B0D10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff00F2FE), 
          surface: Color(0xff14171C),
        ),
      ),
      home: const LoginScreenPreview(),
    );
  }
}

class LoginScreenPreview extends StatefulWidget {
  const LoginScreenPreview({Key? key}) : super(key: key);

  @override
  State<LoginScreenPreview> createState() => _LoginScreenPreviewState();
}

class _LoginScreenPreviewState extends State<LoginScreenPreview> {
  int selectedRoleIndex = 0; 
  final List<String> roles = ['CUSTOMER', 'VENDOR', 'RIDER'];
  final List<Color> roleAccents = [
    const Color(0xff00F2FE), 
    const Color(0xffFF5A00), 
    const Color(0xff3B82F6), 
  ];

  @override
  Widget build(BuildContext context) {
    Color currentAccent = roleAccents[selectedRoleIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background Radial Glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.8),
                radius: 1.3,
                colors: [
                  currentAccent.withOpacity(0.12),
                  const Color(0xff0B0D10),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xff14171C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: currentAccent.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: currentAccent, size: 32),
                        const SizedBox(width: 8),
                        const Text(
                          'OMNIDRIVE AI',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900, // FIXED: Changed from .black to .w900
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Next-Gen Automotive Marketplace Workspace',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'SELECT YOUR PORTAL FRAME',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xff0B0D10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: List.generate(roles.length, (index) {
                          bool isSelected = selectedRoleIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRoleIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? roleAccents[index].withOpacity(0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? roleAccents[index] : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    roles[index],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? roleAccents[index] : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildField(label: 'EMAIL ADDRESS', hint: 'driver@omnidrive.ai', icon: Icons.email_outlined),
                    const SizedBox(height: 20),
                    _buildField(label: 'SECURE PASSWORD', hint: '••••••••', icon: Icons.lock_outline, obscure: true),
                    
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: Text(
                          'ENTER ${roles[selectedRoleIndex]} SYSTEM',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String hint, required IconData icon, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey, size: 18),
            filled: true,
            fillColor: const Color(0xff0B0D10),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
          ),
        ),
      ],
    );
  }
}