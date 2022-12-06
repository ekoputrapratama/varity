import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

bool _signUpActive = false;
bool _signInActive = true;

TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _newEmailController = TextEditingController();
TextEditingController _newPasswordController = TextEditingController();

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @protected
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  String _logoTitle = "MOMENTUM";
  String _logoSubTitle = "GROWTH * HAPPENS * TODAY";
  String _signInMenuButton = "SIGN IN";
  String _signUpMenuButton = "SIGN UP";
  String _hintTextEmail = "Email";
  String _hintTextPassword = "Password";
  String _hintTextNewEmail = "Enter your Email";
  String _hintTextNewPassword = "Enter a Password";
  String _signUpButtonText = "SIGN UP";
  String _signInWithEmailButtonText = "Sign in with Email";
  String _skipSignIn = "Skip";
  String _alternativeLogInSeparatorText = "or";
  String _emailLogInFailed =
      "Email or Password was incorrect. Please try again";

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // ScreenUtil.init(BoxConstraints(minWidth: 380, minHeight: 1280),
    //     designSize: Size(750, 1304), allowFontScaling: true);
    // ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    // ScreenUtil.instance =
    //     ScreenUtil(width: 750, height: 1304, allowFontScaling: true)
    //       ..init(context);
    return Scaffold(
      body: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height),
        child: Column(
          children: <Widget>[
            Container(
              child: Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _logoTitle,
                        style: CustomTextStyle.title(context),
                      ),
                      Text(
                        _logoSubTitle,
                        style: CustomTextStyle.subTitle(context),
                      ),
                    ],
                  )),
              width: 750,
              height: 85,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.only(left: 25.0, right: 25.0),
                child: IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: () => setState(() => changeToSignIn()),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            style: BorderStyle.none,
                          ),
                        ),
                        child: Text(_signInMenuButton,
                            style: _signInActive
                                ? TextStyle(
                                    fontSize: 22,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.bold)
                                : TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.normal)),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() => changeToSignUp()),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            style: BorderStyle.none,
                          ),
                        ),
                        child: Text(_signUpMenuButton,
                            style: _signUpActive
                                ? TextStyle(
                                    fontSize: 22,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.bold)
                                : TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.normal)),
                      )
                    ],
                  ),
                ),
              ),
              width: 750,
              height: 70,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: _signInActive ? _showSignIn(context) : _showSignUp()),
              width: 750,
              // height: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _showSignIn(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              style: TextStyle(color: Theme.of(context).accentColor),
              controller: _emailController,
              decoration: InputDecoration(
                hintText: _hintTextEmail,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).accentColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: Theme.of(context).accentColor,
                  width: 1.0,
                )),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
              obscureText: false,
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: true,
              style: TextStyle(color: Theme.of(context).accentColor),
              controller: _passwordController,
              decoration: InputDecoration(
                //Add th Hint text here.
                hintText: _hintTextPassword,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).accentColor, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: ElevatedButton(
              child: Row(
                children: <Widget>[
                  SocialIcon(iconData: CustomIcons.email),
                  Expanded(
                    child: Text(
                      _signInWithEmailButtonText,
                      textAlign: TextAlign.center,
                      style: CustomTextStyle.button(context),
                    ),
                  )
                ],
              ),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.blueGrey),
              onPressed: () => tryToLogInUserViaEmail(
                context,
                _emailController,
                _passwordController,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: Flex(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.horizontal,
              children: <Widget>[
                horizontalLine(),
                Flexible(
                  flex: 0,
                  child: Text(
                    _alternativeLogInSeparatorText,
                    style: CustomTextStyle.body(context),
                  ),
                ),
                horizontalLine()
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          child: Padding(
              padding: EdgeInsets.only(),
              child: ElevatedButton(
                key: Key('skipSignin'),
                child: Row(
                  children: <Widget>[
                    SocialIcon(iconData: CustomIcons.facebook),
                    Expanded(
                      child: Text(
                        _skipSignIn,
                        textAlign: TextAlign.center,
                        style: CustomTextStyle.button(context),
                      ),
                    )
                  ],
                ),
                style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF3C5A99)),
                // color: Color(0xFF3C5A99),
                onPressed: () => tryToLogInUserViaFacebook(context),
              )),
        ),
      ],
    );
  }

  Widget _showSignUp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: false,
              style: CustomTextStyle.formField(context),
              controller: _newEmailController,
              decoration: InputDecoration(
                //Add th Hint text here.
                hintText: _hintTextNewEmail,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).accentColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).accentColor,
                    width: 1.0,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: true,
              style: CustomTextStyle.formField(context),
              controller: _newPasswordController,
              decoration: InputDecoration(
                //Add the Hint text here.
                hintText: _hintTextNewPassword,
                hintStyle: CustomTextStyle.formField(context),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).accentColor, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).accentColor, width: 1.0)),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80,
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: ElevatedButton(
              child: Text(
                _signUpMenuButton,
                style: CustomTextStyle.button(context),
              ),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.blueGrey),
              // color: Colors.blueGrey,
              onPressed: () {},
              // onPressed: () => Controller.signUpWithEmailAndPassword(
              //     _newEmailController, _newPasswordController),
            ),
          ),
        ),
      ],
    );
  }

  Widget horizontalLine() => Flexible(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            // width: 118,
            height: 1.0,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      );

  Widget emailErrorText() => Text(_emailLogInFailed);

  void changeToSignUp() {
    _signUpActive = true;
    _signInActive = false;
  }

  void changeToSignIn() {
    _signUpActive = false;
    _signInActive = true;
  }

  // void signUpWithEmailAndPassword(email, password) =>
  //     Model._signUpWithEmailAndPassword(email, password);

  Future tryToLogInUserViaFacebook(context) async {
    // if (await signInWithFacebook(context) == true) {
    //   // Navigator.pushNamed(context, "/trade");
    // }
  }

  Future tryToLogInUserViaEmail(context, email, password) async {
    if (await signInWithEmail(context, email, password) == true) {
      //   navigateToProfile(context);
    }
  }

  Future tryToSignUpWithEmail(email, password) async {
    if (await tryToSignUpWithEmail(email, password) == true) {
      //TODO Display success message or go to Login screen
    } else {
      //TODO Display error message and stay put.
    }
  }

  Future<bool> signUpWithEmailAndPassword(
      TextEditingController email, TextEditingController password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text.trim().toLowerCase(), password: password.text);
      if (result.user != null) {
        print('Signed up: ${result.user!.uid}');
      }

      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> signInWithEmail(context, TextEditingController email,
      TextEditingController password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text.trim().toLowerCase(), password: password.text);
      if (result.user != null) {
        print('Signed in: ${result.user!.uid}');
      }
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Future<bool> signInWithFacebook(context) async {
  //   // by default the login method has the next permissions ['email','public_profile']
  //   LoginResult result = await FacebookAuth.instance.login();
  //   if (result.status == LoginStatus.success) {
  //     AccessToken accessToken = result.accessToken!;
  //     print(accessToken.toJson());
  //     // get the user data
  //     final userData = await FacebookAuth.instance.getUserData();
  //     print(userData);
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
}

class CustomTextStyle {
  static TextStyle formField(BuildContext context) {
    return Theme.of(context).textTheme.headline6!.copyWith(
        fontSize: 18.0, fontWeight: FontWeight.normal, color: Colors.white);
  }

  static TextStyle title(BuildContext context) {
    return Theme.of(context).textTheme.headline6!.copyWith(
        fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white);
  }

  static TextStyle subTitle(BuildContext context) {
    return Theme.of(context).textTheme.headline6!.copyWith(
        fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);
  }

  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.headline6!.copyWith(
        fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white);
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.headline6!.copyWith(
        fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);
  }
}

class CustomIcons {
  static const IconData twitter = IconData(0xe900, fontFamily: "CustomIcons");
  static const IconData facebook = IconData(0xe901, fontFamily: "CustomIcons");
  static const IconData Google = IconData(0xe902, fontFamily: "CustomIcons");
  static const IconData email = IconData(0xe0be, fontFamily: "MaterialIcons");
}

class SocialIcon extends StatelessWidget {
  final IconData? iconData;

  SocialIcon({this.iconData});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(),
      child: Container(
        width: 40.0,
        height: 40.0,
        child: RawMaterialButton(
          shape: CircleBorder(),
          onPressed: () {},
          child: Icon(iconData, color: Colors.white),
        ),
      ),
    );
  }
}
