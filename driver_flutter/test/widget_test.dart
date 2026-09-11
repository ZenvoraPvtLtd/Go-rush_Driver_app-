import 'package:flutter_test/flutter_test.dart';
import 'package:gorush_driver/main.dart';

void main() {
  testWidgets('GoRush Driver App launches into Driver Home Dashboard directly and auto-progresses every 5s', (WidgetTester tester) async {
    await tester.pumpWidget(const GoRushDriverApp());
    await tester.pump();

    // 1. Initial Launch: Must be Screen 01 - Driver Home Dashboard
    expect(find.text('STEP 1/13'), findsOneWidget);
    expect(find.text('Driver Home Dashboard'), findsOneWidget);
    expect(find.text('AAJ KI KAMAI'), findsOneWidget);
    expect(find.text('₹2,480'), findsOneWidget);
    expect(find.text('Rajesh Verma'), findsOneWidget);

    // 2. Test Manual Bottom Navigation tap to Trips (Screen 05 - Trip History)
    final tripsTab = find.text('Trips');
    expect(tripsTab, findsOneWidget);
    await tester.tap(tripsTab);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('STEP 5/13'), findsOneWidget);
    expect(find.text('Trip History & Receipt'), findsOneWidget);
    expect(find.text('#TRP-98421'), findsOneWidget);
    expect(find.text('₹513.94'), findsNWidgets(2));

    // 3. Test Manual Bottom Navigation tap to Earnings (Screen 06 - Earnings)
    final earningsTab = find.text('Earnings').last;
    await tester.tap(earningsTab);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('STEP 6/13'), findsOneWidget);
    expect(find.text('Earnings & Instant Payout'), findsOneWidget);
    expect(find.text('₹4,850.00'), findsOneWidget);

    // 4. Test Manual Bottom Navigation tap to Incentives (Screen 07 - Incentives)
    final incentivesTab = find.text('Incentives').last;
    await tester.tap(incentivesTab);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('STEP 7/13'), findsOneWidget);
    expect(find.text('Incentives & Weekly Quests'), findsOneWidget);
    expect(find.text('Level 4 Pro Partner'), findsOneWidget);

    // 5. Test Manual HUD Navigation: Tap Next button
    final nextBtn = find.byTooltip('Next Screen');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('STEP 8/13'), findsOneWidget);
    expect(find.text('Ratings & Dispute Center'), findsOneWidget);
    expect(find.text('4.92'), findsOneWidget);

    // 6. Test Auto-progression: Resume and pump 5.2s -> progresses to Screen 09 (Scheduled Rides)
    final playBtn = find.byTooltip('Resume Auto 5s Flow');
    if (playBtn.evaluate().isNotEmpty) {
      await tester.tap(playBtn);
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(seconds: 5, milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('STEP 9/13'), findsOneWidget);
    expect(find.text('Scheduled Rides & Bookings'), findsOneWidget);
  });
}
