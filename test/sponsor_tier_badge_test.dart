import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vbat_ponsel/core/widgets/sponsor_tier_badge.dart';

/// Pengujian badge tier:
/// 1. Badge memakai berkas ikon bawaan aplikasi (bukan ikon Flutter biasa).
/// 2. Warna dari server lebih diutamakan daripada warna bawaan.
/// 3. Nama tier mentah dirapikan ("SPONSOR PLATINUM" menjadi "Platinum").
/// 4. Bila server mengirim ikon, ikon itu yang dipakai.
void main() {
  testWidgets('badge memakai ikon bawaan aplikasi untuk tiap tier',
      (WidgetTester tester) async {
    for (final String tier in <String>[
      'Free',
      'Kontribusi',
      'Bronze',
      'Silver',
      'Gold',
      'Platinum',
      'Diamond',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: SponsorTierBadge(rawTier: tier)),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byType(SvgPicture),
        findsOneWidget,
        reason: 'Tier $tier harus memakai berkas ikon SVG bawaan aplikasi.',
      );
    }
  });

  testWidgets('warna dari server dipakai bila tersedia',
      (WidgetTester tester) async {
    const Color serverColor = Color(0xFF123456);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SponsorTierBadge(
              rawTier: 'Gold',
              tierColor: serverColor,
              iconSource: const TierIconSource(color: serverColor),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Gold'), findsOneWidget);
  });

  testWidgets('ikon SVG dari server dipakai bila sudah terunduh',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SponsorTierBadge(
              rawTier: 'Diamond',
              iconSource: TierIconSource(
                url: 'https://example.com/ikon-diamond.svg',
                svgText: '<svg xmlns="http://www.w3.org/2000/svg" '
                    'viewBox="0 0 32 32"><circle cx="16" cy="16" r="12"/></svg>',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Diamond'), findsOneWidget);
  });

  testWidgets('ikon server yang gagal dimuat memakai ikon bawaan '
      'tanpa error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SponsorTierBadge(
              rawTier: 'Gold',
              iconSource: const TierIconSource(
                url: 'https://contoh-tidak-ada.invalid/ikon.png',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Wajib tetap tampil rapi: ikon bawaan aplikasi yang dipakai.
    expect(find.text('Gold'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  test('nama tier mentah dirapikan', () {
    expect(SponsorTierBadge.cleanTierName('SPONSOR PLATINUM'), 'Platinum');
    expect(SponsorTierBadge.cleanTierName('Sponsor Gold'), 'Gold');
    expect(SponsorTierBadge.cleanTierName('bronze partner'), 'Bronze partner');
    expect(SponsorTierBadge.cleanTierName(''), 'Partner');
  });

  test('berkas ikon bawaan tersedia untuk ketujuh tier', () {
    for (final String tier in <String>[
      'free',
      'kontribusi',
      'bronze',
      'silver',
      'gold',
      'platinum',
      'diamond',
    ]) {
      expect(
        SponsorTierBadge.assetIconFor(tier),
        isNotNull,
        reason: 'Berkas ikon $tier harus terdaftar.',
      );
      expect(
        SponsorTierBadge.assetIconFor(tier),
        endsWith('tier_$tier.svg'),
      );
    }
  });

  test('warna bawaan berbeda untuk tiap tier', () {
    final List<Color> colors = <Color>[
      SponsorTierBadge.getFallbackColor('Free'),
      SponsorTierBadge.getFallbackColor('Kontribusi'),
      SponsorTierBadge.getFallbackColor('Bronze'),
      SponsorTierBadge.getFallbackColor('Silver'),
      SponsorTierBadge.getFallbackColor('Gold'),
      SponsorTierBadge.getFallbackColor('Platinum'),
      SponsorTierBadge.getFallbackColor('Diamond'),
    ];
    expect(colors.toSet().length, colors.length,
        reason: 'Tiap tier harus punya warna berbeda.');
  });
}
