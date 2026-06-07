import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart';

void main() async {
  // Ensure the framework is fully booted before executing logic
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your live cloud database connection
  await Supabase.initialize(
    url: 'https://wgepkwkrsqmlwciadcuv.supabase.co', 
    anonKey: 'sb_publishable_HEeaKxDwmcyeARxRpNOOjA_3lOAsKC2', // Your live verified public key
  );

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
      routes: {
        '/login': (context) => const LoginScreenPreview(),
      },
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
  bool isSignUp = false; 
  bool isLoading = false; 

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> roles = ['CUSTOMER', 'VENDOR', 'RIDER'];
  final List<Color> roleAccents = [
    const Color(0xff00F2FE), 
    const Color(0xffFF5A00), 
    const Color(0xff3B82F6), 
  ];

  Future<void> handleAuthentication() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorDialog('Please fill in all text input fields.');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isSignUp) {
        // 1. Create a brand new account inside your Supabase Auth Cloud
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        // 2. Insert their custom role metadata into our profiles table
        if (res.user != null) {
          await Supabase.instance.client.from('profiles').insert({
            'id': res.user!.id, 
            'role': roles[selectedRoleIndex], 
          });
        }

        showSuccessSnackbar('Account created successfully! Proceeding to Login.');
        setState(() => isSignUp = false); 
      } else {
        // 1. Authenticate the credentials
        final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (res.user != null) {
          // 2. Fetch the true assigned role from the database profiles table
          final data = await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', res.user!.id)
              .single();

          final String trueRole = data['role'] ?? 'CUSTOMER';
          final String selectedRole = roles[selectedRoleIndex];

          // 3. Role Validation Gatekeeper
          if (trueRole != selectedRole) {
            await Supabase.instance.client.auth.signOut();
            showErrorDialog('Access Denied. Your profile is registered as a $trueRole, not a $selectedRole.');
            return;
          }

          showSuccessSnackbar('Access Granted! Logging into system profile.');

          // 4. Navigate on success
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  portalRole: trueRole,
                  themeAccent: roleAccents[selectedRoleIndex],
                ),
              ),
            );
          }
        }
      }
    } on AuthException catch (error) {
      showErrorDialog(error.message);
    } catch (error) {
      showErrorDialog('An unexpected network error occurred.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff14171C),
        title: const Text('Authentication Error', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xff00F2FE))),
          )
        ],
      ),
    );
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: roleAccents[selectedRoleIndex],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color currentAccent = roleAccents[selectedRoleIndex];

    return Scaffold(
      body: Stack(
        children: [
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
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSignUp ? 'Create your ecosystem access account' : 'Next-Gen Automotive Marketplace Workspace',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    if (!isSignUp) ...[
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
                    ],

                    _buildField(
                      label: 'EMAIL ADDRESS', 
                      hint: 'driver@omnidrive.ai', 
                      icon: Icons.email_outlined,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'SECURE PASSWORD', 
                      hint: '••••••••', 
                      icon: Icons.lock_outline, 
                      obscure: true,
                      controller: _passwordController,
                    ),
                    
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
                        onPressed: isLoading ? null : handleAuthentication,
                        child: isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text(
                              isSignUp ? 'CREATE ACCOUNT' : 'ENTER ${roles[selectedRoleIndex]} SYSTEM',
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isSignUp = !isSignUp;
                          });
                        },
                        child: Text(
                          isSignUp ? 'Already have an account? Login' : "Don't have an account? Register Here",
                          style: TextStyle(color: currentAccent, fontSize: 13),
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

  Widget _buildField({
    required String label, 
    required String hint, 
    required IconData icon, 
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, 
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