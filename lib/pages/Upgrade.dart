import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../VarityApp.dart';
import 'Login.dart';

class FeatureList extends StatelessWidget {
  final List<Widget> children;
  final Widget? header;
  FeatureList({this.children = const [], this.header});
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class FeatureTile extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final int flex;
  FeatureTile({this.icon, this.title, this.flex = 0});
  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: flex,
        child: Column(children: [
          ListTile(
            leading: icon,
            title: title,
          ),
          Divider(
            height: 0,
          )
        ]));
  }
}

class UpgradePage extends StatefulWidget {
  @override
  _UpgradePageState createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  final Controller controller = Get.find();

  String _platformVersion = 'Unknown';
  // List<IAPItem> _items = [];
  // List<PurchasedItem> _purchases = [];

  late StreamSubscription _purchaseUpdatedSubscription;
  late StreamSubscription _purchaseErrorSubscription;
  late StreamSubscription _conectionSubscription;
  final List<String> _productLists = [
    'varity_premium',
  ];

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = (await FlutterInappPurchase.instance.platformVersion)!;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // prepare
    // var result = await FlutterInappPurchase.instance.initConnection;
    // log('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });

    // refresh items for android
    // try {
    //   String msg = await FlutterInappPurchase.instance.consumeAllItems;
    //   log('consumeAllItems: $msg');
    // } catch (err) {
    //   log('consumeAllItems error: $err');
    // }

    // _conectionSubscription =
    //     FlutterInappPurchase.connectionUpdated.listen((connected) {
    //   log('connected: $connected');
    // });

    // _purchaseUpdatedSubscription =
    //     FlutterInappPurchase.purchaseUpdated.listen((productItem) {
    //   log('purchase-updated: $productItem');
    // });

    // _purchaseErrorSubscription =
    //     FlutterInappPurchase.purchaseError.listen((purchaseError) {
    //   log('purchase-error: $purchaseError');
    // });

    // _getProduct();
    // _getPurchases();
  }

  // void _requestPurchase(IAPItem item) {
  //   FlutterInappPurchase.instance.requestPurchase(item.productId!);
  // }

  // Future _getProduct() async {
  //   List<IAPItem> items =
  //       await FlutterInappPurchase.instance.getProducts(_productLists);
  //   for (var item in items) {
  //     print('${item.toString()}');
  //     this._items.add(item);
  //   }

  //   setState(() {
  //     this._items = items;
  //     this._purchases = [];
  //   });
  // }

  // Future _getPurchases() async {
  //   List<PurchasedItem> items =
  //       (await FlutterInappPurchase.instance.getAvailablePurchases())!;
  //   for (var item in items) {
  //     print('${item.toString()}');
  //     this._purchases.add(item);
  //   }

  //   setState(() {
  //     this._items = [];
  //     this._purchases = items;
  //   });
  // }

  // Future _getPurchaseHistory() async {
  //   List<PurchasedItem> items =
  //       (await FlutterInappPurchase.instance.getPurchaseHistory())!;
  //   for (var item in items) {
  //     print('${item.toString()}');
  //     this._purchases.add(item);
  //   }

  //   setState(() {
  //     this._items = [];
  //     this._purchases = items;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    // var firebaseNotifier = context.watch<FirebaseNotifier>();
    // if (firebaseNotifier.state == FirebaseState.loading) {
    //   return _PurchasesLoading();
    // } else if (firebaseNotifier.state == FirebaseState.notAvailable) {
    //   return _PurchasesNotAvailable();
    // }

    // if (!firebaseNotifier.loggedIn) {
    //   return LoginPage();
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text("Varity Pro"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          // direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Center(
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/varity.svg'),
                      Text(
                        'Varity Pro',
                        style: TextStyle().copyWith(fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            ),
            FeatureList(
              children: [
                FeatureTile(
                  icon: SvgPicture.asset(
                    'assets/cloud-backup.svg',
                    height: 28,
                  ),
                  title: Text('Save your apps configuration'),
                ),
                FeatureTile(
                  icon: SvgPicture.asset(
                    'assets/day-and-night.svg',
                    height: 28,
                  ),
                  title: Text('Advanced configuration'),
                )
              ],
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(),
                    child: Text("Upgrade"),
                    onPressed: () async {
                      // log("buy button pressed");
                      // log("purchases ${_purchases}");
                      // log("items ${_items}");
                      // var products = await controller.getProducts();
                      // controller.requestPurchase(products.first);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchasesLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Store is loading'));
  }
}

class _PurchasesNotAvailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Store not available'));
  }
}
