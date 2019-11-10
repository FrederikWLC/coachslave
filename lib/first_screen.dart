import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'sign_in.dart';
import 'subscribe_page.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'coach_me/coachme_v2.dart';

// Database reference
final databaseReference = FirebaseDatabase.instance.reference();

class FirstScreen extends StatelessWidget {

  Future<bool> userIsSubscribed() async {
    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    if (purchaserInfo.entitlements.all["coachslave_full_potential"].isActive) {
      return true;
    }
    return null;
  }

  Widget _buildChild(BuildContext context){

    if (userIsSubscribed() != null) {
      // Grant user "Full Potential" access
      return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
    CircleAvatar(
    backgroundImage: NetworkImage(
    imageUrl,
    ),
    radius: 60,
    backgroundColor: Colors.transparent,
    ),
    SizedBox(height: 40),
    Text(
    'NAME',
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black54),
    ),
    Text(
    name,
    style: TextStyle(
    fontSize: 25,
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 20),
    Text(
    'EMAIL',
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black54),
    ),
    Text(
    email,
    style: TextStyle(
    fontSize: 25,
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 40),
    RaisedButton(
    onPressed: () {
    signOutGoogle();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
    },
    color: Colors.deepPurple,
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
    'Sign Out',
    style: TextStyle(fontSize: 25, color: Colors.white),
    ),
    ),
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(40)),
    ),
    SizedBox(height: 50),
    RaisedButton(
    onPressed: () {
    Navigator.of(context).push(
    MaterialPageRoute(
    builder: (context) {
    return CoachPage();
    },
    ),
    );
    },
    color: Colors.purple,
    child: Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
    'Coach me',
    style: TextStyle(fontSize: 40, color: Colors.white),
    ),
    ),
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(40)),
    )
    ],
    ),
    );
    }
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
    CircleAvatar(
    backgroundImage: NetworkImage(
    imageUrl,
    ),
    radius: 60,
    backgroundColor: Colors.transparent,
    ),
    SizedBox(height: 40),
    Text(
    'NAME',
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black54),
    ),
    Text(
    name,
    style: TextStyle(
    fontSize: 25,
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 20),
    Text(
    'EMAIL',
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black54),
    ),
    Text(
    email,
    style: TextStyle(
    fontSize: 25,
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 40),
    RaisedButton(
    onPressed: () {
    signOutGoogle();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
    },
    color: Colors.deepPurple,
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
    'Sign Out',
    style: TextStyle(fontSize: 25, color: Colors.white),
    ),
    ),
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(40)),
    ),
    SizedBox(height: 50),
    RaisedButton(
    onPressed: () {
    Navigator.of(context).push(
    MaterialPageRoute(
    builder: (context) {
    return SubscribePage();
    },
    ),
    );
    },
    color: Colors.green,
    child: Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
    'Subscribe',
    style: TextStyle(fontSize: 40, color: Colors.white),
    ),
    ),
    elevation: 5,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(40)),
    )
    ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100], Colors.blue[400]],
          ),
        ),
      child: _buildChild(context)
      ),
    );
  }
}