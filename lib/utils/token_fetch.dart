import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/common/env.dart' as env;

class TokenUtils {
  static String getToken(AuthBlock auth) {
    if (!auth.user.containsKey('data')) return "123";
    return env.production ? auth.user['data']['insureeAuthOtp']['token'] : "123";
  }

  static String getChfId(AuthBlock auth) {
    if (!auth.user.containsKey('data')) return "123";
    return env.production ? auth.user['data']['insureeAuthOtp']['insuree']['chfId'] : "123";
  }
}
