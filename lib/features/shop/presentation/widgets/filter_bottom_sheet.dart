import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  // Fungsi pembantu untuk memanggil bottom sheet ini dari halaman mana pun
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Memungkinkan tinggi sheet hampir penuh
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _orangeSale = const Color(0xFFFD761A);
  final Color _bgLight = const Color(0xFFF1F3FF); // surface-container-low
  final Color _textDark = const Color(0xFF0D2B5E);

  // State Variables
  String _selectedCategory = 'LCD';
  String _selectedRating = '4★ ke atas';
  RangeValues _priceRange = const RangeValues(0, 5000000);

  final Map<String, bool> _brands = {
    'BraderParts': true,
    'OG Battery': false,
    'Aigo': true,
    'ShineStar': false,
  };

  @override
  Widget build(BuildContext context) {
    // Membatasi tinggi maksimum bottom sheet hingga 85% layar
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: maxHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- 1. Handle (Drag Indicator) ---
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // --- 2. Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  "Filter",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // --- 3. Scrollable Content ---
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                // Kategori
                _buildSectionTitle("Kategori"),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildCustomChip(
                      "LCD",
                      _selectedCategory == "LCD",
                      (v) => setState(() => _selectedCategory = "LCD"),
                    ),
                    _buildCustomChip(
                      "Baterai",
                      _selectedCategory == "Baterai",
                      (v) => setState(() => _selectedCategory = "Baterai"),
                    ),
                    _buildCustomChip(
                      "Alat Servis",
                      _selectedCategory == "Alat Servis",
                      (v) => setState(() => _selectedCategory = "Alat Servis"),
                    ),
                    _buildCustomChip(
                      "Sparepart",
                      _selectedCategory == "Sparepart",
                      (v) => setState(() => _selectedCategory = "Sparepart"),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Rentang Harga
                _buildSectionTitle("Rentang Harga"),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 10000000,
                  activeColor: _primaryBlue,
                  inactiveColor: Colors.grey.shade200,
                  onChanged: (RangeValues values) {
                    setState(() => _priceRange = values);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceInput(
                        _priceRange.start.round().toString(),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "-",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: _buildPriceInput(
                        _priceRange.end.round().toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Rating
                _buildSectionTitle("Rating"),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildCustomChip(
                      "5★",
                      _selectedRating == "5★",
                      (v) => setState(() => _selectedRating = "5★"),
                    ),
                    _buildCustomChip(
                      "4★ ke atas",
                      _selectedRating == "4★ ke atas",
                      (v) => setState(() => _selectedRating = "4★ ke atas"),
                    ),
                    _buildCustomChip(
                      "3★ ke atas",
                      _selectedRating == "3★ ke atas",
                      (v) => setState(() => _selectedRating = "3★ ke atas"),
                    ),
                    _buildCustomChip(
                      "Semua",
                      _selectedRating == "Semua",
                      (v) => setState(() => _selectedRating = "Semua"),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Brand
                _buildSectionTitle("Brand"),
                Column(
                  children: _brands.keys.map((brand) {
                    return _buildCustomCheckbox(
                      brand,
                      _brands[brand]!,
                      (val) => setState(() => _brands[brand] = val!),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // --- 4. Sticky Footer ---
          Container(
            padding: EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
              bottom:
                  MediaQuery.of(context).padding.bottom +
                  16, // Safe area bottom
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orangeSale,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Terapkan Filter (12)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'LCD';
      _selectedRating = 'Semua';
      _priceRange = const RangeValues(0, 5000000);
      _brands.updateAll((key, value) => false);
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryBlue,
        ),
      ),
    );
  }

  Widget _buildCustomChip(String label, bool isSelected, Function(bool) onTap) {
    return GestureDetector(
      onTap: () => onTap(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue.withValues(alpha: 0.1) : _bgLight,
          border: Border.all(
            color: isSelected ? _primaryBlue : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _primaryBlue : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInput(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            "Rp",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(
    String label,
    bool isChecked,
    Function(bool?) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isChecked,
                activeColor: _primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                color: isChecked ? _primaryBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
