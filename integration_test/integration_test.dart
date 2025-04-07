import 'package:flutter_test/flutter_test.dart';

import './screens/sign_in_screen.dart' as sign_in_test; 
import './screens/sign_up_screen.dart' as sign_up_test;
import './screens/welcome_screen.dart' as welcome_test;
import './screens/home_screen.dart' as home_test;
import './screens/profile_screen.dart' as profile_test;
import './screens/market_screen.dart' as market_test;
import './screens/achievements_screen.dart' as achievements_test;
import './screens/collection_screen.dart' as collection_test;
import './screens/search_exchange_screen.dart' as search_exchange_test;


void main() {
  group('Integration Tests', () {
    welcome_test.main();
    sign_up_test.main();
    sign_in_test.main();
    home_test.main();
    profile_test.main();
    market_test.main();
    achievements_test.main();
    collection_test.main();
    search_exchange_test.main();
  });
}