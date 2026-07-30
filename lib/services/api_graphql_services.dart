import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:openimis_web_app/models/faq.dart';
import 'package:openimis_web_app/models/feedback.dart';
import 'package:openimis_web_app/models/health_facility_coordinates.dart';
import 'package:openimis_web_app/models/insuree_info.dart';
import 'package:openimis_web_app/models/insuree_policy_information.dart';
import 'package:openimis_web_app/models/notices.dart';
import 'package:openimis_web_app/models/notifications.dart';
import 'package:openimis_web_app/models/office.dart';
import 'package:http/http.dart' as http;
import 'package:openimis_web_app/services/api_client.dart';
import 'package:openimis_web_app/models/medical_services.dart';
import 'package:openimis_web_app/models/insuree_claims.dart';
import 'package:openimis_web_app/models/claimed.dart';
import 'package:openimis_web_app/models/claimeditems.dart';
import 'package:openimis_web_app/models/claimedservices.dart';
import 'package:openimis_web_app/models/policy_information.dart';
import 'package:openimis_web_app/graphql/gql_queries.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import "package:openimis_web_app/graphql/gql_mutations.dart";
import 'package:openimis_web_app/common/global.dart' as globals;
import 'package:openimis_web_app/helper/shared_preferences_helper.dart' as helper;

import "package:openimis_web_app/mock_api/mock_api_data_services.dart" as mock_data_services;

import '../models/ServiceProviders.dart';
import '../models/app_contacts.dart';

class ApiGraphQlServices {
    bool isLoading = false;
    MedicalServices? medicalServices;
    Claims? insuree_claims;
    Claimed? claimed;
    ClaimedServices? claimedservices;
    ClaimedItems? claimeditems;
    HealthFacilityCoordinates? healthFacilityCoordinates;
    PolicyInformation? policyinformation;
    InsureePolicyInformation? insureepolicyinformation;
    Notice? notices;
    Feedback? feedback;
    InsureeData? insureedata;
    Notifications? notifications;
    Offices? offices;
    Faq? faq;

    Future<MedicalServices> MedicalServicesGQL(String args) async {
        try {
            final response = await ApiClient.postGraphQL('', OpenimisGqlQueries.medicalServices(100));
            var jsonMap = json.decode(response.body);
            medicalServices = MedicalServices.fromJson(jsonMap);
            return medicalServices!;
        } catch (e) { throw Exception("API Error"); }
    }
    
    Future<Claims> ClaimsServicesGQL(String token, String chfID, bool canRefresh) async {
          if(env.production==false){
            insuree_claims = Claims.fromJson(json.decode(mock_data_services.MockApi().openimis_gql_insuree_claims()));
            return insuree_claims!;
          }

          if(!canRefresh){
            var cachedClaims = await helper.SessionManager().getClaimsServicesGQL();
            if(cachedClaims != null) {
              return cachedClaims;
            }
          }
            try {
              final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureeClaims(chfID));
              var jsonMap = response.body;
              helper.SessionManager().setClaimsServicesGQL(response.body);
              insuree_claims = Claims.fromJson(jsonDecode(jsonMap));
              return insuree_claims!;
            } catch (e) { throw Exception("API Error"); }
      }

    Future<ClaimedServices> ClaimedServicesServicesGQL(token, int claimId) async {
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureeClaimedServices(claimId));
            var jsonMap = json.decode(response.body);
            claimedservices = ClaimedServices.fromJson(jsonMap);
            return claimedservices!;
        } catch (e) { 
            throw Exception("API Error: $e"); 
        }
    }
    
    Future<ClaimedItems> ClaimedItemServicesGQL(token, int claimId) async {
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureeClaimedItems(claimId));
            var jsonMap = json.decode(response.body);
            claimeditems = ClaimedItems.fromJson(jsonMap);
            return claimeditems!;
        } catch (e) {
            throw Exception("API Error: $e");
        }
    }
    
    Future<HealthFacilityCoordinates> HealthFacilityCoordinatesServicesGQL(args) async {
        try {
            final response = await ApiClient.postGraphQL('', OpenimisGqlQueries.healthFacilityCoordinate(args));
            var jsonMap = json.decode(response.body);
            healthFacilityCoordinates = HealthFacilityCoordinates.fromJson(jsonMap);
            return healthFacilityCoordinates!;
        } catch (e) { 
            if (healthFacilityCoordinates != null) return healthFacilityCoordinates!;
            throw Exception("API Error"); 
        }
    }

    Future<dynamic> service_providers() async {
      try {
        final response = await ApiClient.postGraphQL('', OpenimisGqlQueries.service_providers());
        var jsonMap = json.decode(response.body);
        var facilities =  ServiceProvidersModel.fromJson(jsonMap);
        return facilities;
      } catch (e) {
        throw Exception("API Error");
      }
    }

    Future<PolicyInformation> PolicyInformationServicesGQL(String token, chfid) async {
      var isRefresh = await helper.SessionManager().getTrueSetFalseRefreshAPi();
      if(!isRefresh){
        var _policyinformation = await helper.SessionManager().getPolicyInformationCardPage();
        if (_policyinformation != null) {
          return _policyinformation;
        }
      }
      try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureePolicyInformation(chfid));
            var jsonMap = json.decode(response.body);
            helper.SessionManager().setPolicyInformationCardPage(response.body);
            policyinformation = PolicyInformation.fromJson(jsonMap);
            return policyinformation!;
        } catch (e) {
            if (policyinformation != null) return policyinformation!;
            throw Exception("API Error");
        }
    }
    

    Future<InsureePolicyInformation> InsureePolicyInformationServicesGQL(String token, chfid, bool canRefresh) async {
      if(canRefresh==true){
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureePolicyInformationLists(chfid));
            var jsonMap = json.decode(response.body);
            insureepolicyinformation = InsureePolicyInformation.fromJson(jsonMap);
            helper.SessionManager().setPolicyInformation(response.body);
            return insureepolicyinformation!;
        } catch (e) {
            if (insureepolicyinformation != null) return insureepolicyinformation!;
            throw Exception("API Error");
        }
      }
      else {
        var cached = await helper.SessionManager().getPolicyInformation();
        if (cached != null) {
          return cached;
        }
        return await InsureePolicyInformationServicesGQL(token, chfid, true);
      }
    }
    
    Future<Notice> NoticesServicesGQL(String token) async {
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.notices());
            var jsonMap = json.decode(response.body);
            notices = Notice.fromJson(jsonMap);
            return notices!;
        } catch (e) { 
            if (notices != null) return notices!;
            throw Exception("API Error"); 
        }
    }

    Future<InsureeData> InsureeInfoServicesGQL(String token, String chfid, bool canRefresh) async {
      if(env.production==false){
        insureedata = InsureeData.fromJson(json.decode(mock_data_services.MockApi().openimis_gql_insuree_info()));
        return insureedata!;
      }

      if(!canRefresh){
        var cachedInsureeData = await helper.SessionManager().getInsureeInfoServicesGQL();
        if(cachedInsureeData != null) {
          return cachedInsureeData;
        }
      }

        try {
          final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureeInfo(chfid));
          var jsonMap = json.decode(response.body);
          insureedata = InsureeData.fromJson(jsonMap);
          
          final photoUrl = insureedata?.data.profile.photo;
          if (photoUrl != null && photoUrl.isNotEmpty) {
            _cachePhotoAsBase64(photoUrl.replaceAll('192.168.15.22', 'imistest.hib.gov.np'));
          }

          helper.SessionManager().setInsureeInfoServicesGQL(response.body);
          return insureedata!;
        } catch (e) { throw Exception("API Error"); }
    }

    Future<void> _cachePhotoAsBase64(String url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final String base64Image = base64Encode(response.bodyBytes);
          await helper.SessionManager().settBase64Image(base64Image);
        }
      } catch (e) {
        print("Error caching profile photo: $e");
      }
    }

    Future<Notifications> NotificationsServicesGQL(String token, String chfid) async {
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.notifications(chfid));
            var jsonMap = json.decode(response.body);
            notifications = Notifications.fromJson(jsonMap);
            return notifications!;
        } catch (e) { throw Exception("API Error"); }
    }

    Future<Map>  createFeedback(fullname, email, mobileNo, queries) async {
        dynamic jsonmap;
        globals.isLoading = true;
        try {
               final response = await ApiClient.postGraphQL('', openimisGQLMutation().createFeedbackMutation(fullname, email, mobileNo, queries));
               jsonmap = jsonDecode(response.body);
           } catch (e) {
                globals.isLoading = false;
               throw Exception("API Error");
           }
       globals.isLoading = false;
        return jsonmap ;
    }


    Future<Map> createClaimFeedback(String token, String details, int rating, String source, String date, int claimId, bool cardRendered, bool paymentAsked, bool drugPrescribed, bool drugReceived) async {
        globals.isLoading = true;
        try {
            final response = await ApiClient.postGraphQL(token, openimisGQLMutation().createClaimFeedbackMutation(details, rating, source, date, claimId, cardRendered, paymentAsked, drugPrescribed, drugReceived));
            globals.isLoading = false;
            return jsonDecode(response.body);
        } catch (e) {
            globals.isLoading = false;
            throw Exception("API Error: $e");
        }
    }

    Future<AppContactsModel> AppContactsServicesGQL() async {
      late AppContactsModel appContacts;
      try {
        final response = await ApiClient.postGraphQL('',OpenimisGqlQueries.appContactsQuery());
        var jsonMap = json.decode(utf8.decode(response.bodyBytes));
        appContacts = AppContactsModel.fromJson(jsonMap);
      } catch (e) {
        throw Exception("API Error");
      }
      return appContacts;
    }

 Future<Offices>  getOfficesList() async {
   try {
     final response = await  rootBundle.loadString("assets/json/offices.json");
     offices =  Offices.fromJson(jsonDecode(response));
     return offices!;
   } catch (e) {
       if (offices != null) return offices!;
       throw Exception("Asset Error");
   }
 }

  Future<Faq>  getFaqs() async {
    try {
      final response = await  rootBundle.loadString("assets/json/faqs.json");
      faq =  Faq.fromJson(jsonDecode(response));
      return faq!;
    } catch (e) {
      if (faq != null) return faq!;
      throw Exception("Asset Error");
    }
  }
}
