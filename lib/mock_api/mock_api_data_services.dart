class MockApi {
  getProfileMockData() {
    return {
      "data": {
        "profile": {
          "phone": "00000000",
          "photo": "",
          "email": "profile@gmail.com",
          "insuree": {
            "lastName": "None",
            "otherNames": "None",
            "dob": "2000-01-01",
            "validityTo": null
          }
        }
      }
    };
  }


  openimis_gql_insuree_claims(){
    return {
      """
      {
        "data": {
          "insureeProfile": {
            "insureeClaim": [
              {
                "id": "5998091",
                "dateClaimed": "2020-04-10",
                "claimed": 334.96,
                "status": 16,
                "healthFacility": {
                  "name": "Seti Zonal Hospital"
                }
              },
              {
                "id": "9417605",
                "dateClaimed": "2021-03-22",
                "claimed": 3024,
                "status": 4,
                "healthFacility": {
                  "name": "Seti Zonal Hospital"
                }
              },
              {
                "id": "9874789",
                "dateClaimed": "2021-04-18",
                "claimed": 400,
                "status": 4,
                "healthFacility": {
                  "name": "Tribhuvan University Teaching Hospital"
                }
              }
            ]
          }
        }
      }
      """
    };
  }



  openimis_gql_insuree_info() {
    return {
      """
      {
        "data": {
          "profile": {
            "phone": "1111111111",
            "email": "birendrasaid@openimis.gov.np",
            "photo": "http://192.168.15.22/media/insuree/photo/jpt_IVQ21XR.jpg",
            "remainingDays": "-1058",
            "insuree": {
              "insureePolicies": [
                {
                  "policy": {"value": 4200, "expiryDate": "2019-05-14"}
                },
                {
                  "policy": {"value": 6300, "expiryDate": "2020-11-15"}
                },
                {
                  "policy": {"value": 3500, "expiryDate": "2021-11-16"}
                }
              ],
              "claimSet": [
                {"status": 16, "claimed": 334.96, "approved": null},
                {"status": 4, "claimed": 3024, "approved": null},
                {"status": 4, "claimed": 400, "approved": null}
              ],
              "otherNames": "BIRENDRA",
              "lastName": "SAUD",
              "dob": "2002-04-07",
              "currentAddress": "",
              "validityTo": null,
              "healthFacility": {"name": "Seti Zonal Hospital"}
            }
          }
        }
      }
      """
    };
  }
}
