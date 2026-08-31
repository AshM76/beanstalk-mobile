// Regression tests for the "stuck on age picker" report (build 3): selecting
// an age band reveals the Cash bubble, which on the pre-PR-#5 layout grew the
// column and pushed the Continue button off-screen with no way to scroll.
//
// Runs at the reporter's viewport (393x852, iPhone 15) and a small one
// (375x667, iPhone SE class) where the original overflow was worst. The small
// viewport also guards the welcome page's pinned "Let's Get Started" footer.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beanstalk/pages/onboarding/onboarding_flow.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final size in const [Size(393, 852), Size(375, 667)]) {
    testWidgets(
        'onboarding: primary buttons stay visible and tappable with Cash '
        'bubble expanded at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: OnboardingFlow()));

      // Welcome page: the footer button must be on-screen even when the hero
      // content would overflow (it scrolls; the button is pinned).
      final startFinder = find.text("Let's Get Started");
      expect(startFinder.hitTestable(), findsOneWidget,
          reason: "Let's Get Started must be visible without scrolling");
      expect(tester.getRect(startFinder).bottom,
          lessThanOrEqualTo(size.height));

      await tester.tap(startFinder);
      await tester.pumpAndSettle();
      expect(find.text('Who are you?'), findsOneWidget);

      for (final band in const [
        'High School',
        'College',
        'Young Professional',
        'Adult',
      ]) {
        await tester.tap(find.text(band));
        await tester.pumpAndSettle();

        final continueFinder = find.text('Continue');
        expect(continueFinder, findsOneWidget,
            reason: 'Continue must exist after selecting $band');

        // Fully inside the viewport — reachable WITHOUT scrolling, even with
        // the Cash bubble expanded below the age options.
        final rect = tester.getRect(continueFinder);
        expect(rect.bottom, lessThanOrEqualTo(size.height),
            reason: 'Continue must be on-screen with $band selected');
        expect(rect.top, greaterThanOrEqualTo(0));

        // Nothing (e.g. the bubble) covers it — it must be hit-testable.
        expect(continueFinder.hitTestable(), findsOneWidget,
            reason: 'Continue must not be covered by other widgets ($band)');
      }

      // And it actually advances: tapping Continue leaves the age picker.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Who are you?'), findsNothing,
          reason: 'Continue tap must leave the age picker');
    });
  }
}
