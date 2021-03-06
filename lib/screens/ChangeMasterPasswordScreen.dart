import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_notes/utils/Colors.dart';
import 'package:mighty_notes/utils/Common.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ChangeMasterPasswordScreen extends StatefulWidget {
  static String tag = '/ChangeMasterPasswordScreen';

  @override
  ChangeMasterPasswordScreenState createState() => ChangeMasterPasswordScreenState();
}

class ChangeMasterPasswordScreenState extends State<ChangeMasterPasswordScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController currentMasterPwdController = TextEditingController();
  TextEditingController newMasterPwdController = TextEditingController();
  TextEditingController confirmMasterPwdController = TextEditingController();

  FocusNode currentMasterPwdNode = FocusNode();
  FocusNode newMasterPwdNode = FocusNode();
  FocusNode confirmMasterPwdNode = FocusNode();

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Reset Master Password'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: currentMasterPwdController,
                      focus: currentMasterPwdNode,
                      nextFocus: newMasterPwdNode,
                      textFieldType: TextFieldType.PASSWORD,
                      keyboardType: TextInputType.text,
                      maxLength: 4,
                      isPassword: true,
                      cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                      decoration: appTextFieldInputDeco(hint: 'Current password'),
                      errorThisFieldRequired: errorThisFieldRequired,
                      validator: (val) {
                        if (val != getStringAsync(USER_MASTER_PWD)) {
                          return 'Current password is invalid';
                        }
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: newMasterPwdController,
                      focus: newMasterPwdNode,
                      nextFocus: confirmMasterPwdNode,
                      textFieldType: TextFieldType.PASSWORD,
                      keyboardType: TextInputType.text,
                      isPassword: true,
                      maxLength: 4,
                      cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                      decoration: appTextFieldInputDeco(hint: 'New password'),
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return errorThisFieldRequired;
                        } else if (val.length < 4) {
                          return 'password length must be 4';
                        }
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: confirmMasterPwdController,
                      focus: confirmMasterPwdNode,
                      textFieldType: TextFieldType.PASSWORD,
                      keyboardType: TextInputType.text,
                      isPassword: true,
                      maxLength: 4,
                      cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                      decoration: appTextFieldInputDeco(hint: 'Confirm password'),
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return errorThisFieldRequired;
                        } else if (val.length < 4) {
                          return 'password length must be 4';
                        } else if (newMasterPwdController.text.trim() != val.trim()) {
                          return 'password not same';
                        }
                        return null;
                      },
                      onFieldSubmitted: (val) {
                        resetMasterPassword();
                      },
                    ),
                    16.height,
                    AppButton(
                      child: Text('Change master password', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white)),
                      color: appStore.isDarkMode ? PrimaryColor : scaffoldColorDark,
                      width: context.width(),
                      onTap: () {
                        resetMasterPassword();
                      },
                    ),
                  ],
                ),
              ).center(),
            ),
          ),
          Observer(builder: (_) => Loader(color: appStore.isDarkMode ? scaffoldColorDark : PrimaryColor).visible(appStore.isLoading)),
        ],
      ),
    );
  }

  void resetMasterPassword() {
    appStore.setLoading(true);
    if (_formKey.currentState.validate()) {
      Map<String, dynamic> req = {
        'masterPwd': newMasterPwdController.text.trim(),
      };
      userService.updateDocument(req, getStringAsync(USER_ID)).then((value) async {
        await setValue(USER_MASTER_PWD, newMasterPwdController.text.trim());

        toast('Password reset successfully');
        finish(context);

        appStore.setLoading(false);

        currentMasterPwdController.clear();
        newMasterPwdController.clear();
        confirmMasterPwdController.clear();
      }).catchError((error) {
        appStore.setLoading(false);

        toast(errorSomethingWentWrong);
      });
    }
  }
}
