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
// import 'package:openimis_web_app/models/faq.dart';
// import 'package:http/http.dart' as http;
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
            print(jsonEncode(OpenimisGqlQueries.medicalServices(100)));
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
              final response = await ApiClient.postGraphQL(token, 
                      OpenimisGqlQueries.insureeClaims(chfID));
              var jsonMap = response.body;
              helper.SessionManager().setClaimsServicesGQL(response.body);
              insuree_claims = Claims.fromJson(jsonDecode(jsonMap));
              return insuree_claims!;
            } catch (e) { throw Exception("API Error"); }
      }



    Future<ClaimedServices> ClaimedServicesServicesGQL(token, int claimId) async { //todo pass claim id from widget
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureeClaimedServices(claimId));
            var jsonMap = json.decode(response.body);
            claimedservices = ClaimedServices.fromJson(jsonMap);
            return claimedservices!;
        } catch (e) { 
            print("ClaimedServicesServicesGQL error: $e");
            throw Exception("API Error: $e"); 
        }
    }
    
    Future<ClaimedItems> ClaimedItemServicesGQL(token, int claimId) async { //todo pass claim id from widget
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureeClaimedItems(claimId));
            var jsonMap = json.decode(response.body);
            claimeditems = ClaimedItems.fromJson(jsonMap);
            return claimeditems!;
        } catch (e) {
            print("ClaimedItemServicesGQL error: $e");
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

/// Removed the (args) parameter completely
    Future<dynamic> service_providers() async {
      try {
        final response = await ApiClient.postGraphQL('', OpenimisGqlQueries.service_providers());
        var jsonMap = json.decode(response.body);

        // Make sure this matches your actual JSON model for facilities
        var facilities =  ServiceProvidersModel.fromJson(jsonMap);

        return facilities;
      } catch (e) {
        print("Error fetching service providers: $e");
        throw Exception("API Error");
      }
    }


    Future<PolicyInformation> PolicyInformationServicesGQL(String token, chfid) async { //todo pass claim id from widget // this is for the homepage


      var isRefresh = await helper.SessionManager().getTrueSetFalseRefreshAPi().then((value) {
          return value;
      });
    if(!isRefresh){
      var _policyinformation = await helper.SessionManager()
            .getPolicyInformationCardPage();
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
    

    Future<InsureePolicyInformation> InsureePolicyInformationServicesGQL(String token, chfid, bool canRefresh) async { //todo pass claim id from widget // this is for the list of policies of insuree
      dynamic jsonMap;
      dynamic responseBody;

      if(canRefresh==true){

      try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.insureePolicyInformationLists(chfid));
            responseBody = response.body;
             jsonMap = json.decode(response.body);
            insureepolicyinformation = InsureePolicyInformation.fromJson(jsonMap);
            helper.SessionManager().setPolicyInformation(responseBody);
            return insureepolicyinformation!;
        } catch (e) {
            if (insureepolicyinformation != null) return insureepolicyinformation!;
            throw Exception("API Error");
        }
    }
      else {
       // helper.SessionManager().deletePoicyInfrmatin();
        var cached = await helper.SessionManager().getPolicyInformation();
        if (cached != null) {
          return cached;
        }
        // Fallback to fetch if cache is empty even if canRefresh is false
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
        insureedata = InsureeData.fromJson(json.decode(mock_data_services.MockApi().openimis_gql_insuree_info())); //(json.decode(mock_data_services.MockApi().openimis_gql_insuree_info()));
        return insureedata!;
      }

      if(!canRefresh){
        var cachedInsureeData = await helper.SessionManager().getInsureeInfoServicesGQL();
        if(cachedInsureeData != null) {
          return cachedInsureeData;
        }
      }

        try {
          final response = await ApiClient.postGraphQL(token, 
                  OpenimisGqlQueries.insureeInfo(chfid));
          var jsonMap = json.decode(response.body);
          insureedata = InsureeData.fromJson(jsonMap);
          // helper.SessionManager().deletePoicyInfrmatin();
          helper.SessionManager().setInsureeInfoServicesGQL(response.body);
          return insureedata!;
        } catch (e) { throw Exception("API Error"); }
    }


    Future<Notifications> NotificationsServicesGQL(String token, String chfid) async {
        try {
            final response = await ApiClient.postGraphQL(token, OpenimisGqlQueries.notifications(chfid));
            var jsonMap = json.decode(response.body);
            notifications = Notifications.fromJson(jsonMap);
            return notifications!;
        } catch (e) { throw Exception("API Error"); }
    }



  //mutation
    Future<Map>  createFeedback(fullname, email, mobile_number, queries) async {
        dynamic jsonmap;
        globals.isLoading = true;
        try {
               final response = await ApiClient.postGraphQL('', 
                       openimisGQLMutation().createFeedbackMutation(
                           fullname, email, mobile_number, queries));
               jsonmap = jsonDecode(response.body);
           } catch (e)
            {
                globals.isLoading = false;
               throw Exception("Not implemented");
           }
       globals.isLoading = false;
        return jsonmap ;
    }


    Future<AppContactsModel> AppContactsServicesGQL() async {
      late AppContactsModel appContacts;
      try {
        final response = await ApiClient.postGraphQL('',OpenimisGqlQueries.appContactsQuery());
        var jsonMap = json.decode(utf8.decode(response.bodyBytes)); // utf8.decode handles specific localized characters safely
        appContacts = AppContactsModel.fromJson(jsonMap);
      } catch (e) {
        throw Exception("API Error");
      }
      return appContacts;
    }

 Future<Offices>  getOfficesList() async {
   dynamic jsonmap;
   try {
     final response = await  rootBundle.loadString("assets/json/offices.json"); //http.get(Uri.parse(env.OFFICE_LIST_URL),
     jsonmap = response;
     offices =  Offices.fromJson(jsonDecode(jsonmap));
     return offices!;
   } catch (e)
     {
       if (offices != null) return offices!;
       throw Exception("Asset Error");
   }
 }


  Future<Faq>  getFaqs() async {
    dynamic jsonmap;
    try {
      //final response = await http.get(Uri.parse(env.FAQ_LIST_URL),
      final response = await  rootBundle.loadString("assets/json/faqs.json");

        // headers: {
        //   "Content-Type": "application/json",
        // },

      // );
      jsonmap = response;
      faq =  Faq.fromJson(jsonDecode(jsonmap));
      return faq!;
    } catch (e)
    {
      if (faq != null) return faq!;
      throw Exception("Asset Error");
    }
  }
    
}
