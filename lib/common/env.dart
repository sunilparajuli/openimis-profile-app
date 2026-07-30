library env;

import 'package:openimis_web_app/blocks/auth_block.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool registerSuccess = false;
int ExpiryDate = 60;
const String APP_VERSION = "2.0.0";

setRegisterSuccessFalse(){
	registerSuccess = false;
}

setRegisterSuccessTrue(){
	registerSuccess = true;
}

getRegisterSuccess(){
	return registerSuccess;
}

getAuthToken(AuthBlock authBlock){
	if(authBlock.isLoggedIn){
		return authBlock.user['token'];
	}
	return "isLoggedIn=false";
}

late AuthBlock auth;

setAuth(AuthBlock authBlock){
	auth = authBlock;
}

late String CHFID;

setCHFID(String id){
	CHFID = id;
}
getCHFID(){
	return CHFID;
}

late String FirebaseToken;

setFirebaseToken(token){
	FirebaseToken = token;
}

getFirebaseToken(){
	return FirebaseToken;
}

String API_HIB_URL = dotenv.env['API_BASE_URL'] ?? 'https://imistest.hib.gov.np/api/graphql';
String API_HIB_REST_URL = dotenv.env['API_HIB_REST_URL'] ?? 'http://imistest.hib.gov.np/api/';
String API_BASE_URL = API_HIB_URL;

String LOGO_URL = 'assets/images/shs.png';
String SPLASH_SCREEN = 'assets/images/HIB.jpg';
String ONBOARDING_SCREEN_1 = 'assets/images/smcard/splash1.jpg';
String ONBOARDING_SCREEN_2 = 'assets/images/smcard/splash2.jpg';
String ONBOARDING_SCREEN_3 = 'assets/images/smcard/splash3.jpg';

bool production = dotenv.env['PRODUCTION']?.toLowerCase() == 'true';

String Currency = dotenv.env['CURRENCY'] ?? "Npr.";

String debugToken = dotenv.env['DEBUG_TOKEN'] ?? "123";
String debugChfId = dotenv.env['DEBUG_CHFID'] ?? "123";
