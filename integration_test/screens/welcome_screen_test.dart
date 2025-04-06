import 'package:integration_test/integration_test.dart';
import '../flows/auth_flow_test.dart' as auth_flow;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  auth_flow.main();
}