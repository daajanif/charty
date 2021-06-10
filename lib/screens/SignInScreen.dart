import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_notes/components/MyButtonWidget.dart';
import 'package:mighty_notes/screens/DashboardScreen.dart';
import 'package:mighty_notes/screens/ForgotPasswordScreen.dart';
import 'package:mighty_notes/screens/SignUpScreen.dart';
import 'package:mighty_notes/utils/Colors.dart';
import 'package:mighty_notes/utils/Common.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
      delayInMilliSeconds: 100,
    );

    if (isIos) {
      AppleSignIn.onCredentialRevoked.listen((_) {
        log("Credentials revoked");
      });
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        padding: EdgeInsets.only(top: 32),
        child: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    commonCacheImageWidget('https://minah.com.sa/wp-content/uploads/2021/05/3.png', 150, fit: BoxFit.cover),
                    Text(mAppName, style: boldTextStyle(size: 30)),
                    32.height,
                    AppTextField(
                      controller: emailController,
                      focus: emailNode,
                      nextFocus: passwordNode,
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.EMAIL,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                      decoration: appTextFieldInputDeco(hint: 'Email'),
                      errorInvalidEmail: 'Enter valid email',
                      errorThisFieldRequired: errorThisFieldRequired,

                    ).paddingBottom(16),
                    AppTextField(
                      controller: passController,
                      focus: passwordNode,
                      textStyle: primaryTextStyle(),
                      textFieldType: TextFieldType.PASSWORD,
                      cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                      decoration: appTextFieldInputDeco(hint: 'Password'),
                      errorThisFieldRequired: errorThisFieldRequired,
                      onFieldSubmitted: (s) {
                        signIn();
                      },
                    ),
                    16.height,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forgot password?', style: primaryTextStyle(), textAlign: TextAlign.end).paddingSymmetric(vertical: 8, horizontal: 4).onTap(() {
                        ForgotPasswordScreen().launch(context);
                      }),
                    ),
                    16.height,
                    MyButtonWidget(text: 'Sign In',onTap: () {signIn();}),
                    16.height,
                    Align(
                      alignment: Alignment.center,
                      child: Text('Dont have an account? Sign up', style: primaryTextStyle(), textAlign: TextAlign.end).paddingSymmetric(vertical: 8, horizontal: 4).onTap(() {
                        SignUpScreen().launch(context);}),
                    ),
                    16.height,
                      Row(
                      children: [
                        Divider(thickness: 1, endIndent: 10, indent: 10).expand(),
                        Text('Or continue with', style: primaryTextStyle(size: 12)),
                        Divider(thickness: 1, endIndent: 10, indent: 10).expand(),
                      ],
                    ),
                    16.height,
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCorners( backgroundColor: appStore.isDarkMode ? scaffoldColorDark : Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GoogleLogoWidget(size: 20),
                          16.width,
                          Text('Google Account', style: primaryTextStyle(size: 18)),
                        ],
                      ).center(),
                    ).onTap(() {
                      appStore.setLoading(true);
                      service.signInWithGoogle().then((value) async {
                        await addNotification();
                        appStore.setLoading(false);
                        DashboardScreen().launch(context, isNewTask: true);
                      }).catchError((error) {
                        appStore.setLoading(false);
                        toast(error.toString());
                      });
                    }),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCorners(backgroundColor: appStore.isDarkMode ? scaffoldColorDark : Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('images/ic_apple.png', width: 23, height: 23, color: appStore.isDarkMode ? white : black),
                          16.width,
                          Text('Apple Account', style: primaryTextStyle(size: 18)),
                        ],
                      ).center(),
                    ).onTap(() async {
                      hideKeyboard(context);
                      appStore.setLoading(true);
                      await service.appleLogIn().then((value) {
                        DashboardScreen().launch(context, isNewTask: true);
                      }).catchError((e) {
                        toast(e.toString());
                      });
                      appStore.setLoading(false);
                    }).visible(isIos),
                  ],
                ),
              ),
            ).center(),
            Observer(builder: (_) => Loader(color: appStore.isDarkMode ? scaffoldColorDark : PrimaryColor).visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }

  signIn() async {
    if (formKey.currentState.validate()) {
      appStore.setLoading(true);
      service.signInWithEmailPassword(email: emailController.text.trim(), password: passController.text.trim()).then((value) async {
        await addNotification();

        await setValue(PASSWORD, passController.text.trim());

        appStore.setLoading(false);

        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);

        toast(error.toString());
      });
    }
  }

  Future<void> addNotification() async {
    await subscriptionService.getSubscription().then((value) async {
      value.forEach((element) async {
        if (element.notificationDate != null) {
          if (element.notificationDate.isAfter(DateTime.now())) {
            await manager.showScheduleNotification(
              scheduledNotificationDateTime: element.notificationDate,
              id: element.notificationId,
              title: element.name,
              description: element.amount,
            );
          }
        }
      });
    }).catchError((error) {
      toast(error.toString());
    });
  }
}
