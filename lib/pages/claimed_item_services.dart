import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:openimis_web_app/models/claimeditems.dart';
import 'package:openimis_web_app/models/claimedservices.dart';
import 'package:openimis_web_app/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:openimis_web_app/common/env.dart' as env;
import 'package:openimis_web_app/services/api_graphql_services.dart';


class ClaimedItemServicesPage extends StatefulWidget {
    final int claimId;
    final String token;
    ClaimedItemServicesPage({Key? key, required this.claimId, required this.token}) : super(key: key);
    @override
    _ClaimedItemServicesPageState createState() =>
        _ClaimedItemServicesPageState();
}

class _ClaimedItemServicesPageState extends State<ClaimedItemServicesPage> {
    bool hasNotification = false;
    late Future<ClaimedServices> _claimedServices;
    late Future<ClaimedItems> _claimedItems;
    
    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        _claimedServices = ApiGraphQlServices().ClaimedServicesServicesGQL(widget.token, widget.claimId);
        _claimedItems = ApiGraphQlServices().ClaimedItemServicesGQL(widget.token, widget.claimId);
    }
    
    void _showFeedbackBottomSheet() async {
        final _formKey = GlobalKey<FormState>();
        String feedbackDetails = "";
        int rating = 5;
        String source = "Mobile App";
        DateTime feedbackDate = DateTime.now();

        bool cardRendered = false;
        bool paymentAsked = false;
        bool drugPrescribed = false;
        bool drugReceived = false;

        // Attempt to pre-set drugPrescribed based on items list
        try {
            final itemsData = await _claimedItems;
            if (itemsData.data.insureeClaim.isNotEmpty && itemsData.data.insureeClaim[0].items.isNotEmpty) {
                drugPrescribed = true;
            }
        } catch (e) {
            print("Could not pre-fetch items for feedback: $e");
        }

        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (context, setModalState) {
                        return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                ),
                            ),
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                                left: 24,
                                right: 24,
                                top: 12,
                            ),
                            child: SingleChildScrollView(
                                child: Form(
                                    key: _formKey,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            // Handle
                                            Container(
                                                width: 40,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(2),
                                                ),
                                            ),
                                            SizedBox(height: 24),
                                            Text(
                                                'Give Your Feedback',
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: CustomTheme.lightTheme.primaryColor,
                                                ),
                                            ),
                                            SizedBox(height: 24),
                                            
                                            // Checklist section
                                            _buildChecklistTile('Card rendered', cardRendered, (val) {
                                                setModalState(() => cardRendered = val!);
                                            }),
                                            _buildChecklistTile('Payment asked', paymentAsked, (val) {
                                                setModalState(() => paymentAsked = val!);
                                            }),
                                            _buildChecklistTile('Drug prescribed', drugPrescribed, (val) {
                                                setModalState(() => drugPrescribed = val!);
                                            }),
                                            _buildChecklistTile('Drug received', drugReceived, (val) {
                                                setModalState(() => drugReceived = val!);
                                            }),
                                            
                                            SizedBox(height: 16),

                                            // Rating Stars
                                            Text(
                                                'How would you rate this service?',
                                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: List.generate(5, (index) {
                                                    return IconButton(
                                                        icon: Icon(
                                                            index < rating ? Icons.star : Icons.star_border,
                                                            color: Colors.amber,
                                                            size: 36,
                                                        ),
                                                        onPressed: () {
                                                            setModalState(() {
                                                                rating = index + 1;
                                                            });
                                                        },
                                                    );
                                                }),
                                            ),
                                            SizedBox(height: 24),

                                            TextFormField(
                                                decoration: InputDecoration(
                                                    labelText: 'Feedback Details',
                                                    alignLabelWithHint: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    hintText: 'Share your thoughts about this claim...',
                                                ),
                                                maxLines: 4,
                                                onChanged: (value) => feedbackDetails = value,
                                                validator: (value) => value!.isEmpty ? 'Please enter some details' : null,
                                            ),
                                            SizedBox(height: 16),
                                            
                                            TextFormField(
                                                initialValue: source,
                                                decoration: InputDecoration(
                                                    labelText: 'Source',
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                    ),
                                                ),
                                                onChanged: (value) => source = value,
                                            ),
                                            SizedBox(height: 24),
                                            
                                            Row(
                                                children: [
                                                    Expanded(
                                                        child: TextButton(
                                                            child: Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                                                            onPressed: () => Navigator.of(context).pop(),
                                                        ),
                                                    ),
                                                    Expanded(
                                                        child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: CustomTheme.lightTheme.primaryColor,
                                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(12),
                                                                ),
                                                            ),
                                                            child: Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
                                                            onPressed: () async {
                                                                if (_formKey.currentState!.validate()) {
                                                                    Navigator.of(context).pop();
                                                                    try {
                                                                        await ApiGraphQlServices().createClaimFeedback(
                                                                            widget.token,
                                                                            feedbackDetails,
                                                                            rating,
                                                                            source,
                                                                            feedbackDate.toIso8601String(),
                                                                            widget.claimId,
                                                                            cardRendered,
                                                                            paymentAsked,
                                                                            drugPrescribed,
                                                                            drugReceived
                                                                        );
                                                                        Fluttertoast.showToast(
                                                                            msg: "Feedback submitted successfully",
                                                                            backgroundColor: Colors.green,
                                                                            textColor: Colors.white,
                                                                        );
                                                                    } catch (e) {
                                                                        Fluttertoast.showToast(
                                                                            msg: "Error: $e",
                                                                            backgroundColor: Colors.red,
                                                                            textColor: Colors.white,
                                                                        );
                                                                    }
                                                                }
                                                            },
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            SizedBox(height: 32),
                                        ],
                                    ),
                                ),
                            ),
                        );
                    }
                );
            }
        );
    }

    Widget _buildChecklistTile(String label, bool value, Function(bool?) onChanged) {
        return CheckboxListTile(
            title: Text(label, style: TextStyle(fontSize: 16)),
            value: value,
            onChanged: onChanged,
            activeColor: CustomTheme.lightTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: CustomTheme.lightTheme.primaryColor,
            appBar: AppBar(
                elevation: 0.0,
                title: Text(
                    'Claimed Item Services',
                    style: TextStyle(color: Colors.white),
                ),
                backgroundColor: CustomTheme.lightTheme.primaryColor,
            ),
            body: Column(
                children: [
                    Expanded(
                        child: Container(
//                            height: screenHeight(context, dividedBy: 1),
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                    Container(
                                        padding: EdgeInsets.only(left:8.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.25)))),
                                        width: double.infinity,
                                        child: Text(
                                            'Items',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                    ),
                                    SizedBox(height: 8.0),
                                    _claimItemListWidget(),
                                    Container(
                                        padding: EdgeInsets.only(left:8.0, top: 16.0, bottom: 8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.25)))),
                                        width: double.infinity,
                                        child: Text(
                                            'Services',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                    ),
                                    SizedBox(height: 8.0),
                                    _claimServicesListWidget(),
                                ],
                            ),
                            ),
                        ),
                    ),
                ],
            ),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: _showFeedbackBottomSheet,
                label: Text('Give Feedback'),
                icon: Icon(Icons.feedback),
                backgroundColor: CustomTheme.lightTheme.primaryColor,
            ),
        );
    }
    
    Widget _claimItemListWidget(){
        return Container(
            child: FutureBuilder<ClaimedItems>(
                future: _claimedItems,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        if (snapshot.data!.data.insureeClaim.isEmpty || snapshot.data!.data.insureeClaim[0].items.isEmpty) {
                            return Center(child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No items claimed"),
                            ));
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.data
                                .insureeClaim[0].items.length,
                            itemBuilder: (BuildContext context,
                                int index) {
                                var item = snapshot
                                    .data
                                    !.data
                                    .insureeClaim[0]
                                    .items[index];
                                return Container(
                                    child: ListTile(
                                        title: Text(
                                            '${item.item.name}',
                                            style: TextStyle(
                                                fontSize: 14.4,
                                                fontWeight: FontWeight.normal
                                            ),
                                        ),
                                        subtitle: Text(
                                            'Quantity: ${item.qtyProvided}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey[700]
                                            ),
                                        ),
                                        trailing: Text(
                                            '${env.Currency} ' + '${item.item.price.toString()}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: CustomTheme.lightTheme.primaryColor
                                            ),
                                        ),
                                    ),
                                );
                            });
                    } else if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Error: ${snapshot.error}"),
                            ),
                        );
                    } else {
                        return Center(
                            child: CircularProgressIndicator());
                    }
                }),
        );
    }
    
    Widget _claimServicesListWidget(){
        return Container(
            // height: screenHeight(context, dividedBy: 2),
            child: FutureBuilder<ClaimedServices>(
                future: _claimedServices,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        if (snapshot.data!.data.insureeClaim.isEmpty || snapshot.data!.data.insureeClaim[0].services.isEmpty) {
                            return Center(child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No services claimed"),
                            ));
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot
                                .data!.data.insureeClaim[0].services.length,
                            itemBuilder: (BuildContext context, int index) {
                                var service = snapshot
                                    .data!.data.insureeClaim[0].services[index];
                                return Container(
                                    child: ListTile(
                                        title: Text(
                                            '${service.service.name}',
                                            style: TextStyle(
                                                fontSize: 14.4,
                                                fontWeight: FontWeight.normal
                                            ),
                                        ),
                                        subtitle: Text(
                                            'Quantity/Days: ${service.qtyProvided}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey[700]
                                            ),
                                        ),
                                        trailing: Text(
                                            '${env.Currency} ' + '${service.service.price.toString()}',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: CustomTheme.lightTheme.primaryColor
                                            ),
                                        ),
                                    ),
                                );
                            });
                    } else if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Error: ${snapshot.error}"),
                            ),
                        );
                    } else {
                        return Center(
                            child: CircularProgressIndicator()
                        );
                    }
                }),
        );
    }
}
