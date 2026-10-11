import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';

/// Pengujian tampilan badge tier.
///
/// 1. Menghasilkan gambar untuk diperiksa secara visual:
///      flutter test test/visual/sponsor_badge_visual_test.dart --update-goldens
///    Berkas hasil: test/visual/goldens/tier_badge_{terang,gelap}.png
///
/// 2. Memastikan badge tidak melampaui batas pada ruang sempit — ukuran
///    terkecil yang dipakai di kartu produk adalah sekitar 120 piksel.
void main() {
  const List<String> tiers = <String>[
    'Free',
    'Kontribusi',
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
    'Diamond',
  ];

  Widget showcase({required bool dark}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: dark ? const Color(0xFF0F172A) : Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final String tier in tiers)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 76,
                        child: Text(
                          tier,
                          style: TextStyle(
                            fontSize: 11,
                            color: dark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      // Ukuran sedang.
                      SponsorTierBadge(
                        rawTier: tier,
                        fontSize: 11,
                        iconSize: 14,
                      ),
                      const SizedBox(width: 14),
                      // Ukuran kecil seperti di kartu produk.
                      SponsorTierBadge(
                        rawTier: tier,
                        fontSize: 7.5,
                        iconSize: 9,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('tangkap tampilan badge tier - tema terang',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 720);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(showcase(dark: false));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tier_badge_terang.png'),
    );
  });

  testWidgets('tangkap tampilan badge tier - tema gelap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 720);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(showcase(dark: true));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/tier_badge_gelap.png'),
    );
  });

  testWidgets('badge muat di ruang sempit 120 piksel tanpa melampaui batas',
      (WidgetTester tester) async {
    for (final String tier in tiers) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SponsorTierBadge(
                      rawTier: tier,
                      fontSize: 7.5,
                      iconSize: 9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Badge $tier tidak boleh melampaui 120 piksel.',
      );
    }
  });
}
