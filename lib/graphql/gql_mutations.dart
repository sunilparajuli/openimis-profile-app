class openimisGQLMutation {
  createFeedbackMutation(String fullname, String email, String mobileNo, String queries) {
    return {
      "query": """
        mutation {
          createFeedback(fullname: \"$fullname\", emailAddress: \"$email\", mobileNumber: \"$mobileNo\", queries: \"$queries\") {
            feedback {
              fullname
              mobileNumber
              emailAddress
              queries
            }
          }
        }
      """,
      "variables": null
    };
  }

  createClaimFeedbackMutation(String feedbackDetails, int rating, String source, String feedbackDate, int claimId, bool cardRendered, bool paymentAsked, bool drugPrescribed, bool drugReceived) {
    return {
      "query": r'''
        mutation CreateClaimFeedback($details: String!, $rating: Int!, $source: String!, $date: DateTime!, $claimId: Int!, $cardRendered: Boolean!, $paymentAsked: Boolean!, $drugPrescribed: Boolean!, $drugReceived: Boolean!) {
          createClaimFeedback(
            feedbackDetails: $details, 
            rating: $rating, 
            source: $source, 
            feedbackDate: $date, 
            claimId: $claimId,
            cardRendered: $cardRendered,
            paymentAsked: $paymentAsked,
            drugPrescribed: $drugPrescribed,
            drugReceived: $drugReceived
          ) {
            ok
            message
          }
        }
      ''',
      "variables": {
        "details": feedbackDetails,
        "rating": rating,
        "source": source,
        "date": feedbackDate,
        "claimId": claimId,
        "cardRendered": cardRendered,
        "paymentAsked": paymentAsked,
        "drugPrescribed": drugPrescribed,
        "drugReceived": drugReceived
      }
    };
  }
}
