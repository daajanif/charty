import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_notes/components/MyButtonWidget.dart';
import 'package:mighty_notes/screens/DashboardScreen.dart';
import 'package:mighty_notes/utils/Colors.dart';
import 'package:mighty_notes/utils/Common.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  FocusNode usernameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode passNode = FocusNode();
  FocusNode confPassNode = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          child: Stack(
            children: [
              Form(
                key: formState,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      commonCacheImageWidget(getBoolAsync(IS_DARK_MODE, defaultValue: true) ? dark_mode_image : light_mode_image, 150, fit: BoxFit.cover),
                      Text('Create Account', style: boldTextStyle(size: 30)),
                      30.height,
                      AppTextField(
                        autoFocus: true,
                        controller: usernameController,
                        focus: usernameNode,
                        nextFocus: emailNode,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.none,
                        textStyle: primaryTextStyle(),
                        keyboardType: TextInputType.text,
                        cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        decoration: appTextFieldInputDeco(hint: 'Username'),
                        errorInvalidEmail: 'Enter valid email',
                      ),
                      16.height,
                      AppTextField(
                        controller: emailController,
                        focus: emailNode,
                        nextFocus: passNode,
                        textFieldType: TextFieldType.EMAIL,
                        textCapitalization: TextCapitalization.none,
                        textStyle: primaryTextStyle(),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        decoration: appTextFieldInputDeco(hint: 'Email'),
                        errorInvalidEmail: 'Enter valid email',
                        errorThisFieldRequired: errorThisFieldRequired,
                      ),
                      16.height,
                      AppTextField(
                        controller: passController,
                        focus: passNode,
                        nextFocus: confPassNode,
                        textFieldType: TextFieldType.PASSWORD,
                        textStyle: primaryTextStyle(),
                        cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        decoration: appTextFieldInputDeco(hint: 'Password'),
                        errorThisFieldRequired: errorThisFieldRequired,
                      ),
                      16.height,
                      AppTextField(
                        controller: confirmController,
                        focus: confPassNode,
                        textFieldType: TextFieldType.PASSWORD,
                        textStyle: primaryTextStyle(),
                        cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        decoration: appTextFieldInputDeco(hint: 'Confirm Password'),
                        errorThisFieldRequired: errorThisFieldRequired,
                        onFieldSubmitted: (s) {
                          signUp();
                        },
                        validator: (value) {
                          if (value.trim().isEmpty) return errorThisFieldRequired;
                          if (value.trim().length < passwordLengthGlobal) return 'Minimum password length should be $passwordLengthGlobal';
                          return passController.text == value.trim() ? null : 'Password not match';
                        },
                      ),
                      32.height,
                      MyButtonWidget(onTap: ()=> signUp(), text: 'Sign Up'),
                    ],
                  ),
                ),
              ).center(),
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    finish(context);
                  }),
              Observer(builder: (_) => Loader(color: appStore.isDarkMode ? scaffoldColorDark : PrimaryColor).visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (formState.currentState.validate()) {
      appStore.setLoading(true);

      await service.signUpWithEmailPassword(email: emailController.text.trim(), password: passController.text.trim(), displayName: usernameController.text.trim()).then((value) async {
        appStore.setLoading(false);

        await setValue(PASSWORD, passController.text.trim());

        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);

        toast(error);
      });
    }
  }
}
