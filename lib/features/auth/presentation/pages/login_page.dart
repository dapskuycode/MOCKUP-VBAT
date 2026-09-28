import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Definisi Warna Khas VBat
  final Color _vbatBlue = const Color(0xFF1B4F9B);
  final Color _bgGray = const Color(0xFFF8FAFC);
  final Color _textDark = const Color(0xFF111111);
  final Color _textGray = const Color(0xFF717784);
  final Color _inputBg = const Color(0xFFF1F5F9);

  // State Variables
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  void _applyDemographicPresets(String email) {
    if (email == 'andi@teknisi.id') {
      SessionManager.userName = 'Andi Teknisi';
      SessionManager.birthDate = DateTime(2004, 3, 15);
      SessionManager.gender = 'Laki-laki';
      SessionManager.city = 'Jakarta Pusat';
      SessionManager.province = 'DKI Jakarta';
    } else if (email == 'rian@repair.id') {
      SessionManager.userName = 'Rian Repair';
      SessionManager.birthDate = DateTime(2000, 7, 22);
      SessionManager.gender = 'Laki-laki';
      SessionManager.city = 'Bandung';
      SessionManager.province = 'Jawa Barat';
    } else if (email == 'siti@service.id') {
      SessionManager.userName = 'Siti Solder';
      SessionManager.birthDate = DateTime(1998, 11, 5);
      SessionManager.gender = 'Perempuan';
      SessionManager.city = 'Surabaya';
      SessionManager.province = 'Jawa Timur';
    } else if (email == 'budi@vbatponsel.com') {
      SessionManager.userName = 'Budi Hardware';
      SessionManager.birthDate = DateTime(1993, 1, 30);
      SessionManager.gender = 'Laki-laki';
      SessionManager.city = 'Jakarta Selatan';
      SessionManager.province = 'DKI Jakarta';
    } else if (email == 'dewi@flash.id') {
      SessionManager.userName = 'Dewi Flasher';
      SessionManager.birthDate = DateTime(1988, 9, 18);
      SessionManager.gender = 'Perempuan';
      SessionManager.city = 'Bandung';
      SessionManager.province = 'Jawa Barat';
    } else if (email == 'hendra@master.id') {
      SessionManager.userName = 'Hendra Master';
      SessionManager.birthDate = DateTime(1982, 12, 10);
      SessionManager.gender = 'Laki-laki';
      SessionManager.city = 'Aceh Selatan';
      SessionManager.province = 'Aceh';
    } else if (_emailController.text.trim().isNotEmpty) {
      final rawName = _emailController.text.split('@').first;
      SessionManager.userName = rawName[0].toUpperCase() + rawName.substring(1);
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    // 1. Panggil REST API Laravel backend (POST /api/v1/auth/login)
    final result = await SessionManager.loginWithApi(email, password);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selamat datang kembali, ${result['name']}!"),
          backgroundColor: const Color(0xFF1B4F9B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/main');
    } else {
      // 2. Fallback offline untuk akun sampel jika server tidak terjangkau
      final lowerEmail = email.toLowerCase();
      final bool isDemoAccount = [
        'andi@teknisi.id',
        'rian@repair.id',
        'siti@service.id',
        'budi@vbatponsel.com',
        'dewi@flash.id',
        'hendra@master.id'
      ].contains(lowerEmail);

      if (isDemoAccount && (password == 'password' || password == '123456')) {
        _applyDemographicPresets(lowerEmail);
        await SessionManager.saveSession(
          token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
          name: SessionManager.userName,
          email: lowerEmail,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil masuk (Offline Mode), ${SessionManager.userName}!"),
            backgroundColor: const Color(0xFF1B4F9B),
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.go('/main');
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Email atau kata sandi tidak valid!"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Listener untuk mengaktifkan tombol Log In
    void checkInput() {
      setState(() {
        _isButtonEnabled =
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      });
    }

    _emailController.addListener(checkInput);
    _passwordController.addListener(checkInput);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _bgGray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _textDark,
          iconSize: 20,
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Masuk",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: _textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // --- 1. Hero / Logo ---
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: Image.asset(
                'assets/images/vbat_logo_shadow.png', // Pastikan dummy aset logo VBat tersedia
                height: 80,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _vbatBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.handyman_rounded,
                    color: _vbatBlue,
                    size: 40,
                  ),
                ),
              ),
            ),

            // --- 2. Form Input Utama ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Input Field Username/Phone/Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: _textDark,
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: _textGray.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(Icons.email_outlined, color: _textGray),
                      filled: true,
                      fillColor: _inputBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _vbatBlue, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Field Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    style: TextStyle(
                      color: _textDark,
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(
                        color: _textGray.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: _textGray,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _textGray,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _isObscure = !_isObscure);
                            },
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(
                                right: 16,
                                left: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Lupa?",
                              style: TextStyle(
                                color: _vbatBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: _inputBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _vbatBlue, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Demo Accounts Chips
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 16, color: _vbatBlue),
                            const SizedBox(width: 4),
                            Text(
                              "1-Tap Akun Demo Teknisi:",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _vbatBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildDemoChip("Andi (Gen-Z / 22 Th)", "andi@teknisi.id"),
                            _buildDemoChip("Siti (Surabaya / 28 Th)", "siti@service.id"),
                            _buildDemoChip("Rian (Bandung / 26 Th)", "rian@repair.id"),
                            _buildDemoChip("Budi (Jkt Sel / 33 Th)", "budi@vbatponsel.com"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary CTA Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isButtonEnabled && !_isLoading) ? _handleLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled
                            ? _vbatBlue
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 3. Divider ATAU ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "ATAU",
                      style: TextStyle(
                        color: _textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
            ),

            // --- 4. SSO Options ---
            _buildSSOButton(
              "Lanjutkan dengan Google",
              Icons.g_mobiledata_rounded,
              Colors.red,
              imagePath: 'assets/images/google_logo.png',
              onPressed: () => _handleSSOLogin("Google"),
            ),
            const SizedBox(height: 12),
            _buildSSOButton(
              "Lanjutkan dengan Facebook",
              Icons.facebook_rounded,
              Colors.blue,
              imagePath: 'assets/images/facebook_logo.png',
              onPressed: () => _handleSSOLogin("Facebook"),
            ),
            const SizedBox(height: 12),
            _buildSSOButton(
              "Lanjutkan dengan Apple",
              Icons.apple_rounded,
              Colors.black,
              imagePath: 'assets/images/apple_logo.png',
              onPressed: () => _handleSSOLogin("Apple"),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  SessionManager.logout();
                  context.go('/main');
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: _vbatBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Masuk sebagai Tamu",
                  style: TextStyle(
                    color: _vbatBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // --- 5. Register Link ---
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Belum punya akun? ", style: TextStyle(color: _textDark)),
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: Text(
                    "Daftar",
                    style: TextStyle(
                      color: _vbatBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleSSOLogin(String provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        final provLower = provider.toLowerCase();
        final domain = provLower == 'google' ? 'gmail.com' : (provLower == 'apple' ? 'icloud.com' : 'teknisi.id');

        final accounts = [
          {
            'name': 'Andi Pratama',
            'email': 'andi.pratama@$domain',
            'avatar': 'A',
            'color': const Color(0xFF1B4F9B),
          },
          {
            'name': 'Budi Teknisi',
            'email': 'budi.santoso@$domain',
            'avatar': 'B',
            'color': const Color(0xFF10B981),
          },
          {
            'name': 'Rian Hardware',
            'email': 'rian.hardware@$domain',
            'avatar': 'R',
            'color': const Color(0xFFF97316),
          },
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      provLower == 'google'
                          ? Icons.g_mobiledata_rounded
                          : (provLower == 'apple'
                              ? Icons.apple_rounded
                              : (provLower == 'whatsapp'
                                  ? Icons.chat_rounded
                                  : Icons.facebook_rounded)),
                      color: provLower == 'google'
                          ? Colors.red
                          : (provLower == 'apple'
                              ? Colors.black
                              : (provLower == 'whatsapp' ? Colors.green : Colors.blue)),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pilih Akun $provider",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "untuk login ke VBat Ponsel",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...accounts.map((acc) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    leading: CircleAvatar(
                      backgroundColor: acc['color'] as Color,
                      foregroundColor: Colors.white,
                      child: Text(acc['avatar'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(acc['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(acc['email'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _executeOAuthLogin(provider, acc['name'] as String, acc['email'] as String);
                    },
                  );
                }),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.grey),
                  ),
                  title: const Text("Gunakan akun lain", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text("Masuk dengan kredensial baru", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _executeOAuthLogin(provider, "Teknisi Baru", "teknisi.baru@$domain");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _executeOAuthLogin(String provider, String name, String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: SessionManager.apiBaseUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final res = await dio.post('/auth/oauth/callback', data: {
        'provider': provider.toLowerCase(),
        'provider_user': {
          'id': 'oauth_${provider.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': email,
        },
      });

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      String ssoToken = 'sso_token_${provider.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
      if (res.data != null && res.data['success'] == true) {
        final userData = res.data['data']['user'];
        SessionManager.userName = userData['name'] ?? name;
        ssoToken = res.data['data']['token'] ?? ssoToken;
      } else {
        SessionManager.userName = name;
      }

      await SessionManager.saveSession(
        token: ssoToken,
        name: SessionManager.userName,
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil masuk melalui $provider! Selamat datang, ${SessionManager.userName}"),
          backgroundColor: const Color(0xFF1B4F9B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/main');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      // Fallback offline / local login
      SessionManager.userName = name;
      await SessionManager.saveSession(
        token: 'sso_token_${provider.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masuk dengan $provider berhasil. Selamat datang, $name!"),
          backgroundColor: const Color(0xFF1B4F9B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/main');
    }
  }

  Widget _buildSSOButton(
    String label,
    IconData icon,
    Color iconColor, {
    String? imagePath,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: _bgGray, shape: BoxShape.circle),
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon, color: iconColor, size: 20),
                    )
                  : Icon(icon, color: iconColor, size: 20),
            ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: _textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoChip(String label, String email) {
    return InkWell(
      onTap: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = "password";
          _isButtonEnabled = true;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF93C5FD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _vbatBlue,
          ),
        ),
      ),
    );
  }
}
