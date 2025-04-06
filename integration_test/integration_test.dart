import 'package:flutter_test/flutter_test.dart';

import './screens/sign_in_screen.dart' as sign_in_test; 
import './screens/sign_up_screen.dart' as sign_up_test;
import './screens/welcome_screen.dart' as welcome_test;

void main() {
  group('Integration Tests', () {
    welcome_test.main();
    sign_up_test.main();
    sign_in_test.main();
  });
}