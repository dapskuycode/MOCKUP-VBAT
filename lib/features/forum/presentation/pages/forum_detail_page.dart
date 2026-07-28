import 'package:flutter/material.dart';

class ForumDetailPage extends StatefulWidget {
  const ForumDetailPage({super.key});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final Color _primaryBlue = const Color(0xFF1B4F9B);
  final Color _bgLight = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF0D2B5E);
  final Color _textGray = const Color(0xFF434751);

  bool _isLiked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Forum Teknisi",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // --- Sticky Input Bottom ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12, // safe area
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tulis komentar...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: _primaryBlue,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- 1. Main Post Area ---
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Budi Teknisi",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "TEKNISI SENIOR",
                                      style: TextStyle(
                                        color: _primaryBlue,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "2 jam yang lalu",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded),
                          color: Colors.grey,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Post Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cara jumper IC Power iPhone 11",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBlue,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Malam suhu semua, izin share pengalaman hari ini masuk servisan iPhone 11 kondisi mati total (matot) konslet di jalur VDD_MAIN. Setelah cek tegangan menggunakan power supply ternyata ada short.\n\nLangkah-langkah yang saya lakukan:\n1. Angkat kaleng area IC Power (U3100)\n2. Injek tegangan 1.8v ke kapasitor terdekat, ternyata IC Power langsung panas.\n3. Angkat IC Power, reball, lalu pasang kembali tapi masih short.\n4. Akhirnya saya jumper langsung jalur tegangan yang putus akibat korosi di bawah IC.\n\nBerikut saya sertakan foto mikroskop hasil jumperannya. Perhatikan kawat jumper ukuran 0.01mm wajib dilapisi UV mask agar tidak short ke ground sebelahnya.",
                          style: TextStyle(
                            fontSize: 14,
                            color: _textGray,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Carousel
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Container(
                          width:
                              MediaQuery.of(context).size.width *
                              0.75, // 85% width like tailwind
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interaction Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _isLiked = !_isLiked),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked
                                        ? Icons.thumb_up_rounded
                                        : Icons.thumb_up_outlined,
                                    color: _isLiked ? _primaryBlue : _textGray,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "12 Suka",
                                    style: TextStyle(
                                      color: _isLiked
                                          ? _primaryBlue
                                          : _textGray,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: _textGray,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "5 Komentar",
                                  style: TextStyle(
                                    color: _textGray,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.share_outlined, color: _textGray, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. Comments Section ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      "Komentar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Comment
                  _buildCommentItem(
                    author: "Agus Fixit",
                    time: "1 hour ago",
                    content:
                        "Mantap suhu, sangat membantu! Kebetulan lagi ada kasus mirip tapi di iPhone X. Izin sedot ilmunya ya suhu.",
                    likes: "2",
                    isReply: false,
                  ),

                  // Nested Reply
                  _buildCommentItem(
                    author: "Budi Teknisi",
                    time: "30 mins ago",
                    content:
                        "Sama-sama, hati-hati saat pengerjaan jalurnya tipis. Pastikan suhu blower tidak terlalu tinggi biar komponen pasif sebelahnya aman.",
                    likes: "0",
                    isReply: true,
                    isOp: true, // OP (Original Poster) Badge
                  ),

                  const SizedBox(height: 16),

                  // Another Comment
                  _buildCommentItem(
                    author: "Reza Cell",
                    time: "5 mins ago",
                    content:
                        "Kawat jumper pake merk apa hu? Punya saya gampang putus.",
                    likes: "0",
                    isReply: false,
                    avatarText: "R",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCommentItem({
    required String author,
    required String time,
    required String content,
    required String likes,
    required bool isReply,
    bool isOp = false,
    String? avatarText,
  }) {
    return Container(
      margin: EdgeInsets.only(left: isReply ? 40 : 0, bottom: 12),
      padding: EdgeInsets.all(isReply ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundColor: Colors.grey.shade200,
            child: avatarText != null
                ? Text(
                    avatarText,
                    style: TextStyle(
                      color: _primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: Colors.grey.shade400,
                    size: isReply ? 20 : 24,
                  ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          author,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isOp ? _primaryBlue : _textDark,
                          ),
                        ),
                        if (isOp) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "OP",
                              style: TextStyle(
                                color: _primaryBlue,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: _textGray),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(fontSize: 13, color: _textGray, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Balas",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _textGray,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 14,
                          color: _textGray,
                        ),
                        if (likes != "0") ...[
                          const SizedBox(width: 4),
                          Text(
                            likes,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _textGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
