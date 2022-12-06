import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/loader/gf_loader.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // textDirection: TextDirection.ltr,
      backgroundColor: const Color.fromRGBO(49, 49, 49, 1),
      body: Container(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/varity.svg',
                height: 100.0,
              ),
              GFLoader()
            ],
          ),
        ),
      ),
    );
  }
}
