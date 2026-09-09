import 'package:flutter_test/flutter_test.dart';

import '../scenarios/app_flow_scenario.dart';

void main() {
  testWidgets('user logs in and opens activities for a place', (tester) async {
    await runLoginToActivitiesFlow(tester);
  });
}
