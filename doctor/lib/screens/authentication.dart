import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/record_provider.dart';
import '../widgets/alert_dialog.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/custom_text.dart';
import 'landingpage.dart';

class Authentication extends StatefulWidget {
  final AuthAction authAction;
  Authentication(this.authAction);
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final _formkey = GlobalKey<FormState>();
  final _usernamenode = FocusNode();
  final _emailnode = FocusNode();
  final _passwordnode = FocusNode();
  var _isLoading = false;

  Map<String, String> _authData = {
    'username': '',
    'email': '',
    'password': '',
    'doctorid': ''
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formkey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formkey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    widget.authAction == AuthAction.signup ? signupuser() : loginuser();
  }

  Future<void> loginuser() async {
    try {
      final provider = Provider.of<DoctorAuthProvider>(context, listen: false);
      await provider.login(
        email: _authData['email'],
        password: _authData['password'],
      );

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await showDialog(
        context: context,
        builder: (ctx) => CustomAlertDialog(
          message: e.toString(),
          success: false,
        ),
      );
    }
  }

  Future<void> signupuser() async {
    try {
      final provider = Provider.of<DoctorAuthProvider>(context, listen: false);
      await provider.signup(
        name: _authData['username'],
        email: _authData['email'],
        password: _authData['password'],
        doctorid: _authData['doctorid'],
        gender: _authData['gender'],
      );
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).popUntil((route) => route.isFirst);
      // Navigator.of(context).popAndPushNamed('activationscreen');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await showDialog(
        context: context,
        builder: (ctx) => CustomAlertDialog(
          message: e.toString(),
          success: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;
    final devicewidth = MediaQuery.of(context).size.width;

    Future<bool> _onBackPressed() {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          body: ListView(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                height: deviceheight * 0.33,
                width: double.infinity,
                child: Image.asset(
                  'assets/background.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10),
              CustomText(
                widget.authAction == AuthAction.signup ? "Sign up" : " Sign In",
                alignment: TextAlign.center,
                fontsize: 30,
              ),
              Form(
                key: _formkey,
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.all(25),
                  shrinkWrap: true,
                  children: [
                    widget.authAction == AuthAction.signup
                        ? ListView(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            children: [
                              CustomFormField(
                                icondata: Icons.assignment_ind,
                                labeltext: 'Doctor id',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.number,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Doctor id can\'t be empty!';
                                  }
                                  return null;
                                },
                                onfieldsubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_usernamenode);
                                },
                                onsaved: (value) {
                                  _authData['doctorid'] = value.trim();
                                },
                              ),
                              SizedBox(height: 20),
                              CustomFormField(
                                focusNode: _usernamenode,
                                icondata: Icons.person,
                                labeltext: 'Username',
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Username can\'t be empty!';
                                  }
                                  return null;
                                },
                                onfieldsubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_emailnode);
                                },
                                onsaved: (value) {
                                  _authData['username'] = value.trim();
                                },
                              ),
                              SizedBox(height: 20),
                            ],
                          )
                        : SizedBox(),
                    CustomFormField(
                      focusNode: _emailnode,
                      labeltext: 'Email',
                      icondata: Icons.email,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.trim().isEmpty ||
                            !value.trim().contains('@') ||
                            !value.trim().endsWith('com')) {
                          return 'Invalid email!';
                        }
                        return null;
                      },
                      onfieldsubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordnode);
                      },
                      onsaved: (value) {
                        _authData['email'] = value.trim();
                      },
                    ),
                    SizedBox(height: 20),
                    CustomFormField(
                      focusNode: _passwordnode,
                      labeltext: 'Password',
                      maxlines: 1,
                      icondata: Icons.remove_red_eye,
                      obscuretext: true,
                      textInputAction: TextInputAction.go,
                      validator: (value) {
                        if (value.isEmpty || value.length < 8) {
                          return 'Password is too short!';
                        }
                        return null;
                      },
                      onsaved: (value) {
                        _authData['password'] = value.trim();
                      },
                    ),
                    SizedBox(height: 20),
                    widget.authAction == AuthAction.signup
                        ? DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                size: 25,
                                color: Colors.black,
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please choose your gender';
                              }
                              return null;
                            },
                            hint: Text("Enter Gender"),
                            items: [
                              DropdownMenuItem(
                                child: Text("Male"),
                                value: "Male",
                              ),
                              DropdownMenuItem(
                                child: Text("Female"),
                                value: "Female",
                              ),
                            ],
                            onChanged: (value) {
                              _authData['gender'] = value;
                            },
                          )
                        : SizedBox(),
                    SizedBox(height: 20),
                    Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Container(
                              width: devicewidth * 0.4,
                              child: CustomButton(
                                widget.authAction == AuthAction.signup
                                    ? 'Signup'
                                    : 'Signin',
                                _submit,
                                backgroundcolor:
                                    widget.authAction == AuthAction.signup
                                        ? Colors.red
                                        : null,
                              ),
                            ),
                    )
                  ],
                ),
              ),
              FlatButton(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.authAction == AuthAction.signup
                            ? 'Already have an account? '
                            : 'Don\'t have an account? ',
                        style: GoogleFonts.montserrat()
                            .copyWith(color: Colors.black),
                      ),
                      TextSpan(
                        text: widget.authAction == AuthAction.signup
                            ? 'Sign in'
                            : 'Sign up',
                        style: GoogleFonts.montserrat()
                            .copyWith(color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
                onPressed: widget.authAction == AuthAction.signup
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => Authentication(AuthAction.signin),
                          ),
                        )
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => Authentication(AuthAction.signup),
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
