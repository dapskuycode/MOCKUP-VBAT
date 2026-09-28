import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/theme/theme_manager.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  bool get _isDark => ThemeManager.isDark(context);
  Color get _bgLight => _isDark ? ThemeManager.darkBg : const Color(0xFFF5F7FA);
  Color get _cardColor => _isDark ? ThemeManager.darkCard : Colors.white;
  Color get _textDark => _isDark ? ThemeManager.darkText : const Color(0xFF001944);
  Color get _textGray => _isDark ? ThemeManager.darkTextSecondary : const Color(0xFF737782);
  Color get _borderColor => _isDark ? ThemeManager.darkBorder : Colors.grey.shade200;
  final Color _orangeCTA = const Color(0xFFF78B00);
  final Color _redWarning = const Color(0xFFEF4444);
  final Color _greenSuccess = const Color(0xFF10B981);

  // Form Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _waController;
  late final TextEditingController _addressController;
  late final TextEditingController _igController;
  late final TextEditingController _fbController;
  late final TextEditingController _tiktokController;
  late final TextEditingController _ytController;

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  String? _selectedProvinsi;
  String? _selectedKota;

  final List<String> _provinsiList = [
    "Jawa Tengah",
    "Jawa Barat",
    "DKI Jakarta",
    "Jawa Timur",
    "Banten",
    "DI Yogyakarta",
    "Sumatera Utara",
    "Sumatera Barat",
    "Sumatera Selatan",
    "Riau",
    "Lampung",
    "Bali",
    "Sulawesi Selatan",
    "Kalimantan Timur",
  ];

  final List<String> _kotaList = [
    "Semarang",
    "Kab. Semarang",
    "Surakarta (Solo)",
    "Bandung",
    "Jakarta Pusat",
    "Jakarta Selatan",
    "Jakarta Barat",
    "Jakarta Timur",
    "Jakarta Utara",
    "Surabaya",
    "Yogyakarta",
    "Malang",
    "Medan",
    "Makassar",
    "Denpasar",
  ];

  int? get _calculatedAge {
    if (_selectedBirthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _selectedBirthDate!.year;
    if (now.month < _selectedBirthDate!.month ||
        (now.month == _selectedBirthDate!.month && now.day < _selectedBirthDate!.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    ThemeManager.themeModeNotifier.addListener(_onThemeChanged);
    _nameController = TextEditingController(text: SessionManager.userName);
    _emailController = TextEditingController(text: SessionManager.userEmail);
    _phoneController = TextEditingController(text: SessionManager.phone ?? "");
    _waController = TextEditingController(text: SessionManager.whatsapp ?? "");
    _addressController = TextEditingController(text: SessionManager.address ?? "");
    _igController = TextEditingController(text: SessionManager.instagram ?? "");
    _fbController = TextEditingController(text: SessionManager.facebook ?? "");
    _tiktokController = TextEditingController(text: SessionManager.tiktok ?? "");
    _ytController = TextEditingController(text: SessionManager.youtube ?? "");

    _selectedBirthDate = SessionManager.birthDate;
    _selectedGender = SessionManager.gender;
    _selectedProvinsi = SessionManager.province;
    _selectedKota = SessionManager.city;
  }

  @override
  void dispose() {
    ThemeManager.themeModeNotifier.removeListener(_onThemeChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _waController.dispose();
    _addressController.dispose();
    _igController.dispose();
    _fbController.dispose();
    _tiktokController.dispose();
    _ytController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Edit Profil",
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Warning Banner KTA & Sertifikat ---
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isDark ? Colors.orange.withValues(alpha: 0.3) : Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: _isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "PENTING: Pastikan Nama Lengkap dan Data Diri sesuai KTP. Data ini akan dicetak permanen pada KTA Digital dan Sertifikat Kelulusan seumur hidup.",
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Avatar Section ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _orangeCTA,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- DATA PRIBADI ---
            _buildSectionHeader(Icons.person_outline_rounded, "DATA PRIBADI & DEMOGRAFI"),
            const SizedBox(height: 16),
            _buildTextField("Nama Lengkap *", _nameController),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildDropdown(
              "Jenis Kelamin *",
              ["Laki-laki", "Perempuan"],
              _selectedGender,
              (val) => setState(() => _selectedGender = val),
            ),
            const SizedBox(height: 32),

            // --- INFORMASI KONTAK ---
            _buildSectionHeader(
              Icons.contact_mail_outlined,
              "INFORMASI KONTAK",
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "Alamat Email",
              _emailController,
              isReadOnly: true,
              helperText: "✓ Email sudah terverifikasi",
              helperColor: _greenSuccess,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Nomor Telepon *", _phoneController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    "Nomor WhatsApp *",
                    _waController,
                    helperText: "Gunakan kode negara 62",
                    helperColor: _textGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "Alamat Lengkap *",
              _addressController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // --- WILAYAH ---
            _buildSectionHeader(Icons.location_on_outlined, "WILAYAH"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "Provinsi *",
                    _provinsiList,
                    _selectedProvinsi,
                    (val) => setState(() => _selectedProvinsi = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    "Kota/Kabupaten *",
                    _kotaList,
                    _selectedKota,
                    (val) => setState(() => _selectedKota = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- MEDIA SOSIAL ---
            _buildSectionHeader(Icons.share_outlined, "MEDIA SOSIAL"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Instagram",
                    _igController,
                    hintText: "@namapengguna",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    "Facebook",
                    _fbController,
                    hintText: "URL profil",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "TikTok",
                    _tiktokController,
                    hintText: "@namapengguna",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    "YouTube",
                    _ytController,
                    hintText: "URL channel",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _nameController.text = SessionManager.userName;
                      _emailController.text = SessionManager.userEmail;
                      _phoneController.text = SessionManager.phone ?? "";
                      _waController.text = SessionManager.whatsapp ?? "";
                      _addressController.text = SessionManager.address ?? "";
                      _igController.text = SessionManager.instagram ?? "";
                      _fbController.text = SessionManager.facebook ?? "";
                      _tiktokController.text = SessionManager.tiktok ?? "";
                      _ytController.text = SessionManager.youtube ?? "";
                      _selectedBirthDate = SessionManager.birthDate;
                      _selectedGender = SessionManager.gender;
                      _selectedProvinsi = SessionManager.province;
                      _selectedKota = SessionManager.city;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data formulir berhasil diatur ulang")),
                    );
                  },
                  child: Text(
                    "Atur Ulang",
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final updatedName = _nameController.text.trim();
                    if (updatedName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nama Lengkap wajib diisi"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final phone = _phoneController.text.trim();
                    final wa = _waController.text.trim();
                    final address = _addressController.text.trim();
                    final ig = _igController.text.trim();
                    final fb = _fbController.text.trim();
                    final tiktok = _tiktokController.text.trim();
                    final yt = _ytController.text.trim();

                    // Simpan data ke SessionManager
                    SessionManager.userName = updatedName;
                    SessionManager.birthDate = _selectedBirthDate;
                    SessionManager.gender = _selectedGender;
                    SessionManager.phone = phone.isNotEmpty ? phone : null;
                    SessionManager.whatsapp = wa.isNotEmpty ? wa : null;
                    SessionManager.address = address.isNotEmpty ? address : null;
                    SessionManager.province = _selectedProvinsi;
                    SessionManager.city = _selectedKota;
                    SessionManager.district = null;
                    SessionManager.village = null;
                    SessionManager.instagram = ig.isNotEmpty ? ig : null;
                    SessionManager.facebook = fb.isNotEmpty ? fb : null;
                    SessionManager.tiktok = tiktok.isNotEmpty ? tiktok : null;
                    SessionManager.youtube = yt.isNotEmpty ? yt : null;
                    SessionManager.checkAndNotifyProfileComplete();

                    // Loading indicator overlay
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Sync secara real-time ke Database Web Laravel via REST API
                    await SessionManager.syncProfileToBackend(
                      name: updatedName,
                      birthDate: _selectedBirthDate,
                      gender: _selectedGender,
                      phone: phone.isNotEmpty ? phone : null,
                      whatsapp: wa.isNotEmpty ? wa : null,
                      address: address.isNotEmpty ? address : null,
                      province: _selectedProvinsi,
                      city: _selectedKota,
                      instagram: ig.isNotEmpty ? ig : null,
                      facebook: fb.isNotEmpty ? fb : null,
                      tiktok: tiktok.isNotEmpty ? tiktok : null,
                      youtube: yt.isNotEmpty ? yt : null,
                    );

                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // dismiss loading dialog

                    if (SessionManager.isProfileComplete) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✓ Profil lengkap berhasil disimpan!"),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Perubahan disimpan. Lengkapi semua kolom bertanda * agar profil lengkap!"),
                          backgroundColor: Colors.orange.shade800,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    // Kembali ke halaman profil
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // --- DELETE ACCOUNT ---
            const Divider(),
            const SizedBox(height: 24),
            Text(
              "Hapus Akun",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Setelah akun Anda dihapus, seluruh data dan informasi yang terkait akan dihapus secara permanen dan tidak dapat dipulihkan. Pastikan Anda benar-benar yakin sebelum melanjutkan proses ini.",
              style: TextStyle(fontSize: 13, color: _textGray, height: 1.5),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Proses hapus akun...")),
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text(
                "Hapus Akun Saya",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _redWarning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _textGray),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _textGray,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isReadOnly = false,
    int maxLines = 1,
    String? hintText,
    String? helperText,
    Color? helperColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14,
            color: isReadOnly ? _textGray : _textDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.6)),
            filled: true,
            fillColor: isReadOnly ? (_isDark ? Colors.black26 : Colors.grey.shade100) : _cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryBlue),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: TextStyle(fontSize: 11, color: helperColor ?? _textGray),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged,
  ) {
    final effectiveItems = List<String>.from(items);
    if (selectedItem != null && selectedItem.isNotEmpty && !effectiveItems.contains(selectedItem)) {
      effectiveItems.insert(0, selectedItem);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: _cardColor,
              isExpanded: true,
              value: (selectedItem != null && effectiveItems.contains(selectedItem))
                  ? selectedItem
                  : null,
              hint: Text(
                "Pilih $label".replaceAll(" *", ""),
                style: TextStyle(color: _textGray.withValues(alpha: 0.6), fontSize: 14),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textGray),
              items: effectiveItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(color: _textDark, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final age = _calculatedAge;
    final dateStr = _selectedBirthDate != null
        ? "${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}"
        : "Pilih Tanggal Lahir";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tanggal Lahir *",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            if (age != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Text(
                  "Usia: $age Tahun",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: _primaryBlue,
                      onPrimary: Colors.white,
                      onSurface: _textDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedBirthDate = picked;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedBirthDate != null ? _textDark : _textGray.withValues(alpha: 0.6),
                  ),
                ),
                Icon(Icons.calendar_month_rounded, color: _isDark ? Colors.blue.shade300 : _primaryBlue, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Wajib diisi untuk verifikasi data diri & demografi teknisi",
          style: TextStyle(fontSize: 11, color: _textGray),
        ),
      ],
    );
  }
}
