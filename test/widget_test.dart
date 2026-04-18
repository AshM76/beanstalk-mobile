import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beanstalk/main.dart';
import 'package:beanstalk/services/api/api_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiService().init();
  });

  testWidgets('app boots through splash to login when unauthenticated',
      (tester) async {
    await tester.pumpWidget(const BeanstalkApp());

    expect(find.text('Beanstalk'), findsOneWidget);
    expect(find.text('Learn. Trade. Compete.'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
