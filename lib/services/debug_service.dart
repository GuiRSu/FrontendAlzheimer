import 'package:shared_preferences/shared_preferences.dart';

class DebugService {
  static Future<void> printAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userRole = prefs.getString('userRole') ?? 'No role';
      final userName = prefs.getString('userName') ?? 'No name';
      final token = prefs.getString('authToken') ?? 'No token';

      print('=== DEBUG AUTH STATUS ===');
      print('isLoggedIn: $isLoggedIn');
      print('userRole: $userRole');
      print('userName: $userName');
      print('token length: ${token.length}');
      print(
        'token preview: ${token.length > 20 ? token.substring(0, 20) + "..." : token}',
      );
      print('========================');
    } catch (e) {
      print('Error en debug: $e');
    }
  }
}
