import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Definisi Warna Khas VBat
  final Color _vbatBlue = const Color(0xFF1B4F9B);
  final Color _bgGray = const Color(0xFFF8FAFC);
  final Color _textDark = const Color(0xFF111111);
  final Color _textGray = const Color(0xFF717784);
  final Color _inputBg = const Color(0xFFF1F5F9);

  // State Variables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    void checkInput() {
      setState(() {
        _isButtonEnabled = _nameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
      });
    }

    _nameController.addListener(checkInput);
    _emailController.addListener(checkInput);
    _passwordController.addListener(checkInput);
    _confirmPasswordController.addListener(checkInput);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          "Daftar",
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
                      'assets/images/vbat_logo_shadow.png',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _vbatBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.build_rounded,
                          size: 40,
                          color: _vbatBlue,
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
                        // Field 1: Nama
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: _textDark, fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Nama Lengkap Anda...",
                            hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.6), fontSize: 14),
                            prefixIcon: Icon(Icons.person_outline, color: _textGray),
                            filled: true,
                            fillColor: _inputBg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _vbatBlue, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: _textDark, fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Email Anda...",
                            hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.6), fontSize: 14),
                            prefixIcon: Icon(Icons.email_outlined, color: _textGray),
                            filled: true,
                            fillColor: _inputBg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _vbatBlue, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 3: Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscurePassword,
                          style: TextStyle(color: _textDark, fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Kata Sandi...",
                            hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.6), fontSize: 14),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: _textGray),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textGray),
                              onPressed: () => setState(() => _isObscurePassword = !_isObscurePassword),
                            ),
                            filled: true,
                            fillColor: _inputBg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _vbatBlue, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 4: Konfirmasi Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _isObscureConfirmPassword,
                          style: TextStyle(color: _textDark, fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Konfirmasi Kata Sandi...",
                            hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.6), fontSize: 14),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: _textGray),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textGray),
                              onPressed: () => setState(() => _isObscureConfirmPassword = !_isObscureConfirmPassword),
                            ),
                            filled: true,
                            fillColor: _inputBg,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _vbatBlue, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Primary CTA Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled
                                ? () => context.push('/otp-verification')
                                : null,
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
                            child: const Text(
                              "Daftar",
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
                  ),
                  const SizedBox(height: 12),
                  _buildSSOButton(
                    "Lanjutkan dengan Facebook",
                    Icons.facebook_rounded,
                    Colors.blue,
                    imagePath: 'assets/images/facebook_logo.png',
                  ),
                  const SizedBox(height: 12),
                  _buildSSOButton(
                    "Lanjutkan dengan WhatsApp",
                    Icons.chat_rounded,
                    Colors.green,
                    imagePath: 'assets/images/whatsapp_logo.png',
                  ),
                  const SizedBox(height: 12),
                  _buildSSOButton(
                    "Lanjutkan dengan Apple",
                    Icons.apple_rounded,
                    Colors.black,
                    imagePath: 'assets/images/apple_logo.png',
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

                  // --- 5. Login Link ---
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: _textDark),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: Text(
                          "Masuk",
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

  Widget _buildSSOButton(String label, IconData icon, Color iconColor, {String? imagePath}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
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
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(icon, color: iconColor, size: 20),
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
}
