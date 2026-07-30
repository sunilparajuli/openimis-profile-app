import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/common/env.dart' as env;

class TokenUtils {
  static String getToken(AuthBlock auth) {
    if (!auth.user.containsKey('data')) return env.debugToken;
    return env.production ? auth.user['data']['insureeAuthOtp']['token'] : env.debugToken;
  }

  static String getChfId(AuthBlock auth) {
    if (!auth.user.containsKey('data')) return env.debugChfId;
    return env.production ? auth.user['data']['insureeAuthOtp']['insuree']['chfId'] : env.debugChfId;
  }
}
