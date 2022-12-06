import 'package:android_native/app/Activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class AboutPage extends ActivityStateless {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Center(
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/varity.svg'),
                      Text(
                        'Varity',
                        style: TextStyle().copyWith(fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
              Text(
                  """Varity is an application to manage your device volume and brightness for each different app. It can save your volume/brightness state when you open other app and restore it when you open that app again.

It works on rooted or non-rooted device."""),
              // Padding(padding: ),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                child: Divider(
                  height: 0.0,
                ),
              ),

              // Text(
              //   "Support Our Work",
              //   style: TextStyle().copyWith(fontSize: 18),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(top: 20, bottom: 20),
              //   child: Text("Consider making a donation to support our work."),
              // ),
              // Image(image: AssetImage('assets/btc_qr_code.png')),
              // Padding(
              //   padding: EdgeInsets.only(top: 10, bottom: 10),
              //   child: Center(
              //     child: Text('Bitcoin Address'),
              //   ),
              // ),

              // Center(
              //   child: InkWell(
              //     child: Text("39WDv44u46gNwCSxD4LokUwyut9nRSXNdm", style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
              //     onTap: () {
              //       // do what you need to do when "Click here" gets clicked
              //       launch('bitcoin:39WDv44u46gNwCSxD4LokUwyut9nRSXNdm');
              //     }
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
