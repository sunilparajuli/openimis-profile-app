import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/services/api_graphql_services.dart';
import 'package:openimis_web_app/services/api_rest_services.dart';
import 'package:openimis_web_app/utils/token_fetch.dart';
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;

class HomePageHooks {
  static Future<bool> canRefreshClaims() async {
    final value = await helper.SessionManager().getClaimsServicesStatus();
    return !(value == true);
  }

  static Future<bool> canRefreshInsureeData() async {
    final value = await helper.SessionManager().getInsureeInfoServicesStatus();
    return !(value == true);
  }

  static Future<InsureeData> fetchInsureeData(AuthBlock auth, bool canRefresh) async {
    final token = TokenUtils.getToken(auth);
    final chfId = TokenUtils.getChfId(auth);
    return ApiGraphQlServices().InsureeInfoServicesGQL(token, chfId, canRefresh);
  }

  static Future<Claims> fetchClaimsData(AuthBlock auth, bool canRefresh) async {
    final token = TokenUtils.getToken(auth);
    final chfId = TokenUtils.getChfId(auth);
    return ApiGraphQlServices().ClaimsServicesGQL(token, chfId, canRefresh);
  }

  static Future<double?> fetchBalance(AuthBlock auth) async {
    final isRefresh = await helper.SessionManager().getTrueSetFalseRefreshAPi();

    if (!isRefresh) {
      final hasCachedBalance = await helper.SessionManager().getprocedureHIBstatus();
      if (hasCachedBalance != false) {
        final cachedBalanceData = await helper.SessionManager().getprocedureHIB();
        if (cachedBalanceData != null) {
          return cachedBalanceData.balance;
        }
      }
    }

    try {
      final token = TokenUtils.getToken(auth);
      final chfId = TokenUtils.getChfId(auth);
      final value = await ApiRestServices().UspPolicyHIB(token, chfId, true);
      return value.balance;
    } catch (e) {
      print("Error fetching balance: $e");
      return null;
    }
  }
}
