import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';

class SubscribePage extends StatelessWidget {

  Future displayAvailableProducts() async {
    try {
      Map<String, Entitlement> entitlements = await Purchases.getEntitlements();
    } on PlatformException catch(e) {

    }
  }

   showError(e) {

  }

  Future makePurchase(product) async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.makePurchase(product.identifier);
      var isPro = purchaserInfo.entitlements.all[product.identifier].isActive;
      if (isPro) {
        // Unlock that great "pro" content
      }
    } on PlatformException catch (e) {
      if (!(e.details as Map)["userCancelled"]) {
        showError(e);
      }
    }
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                "Subscribe to Coachslave",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "\$3 a week",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}