import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/scenarios/app_flow_scenario.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user logs in and opens activities for a place', (tester) async {
    await runLoginToActivitiesFlow(tester);
  });
}
