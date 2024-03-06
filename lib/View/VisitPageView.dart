import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Utils/StyleData.dart';
import '../login1.dart';
import 'NewLeadPageView.dart';
import 'formPageVIiew.dart';

class VisitPageView extends StatefulWidget {
  String? accessToken;
 // String? customerStatus;
   VisitPageView({Key? key,this.accessToken}) : super(key: key);

  @override
  State<VisitPageView> createState() => _VisitPageViewState();
}

class _VisitPageViewState extends State<VisitPageView> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var userType;
  TextEditingController searchKEY = TextEditingController();
  List<DocumentSnapshot> searchListOfLeads = [];
  List<DocumentSnapshot> filteredListOfLeads = [];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();


  bool isleadConverted = false;

  final List<String> _vistType= [
    'DSA',
    'Customer',
  ];
  String? _selectedVisitType;
  List<String> selectedVisitList = [];


  final List<String> _scheduledDate= [
    'Today',
    'Custome',
  ];
  String? _selectedScheduledDate;

  List<DocumentSnapshot> ListOfLeads = [];
  List<DocumentSnapshot> ListOfConvertedLeads = [];


  UnderlineInputBorder enb =  UnderlineInputBorder(
    //  borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color:  Colors.black38)
  );
  UnderlineInputBorder focus =  UnderlineInputBorder(
    //  borderRadius: BorderRadius.circular(10),
      borderSide:  const BorderSide(color: Color(0xff778287))
  );





  void fetchdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('LeadCreation');
    SharedPreferences pref = await SharedPreferences.getInstance();
    // var userId = pref.getString("token");
    var userId = pref.getString("userID");
    print("userIDlkkk");
    print("userId");
    setState(() {
      userType = pref.getString("logintype");
    });
    print(userType);
    if (userType == "user") {
      users.where("userId", isEqualTo: userId).get().then((value) {
        setState(() {
          ListOfLeads = value.docs;
        });
        for (var i = 0; value.docs.length > i; i++) {
          print(value.docs[i].data());
        }
      });
    } else {
      users.get().then((value) {
        setState(() {
          ListOfLeads = value.docs;
        });
        for (var i = 0; value.docs.length > i; i++) {
          print(value.docs[i].data());
        }
      });
    }
  }

  void fetchLeadsdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
   // var userId = pref.getString("token");
    var userId = pref.getString("userID");
    setState(() {
      userType = pref.getString("logintype");
    });
    print(userType);
    if (userType == "user") {
      users.where("userId", isEqualTo: userId).get().then((value) {
        setState(() {
          ListOfConvertedLeads = value.docs;

        });
        for (var i = 0; value.docs.length > i; i++) {
          print(value.docs[i].data());
        }
      });
    } else {
      users.get().then((value) {
        setState(() {
          ListOfConvertedLeads = value.docs;
        });
        for (var i = 0; value.docs.length > i; i++) {
          print(value.docs[i].data());
        }

      });
    }
  }




  String formatDate(String dateString) {
    try {
      // Assuming dateString is in the format 'yyyy-MM-dd HH:mm:ss.SSS'
      DateTime date = DateTime.parse(dateString);

      final formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date);
    } catch (e) {
      print("Error parsing date: $e");
      return " --";
    }
  }

  void _runFilter(String enteredKeyword) {
    var data = ListOfLeads.where((row) => (row["firstName"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase())|| row["purposeVisit"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase()) ||
        row["LeadID"]
            .toString()
            .toUpperCase()
            .contains(enteredKeyword.toUpperCase()) || row["leadSource"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase()))).toList();
    setState(() {
      searchListOfLeads = data;
    });
  }

  List<DocumentSnapshot> filteredList = [];


  void filterData() {
    print("Filtering");

    filteredList = ListOfLeads
        .where((item) {
      DateTime visitDate = DateTime.parse(item["visitDate"]);
      return visitDate.isAfter(fromDate) && visitDate.isBefore(toDate);
    })
        .toList();
  }


  void clearFilter() {
    filteredList.clear();
  }

  Future<void> _selectDate(BuildContext context, int type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
              primaryColor: Colors.white,
              dialogBackgroundColor: Colors.white,
              hintColor: Colors.white,
              colorScheme: ColorScheme.light(
                  primary: StyleData.buttonColor, background: Colors.white),
              buttonTheme:
              const ButtonThemeData(textTheme: ButtonTextTheme.primary),
              backgroundColor: Colors.white),
          child: child!,
        );
      },
    );

    if (picked != null && picked != (type == 1 ? fromDate : toDate)) {
      setState(() {
        if (type == 1) {
          // _selectedDate.toLocal().toString().split(' ')[0];

          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }




  @override
  void initState() {
    // TODO: implement initState
    fetchdata();
    fetchLeadsdata();
    print("Access token");
    print(widget.accessToken);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Container(
            height: height * 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.015,
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child:
                          const Icon(Icons.arrow_back, color: Colors.black54)),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      Text("Filter by",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: StyleData.boldFont,
                              color: Colors.black54)),
                    //  const Spacer(),
                      // SizedBox(
                      //     height: 24,
                      //     child: Image.asset("assets/images/filter_icon.png")),
                      SizedBox(
                        width: width * 0.01,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  const Text(
                    "From & To Date",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          _selectDate(context, 1);
                        },
                        child: Container(
                          height: 40,
                          width: width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formatDate(fromDate.toLocal().toString()),
                                style: TextStyle(color: Colors.black87, fontSize: 13),
                              ),
                              SizedBox(
                                width: width * 0.02,
                              ),
                              Icon(
                                Ionicons.calendar_outline,
                                color: StyleData.appBarColor2,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: width * 0.01,
                      // ),
                      InkWell(
                        onTap: () {
                          _selectDate(context, 2);
                        },
                        child: Container(
                          height: 40,
                          width: width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formatDate(toDate.toLocal().toString()),
                                style: TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              SizedBox(
                                width: width * 0.02,
                              ),
                              Icon(
                                Ionicons.calendar_outline,
                                color: StyleData.appBarColor2,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height * 0.035,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          clearFilter();
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          width: width * 0.3,
                          decoration: BoxDecoration(
                            // color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                              border:
                              Border.all(color: Colors.black26, width: 0.5)),
                          child: const Center(
                            child: Text(
                              "Reset",
                              style: TextStyle(color: Colors.black, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          filterData();
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          width: width * 0.3,
                          decoration: BoxDecoration(
                              color: StyleData.buttonColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Center(
                            child: Text(
                              "Apply",
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.006,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: height * 0.08,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: StyleData.appBarColor2,
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(20.0),
                  //   bottomRight: Radius.circular(20.0),
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SizedBox(
                    //   width: width * 0.00,
                    // ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                            onTap: (){
                              // SimpleHiddenDrawerController.of(context).open();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FormPageView(),
                                ),
                              );
                            },
                            child:  Image.asset(
                              'assets/images/add.png',
                              width: width * 0.1,
                            ),),
                ),
                    Text("Visits",style: TextStyle(color: Colors.white,fontSize: 18,fontFamily: StyleData.boldFont),),
      
      
                Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: width * 0.05,
                            ),
                            Container(
                              width: width * 0.08,
                              height: height * 0.036,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white24,
                              ),
                              child: Center(
                                child: Text(
                                  searchKEY.text.isEmpty
                                      ? ListOfLeads.length.toString()
                                      : searchListOfLeads.length.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),

              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchKEY,
                    style: const TextStyle(fontSize: 14,color: Colors.black54),
                    cursorColor: Colors.black87,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black54
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color:Colors.black54)),
                      contentPadding: const EdgeInsets.only(left: 1,),
                      hintStyle: const TextStyle(fontSize: 14,color: Colors.black54),
                    //   suffixIcon: IconButton(
                    //      icon:    SizedBox(
                    //      //  height: 60,
                    //        child: Image.asset(
                    //          'assets/images/filter.png',
                    //          width: width * 0.06,
                    //          height: height * 0.02,
                    //          color: Colors.black87
                    //        ),
                    //      ),
                    //       onPressed: () {
                    //      //   _showFilterBottomSheet();
                    //         _scaffoldKey.currentState!.openDrawer();
                    // },
                    //   ),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: new BorderSide(color: Colors.grey)),
                    ),
                    onChanged: (value) {
                      _runFilter(value);
                    },
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
      
              SizedBox(
                height: height * 0.65,
                width: MediaQuery.of(context).size.width,
                child:ListOfLeads.isNotEmpty ?
                Scrollbar(
                  thickness: 8.5,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  controller: ScrollController(),
                  child: ListView.builder(
                    itemCount: searchKEY.text.isEmpty
                        ? ListOfLeads.length
                        : searchListOfLeads.length,
                    itemBuilder: (context, index) {
                      ListOfLeads.sort((a, b) =>
                          (b['createdDateTime'] as Timestamp).compareTo(a['createdDateTime'] as Timestamp));
                      // ListOfLeads.sort((a, b) => DateTime.parse(b['createdDateTime']).compareTo(DateTime.parse(a['createdDateTime'])));

                      return
                        (ListOfLeads[index]["LeadID"] ?? "").length <= 1 &&  ListOfLeads[index]["customerStatus"] == "Interested"  ?
                        InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewLeadPageView(
                                    isNewActivity: false,
                                    isUpdateActivity: true,
                                    docId: ListOfLeads[index].id,
                                  )));
                        },
                        child: Card(
                          elevation: 0.5,
                          child: Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Name : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                           )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["firstName"] + " " + ListOfLeads[index]["lastName"]
                                              : searchListOfLeads[index]
                                          ["firstName"],
                                            style: TextStyle(fontSize: 16, color: StyleData.appBarColor,decoration: TextDecoration.underline,decorationColor: StyleData.appBarColor, // Optional: Set the underline color
                                            decorationThickness: 1.0, decorationStyle: TextDecorationStyle.solid,)),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month),
                                          Text("Visit Date :", style: TextStyle(fontSize: 15, color: Colors.blueGrey, )),
                                          Text(searchKEY.text.isEmpty
                                              ?
                                          formatDate(ListOfLeads[index]["visitDate"])
                                              :
                                          formatDate(searchListOfLeads[index]
                                          ["visitDate"])
                                                 ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Visibility(
                                         visible: ListOfLeads[index]["LeadID"] != null,
                                        child: Row(
                                          children: [
                                            Text("Lead ID : ",
                                                style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                                )),
                                            Text(searchKEY.text.isEmpty
                                                ? ListOfLeads[index]["LeadID"] ?? ""
                                                : searchListOfLeads[index]
                                            ["LeadID"] ?? "",
                                                style: TextStyle(fontSize: 16, color: Colors.black87,)),
                                          ],
                                        ),
                                      ) ,
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text("Customer Status : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["customerStatus"] ?? ""
                                              : searchListOfLeads[index]
                                          ["customerStatus"] ?? "",
                                              style: TextStyle(fontSize: 16, color: Colors.black,)),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text("Lead Source       : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["leadSource"] ?? ""
                                              : searchListOfLeads[index]
                                          ["leadSource"] ?? "",
                                              style: TextStyle(fontSize: 16, color: Colors.black,)),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text("Purpose of Visit : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["purposeVisit"] ?? ""
                                              : searchListOfLeads[index]
                                          ["purposeVisit"] ?? "",
                                              style: TextStyle(fontSize: 16, color: Colors.black,)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 20,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/next.png',
                                          width: 35,
                                        ),
                                        Text(
                                          'Convert',
                                          style: TextStyle(fontSize: 12,color: StyleData.appBarColor,fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ) :
                        Card(
                          elevation: 0.5,
                          child: Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Name : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["firstName"] + " " + ListOfLeads[index]["lastName"]
                                              : searchListOfLeads[index]
                                          ["firstName"],
                                              style: TextStyle(fontSize: 16, color: StyleData.appBarColor,decoration: TextDecoration.underline,decorationColor: StyleData.appBarColor, // Optional: Set the underline color
                                                decorationThickness: 1.0, decorationStyle: TextDecorationStyle.solid,)),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month),
                                          Text("Visit Date :", style: TextStyle(fontSize: 15, color: Colors.blueGrey, )),
                                          Text(searchKEY.text.isEmpty
                                              ?
                                          formatDate(ListOfLeads[index]["visitDate"])
                                              :
                                          formatDate(searchListOfLeads[index]
                                          ["visitDate"])
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Visibility(
                                        visible: ListOfLeads[index]["LeadID"] != null,
                                        child: Row(
                                          children: [
                                            Text("Lead ID : ",
                                                style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                                )),
                                            Text(searchKEY.text.isEmpty
                                                ? ListOfLeads[index]["LeadID"] ?? ""
                                                : searchListOfLeads[index]
                                            ["LeadID"] ?? "",
                                                style: TextStyle(fontSize: 16, color: StyleData.appBarColor2,)),
                                          ],
                                        ),
                                      ) ,
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text("Customer Status : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["customerStatus"] ?? ""
                                              : searchListOfLeads[index]
                                          ["customerStatus"] ?? "",
                                              style: TextStyle(fontSize: 16, color: Colors.black,)),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text("Lead Source       : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["leadSource"] ?? ""
                                              : searchListOfLeads[index]
                                          ["leadSource"] ?? "",
                                              style: TextStyle(fontSize: 16, color: Colors.black,)),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text("Purpose of Visit : ",
                                              style: TextStyle(fontSize: 15, color: Colors.blueGrey, // Optional: Set the underline color
                                              )),
                                          Text(searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["purposeVisit"] ?? ""
                                              : searchListOfLeads[index]
                                          ["purposeVisit"] ?? "",
                                              style: TextStyle(fontSize: 16, color: Colors.black,)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ListOfLeads[index]["customerStatus"] == "Interested" ?
                                  Positioned(
                                    top: 10,
                                    right: 20,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/Correct.png',
                                          width: 30,
                                        ),
                                      ],
                                    ),
                                  ) :
                                  Positioned(
                                    top: 10,
                                    right: 20,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/notInterested.png',
                                          width: 30,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                    },
                  ),
                )
                    : Center(
                      child: const Text(
                                      'No results found',
                                      style: TextStyle(fontSize: 24),
                                    ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }




}
class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>)? onSelectionChanged;
  final Function(List<String>)? onMaxSelected;
  final int? maxSelection;

  MultiSelectChip(this.reportList,
      {this.onSelectionChanged, this.onMaxSelected, this.maxSelection});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          backgroundColor: Colors.white30,
          side: const BorderSide(color: Colors.black12),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          label: Text(
            item,
           // style: TextStyle(color: textColor, fontSize: 13),
          ),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            if (selectedChoices.length == (widget.maxSelection ?? -1) &&
                !selectedChoices.contains(item)) {
              widget.onMaxSelected?.call(selectedChoices);
            } else {
              setState(() {
                selectedChoices.contains(item)
                    ? selectedChoices.remove(item)
                    : selectedChoices.add(item);
                widget.onSelectionChanged?.call(selectedChoices);
              });
            }
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

// void _showFilterBottomSheet() {
//   final height = MediaQuery.of(context).size.height;
//   final width = MediaQuery.of(context).size.width;
//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext context) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           color: Colors.white,
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 height: height * 0.015,
//               ),
//               const Text(
//                 "From & To Date",
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600),
//               ),
//               SizedBox(
//                 height: height * 0.01,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       _selectDate(context, 1);
//                     },
//                     child: Container(
//                       height: 40,
//                       width: width * 0.35,
//                       decoration: BoxDecoration(
//                         color: Colors.white30,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.black12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             formatDate(fromDate.toLocal().toString()),
//                             style: TextStyle(color: Colors.black87, fontSize: 13),
//                           ),
//                           SizedBox(
//                             width: width * 0.02,
//                           ),
//                           Icon(
//                             Ionicons.calendar_outline,
//                             color: StyleData.appBarColor2,
//                             size: 20,
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   // SizedBox(
//                   //   width: width * 0.01,
//                   // ),
//                   InkWell(
//                     onTap: () {
//                       _selectDate(context, 2);
//                     },
//                     child: Container(
//                       height: 40,
//                       width: width * 0.35,
//                       decoration: BoxDecoration(
//                         color: Colors.white30,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.black12),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                              formatDate(toDate.toLocal().toString()),
//                             style: TextStyle(color: Colors.black, fontSize: 13),
//                           ),
//                           SizedBox(
//                             width: width * 0.02,
//                           ),
//                           Icon(
//                             Ionicons.calendar_outline,
//                             color: StyleData.appBarColor2,
//                             size: 20,
//                           )
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               SizedBox(
//                 height: height * 0.035,
//               ),
//               Row(
//                 children: [
//                   const Spacer(),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Container(
//                       height: 40,
//                       width: width * 0.3,
//                       decoration: BoxDecoration(
//                         // color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(20),
//                           border:
//                           Border.all(color: Colors.black26, width: 0.5)),
//                       child: const Center(
//                         child: Text(
//                           "Reset",
//                           style: TextStyle(color: Colors.black, fontSize: 13),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: width * 0.02,
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Container(
//                       height: 40,
//                       width: width * 0.3,
//                       decoration: BoxDecoration(
//                           color: StyleData.buttonColor,
//                           borderRadius: BorderRadius.circular(20)),
//                       child: const Center(
//                         child: Text(
//                           "Apply",
//                           style: TextStyle(color: Colors.white, fontSize: 13),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: width * 0.006,
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: height * 0.02,
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }