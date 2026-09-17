import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vbat_ponsel/core/utils/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF001944);
  final Color _textGray = const Color(0xFF737782);
  final Color _orangeCTA = const Color(0xFFF78B00);
  final Color _redWarning = const Color(0xFFEF4444);
  final Color _greenSuccess = const Color(0xFF10B981);

  // Form Controllers
  final TextEditingController _nameController = TextEditingController(
    text: SessionManager.userName,
  );
  final TextEditingController _emailController = TextEditingController(
    text: "budi@vbatponsel.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "081234567890",
  );
  final TextEditingController _waController = TextEditingController(
    text: "6281234567890",
  );
  final TextEditingController _addressController = TextEditingController(
    text: "Jl. Merdeka No 123, Blok C",
  );
  final TextEditingController _igController = TextEditingController();
  final TextEditingController _fbController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _ytController = TextEditingController();

  DateTime? _selectedBirthDate = SessionManager.birthDate ?? DateTime(1998, 5, 15);
  String? _selectedGender = SessionManager.gender ?? "Laki-laki";
  String? _selectedProvinsi = SessionManager.province ?? "Jawa Barat";
  String? _selectedKota = SessionManager.city ?? "Bandung";
  String? _selectedKecamatan;
  String? _selectedKelurahan;

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
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _primaryBlue),
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
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "PENTING: Pastikan Nama Lengkap dan Data Diri sesuai KTP. Data ini akan dicetak permanen pada KTA Digital dan Sertifikat Kelulusan seumur hidup.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
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
                    [
                      "Jawa Barat",
                      "DKI Jakarta",
                      "Jawa Tengah",
                      "Jawa Timur",
                      "Banten",
                      "Sumatera Utara",
                      "Sulawesi Selatan",
                      "Bali",
                    ],
                    _selectedProvinsi,
                    (val) => setState(() => _selectedProvinsi = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    "Kota/Kabupaten *",
                    [
                      "Bandung",
                      "Jakarta Pusat",
                      "Jakarta Selatan",
                      "Surabaya",
                      "Semarang",
                      "Medan",
                      "Makassar",
                      "Denpasar",
                    ],
                    _selectedKota,
                    (val) => setState(() => _selectedKota = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "Kecamatan *",
                    ["Kecamatan A", "Kecamatan B"],
                    _selectedKecamatan,
                    (val) => setState(() => _selectedKecamatan = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    "Kelurahan/Desa *",
                    ["Kelurahan X", "Kelurahan Y"],
                    _selectedKelurahan,
                    (val) => setState(() => _selectedKelurahan = val),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data diatur ulang")),
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
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama Lengkap wajib diisi")),
                      );
                      return;
                    }
                    if (_selectedBirthDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tanggal Lahir wajib diisi untuk kelengkapan data demografi"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (_selectedGender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Jenis Kelamin wajib dipilih"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (_selectedKota == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Kota/Domisili wajib dipilih"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Simpan data demografi ke SessionManager
                    final updatedName = _nameController.text.trim();
                    SessionManager.userName = updatedName;
                    SessionManager.birthDate = _selectedBirthDate;
                    SessionManager.gender = _selectedGender;
                    SessionManager.province = _selectedProvinsi;
                    SessionManager.city = _selectedKota;
                    SessionManager.profileCompleted = true;

                    // Sync secara real-time ke Database Web Laravel via API
                    SessionManager.syncProfileToBackend(
                      name: updatedName,
                      birthDate: _selectedBirthDate,
                      gender: _selectedGender,
                      province: _selectedProvinsi,
                      city: _selectedKota,
                    );

                    // Langsung kembali ke halaman profil
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
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedItem,
              hint: Text(
                "Pilih $label".replaceAll(" *", ""),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textGray),
              items: items.map((String item) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedBirthDate != null ? _textDark : Colors.grey.shade400,
                  ),
                ),
                Icon(Icons.calendar_month_rounded, color: _primaryBlue, size: 20),
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
