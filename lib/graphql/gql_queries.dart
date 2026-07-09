class OpenimisGqlQueries {
  static Map<String, dynamic> medicalServices(int first) {
    if (first > 0) {
      return {
        "query": r'''
          query MedicalServicesQuery($first: Int!) {
            medicalServicesStr(first: $first) {
              edges {
                node {
                  id
                  name
                }
              }
            }
          }
        ''',
        "variables": {"first": first}
      };
    } else {
      return {
        "query": r'''
          query MedicalServicesQuery {
            medicalServicesStr {
              edges {
                node {
                  id
                  name
                }
              }
            }
          }
        ''',
        "variables": null
      };
    }
  }

  static Map<String, dynamic> insureeClaims(String chfid) {
    return {
      "query": r'''
        query InsureeClaimsQuery($chfid: String!) {
          insureeProfile(insureeCHFID: $chfid) {
            insureeClaim {
              id
              dateClaimed
              claimed
              status
              healthFacility {
                name
              }
            }
          }
        }
      ''',
      "variables": {"chfid": chfid}
    };
  }

  static Map<String, dynamic> insureeClaimedServices(int claimId) {
    return {
      "query": r'''
        query ClaimedServicesQuery($claimId: Int!) {
          insureeClaim(claimId: $claimId) {
            services {
              id
              qtyProvided
              qtyApproved
              service {
                id
                name
                price
              }
            }
          }
        }
      ''',
      "variables": {"claimId": claimId}
    };
  }

  static Map<String, dynamic> insureeClaimedItems(int claimId) {
    return {
      "query": r'''
        query ClaimedItemsQuery($claimId: Int!) {
          insureeClaim(claimId: $claimId) {
            items {
              id
              qtyProvided
              qtyApproved
              item {
                id
                name
                price
              }
            }
          }
        }
      ''',
      "variables": {"claimId": claimId}
    };
  }

  static Map<String, dynamic> healthFacilityCoordinate(Map<String, dynamic> args) {
    return {
      "query": r'''
        query HealthFacilityCoordinateQuery($inputLatitude: Decimal, $inputLongitude: Decimal) {
          healthFacilityCoordinate(inputLatitude: $inputLatitude, inputLongitude: $inputLongitude) {
            id
            distance
            healthFacility {
              id
              name
            }
          }
        }
      ''',
      "variables": {
        "inputLatitude": args['inputLatitude']?.toString(),
        "inputLongitude": args['inputLongitude']?.toString()
      }
    };
  }

  static Map<String, dynamic> insureePolicyInformation(String chfid) {
    return {
      "query": r'''
        query InsureePolicyInformationQuery($chfid: String!) {
          insureeProfile(insureeCHFID: $chfid) {
            chfId
            lastName
            otherNames
            insureePolicies {
              policy {
                value
                startDate
                enrollDate
                expiryDate
                status
              }
              insuree {
                gender {
                  code
                  gender
                }
                dob
                healthFacility {
                  code
                  name
                }
              }
            }
          }
        }
      ''',
      "variables": {"chfid": chfid}
    };
  }

  static Map<String, dynamic> insureePolicyInformationLists(String chfid) {
    return {
      "query": r'''
        query InsureePolicyInformationListsQuery($chfid: String!) {
          insureeProfile(insureeCHFID: $chfid) {
            chfId
            lastName
            otherNames
            insureePolicies {
              policy {
                id
                value
                startDate
                enrollDate
                expiryDate
                status
                product {
                  name
                }
              }
              insuree {
                gender {
                  code
                  gender
                }
                dob
                healthFacility {
                  code
                  name
                }
              }
            }
          }
        }
      ''',
      "variables": {"chfid": chfid}
    };
  }

  static Map<String, dynamic> notices() {
    return {
      "query": r'''
        query NoticesQuery {
          notices(orderBy: ["-created_at"]) {
            edges {
              node {
                id
                title
                description
              }
            }
          }
        }
      ''',
      "variables": null
    };
  }

  static Map<String, dynamic> insureeInfo(String chfid) {
    return {
      "query": r'''
        query InsureeInfoQuery($chfid: String!) {
          profile(insureeCHFID: $chfid) {
            phone
            email
            photo
            remainingDays
            insuree {
              insureePolicies {
                policy {
                  value
                  expiryDate
                }
              }
              otherNames
              lastName
              dob
              currentAddress
              validityTo
              healthFacility {
                name
              }
            }
          }
        }
      ''',
      "variables": {"chfid": chfid}
    };
  }

  static Map<String, dynamic> notifications(String chfid) {
    return {
      "query": r'''
        query NotificationsQuery($chfid: String!) {
          notifications(insureeCHFID: $chfid) {
            edges {
              node {
                message
                createdAt
              }
            }
          }
        }
      ''',
      "variables": {"chfid": chfid}
    };
  }

  static Map<String, dynamic> profile(String chfid) {
    return {
      "query": r'''
        query ProfileQuery($chfid: String!) {
          profile(insureeCHFID: $chfid) {
            phone
            email
            photo
            insuree {
              otherNames
              lastName
              dob
              currentAddress
              validityTo
            }
          }
        }
      ''',
      "variables": {"chfid": chfid}
    };
  }

  static Map<String, dynamic> otpVerify(Map<String, dynamic> args) {
    return {
      "query": r'''
        query OtpVerifyQuery($chfid: String!, $otp: String!) {
          insureeAuthOtp(chfid: $chfid, otp: $otp) {
            token
            insuree {
              chfId
            }
          }
        }
      ''',
      "variables": {
        "chfid": args['chfid'].toString(),
        "otp": args['otp'].toString()
      }
    };
  }
}
