import 'package:flutter/material.dart';
import 'package:flutter_app_mydripo/services/authentication.dart';
import 'package:flutter_app_mydripo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app_mydripo/models/users.dart';
import 'package:flutter_app_mydripo/models/patients.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


enum WidgetMarker { loginpage,signuppage }
class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _errorMessage;
  String _role;
  String _name;

  String _rolestate;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  WidgetMarker
  selectedWidgetMarker = WidgetMarker.loginpage;



  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password,);

          print('Signed in: $userId');

        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          users user = new users(_name.toString(), userId, _role);
          _database.reference().child("users").push().set(user.toJson());

          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId != null && userId.length > 0 && _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
      getsignuppage();
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
      getloginpage();
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Smart Infusion System'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  Widget _showBody(){

    return ListView(
      children: <Widget>[
        Row(

        ),

        Container(
          child: getCustomContainer(),
        )
      ],
    );
  }


  Widget getloginpage()
  {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
            key: _formKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                _showLogo(),
                _showEmailInput(),
                _showPasswordInput(),
                _showPrimaryButton(),
                _showSecondaryButton(),
                _showErrorMessage(),
//                _showImage(),
              ],)));
  }

  Widget getsignuppage()
  {
    return new Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
            key: _formKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                _showLogo(),
                _showname(),
                _showEmailInput(),
                _showPasswordInput(),// add name and role
                //ROLE
                _showRole(),
                _showPrimaryButton(),
                _showSecondaryButton(),
                _showErrorMessage(),
              ],)));
  }





  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

//  Widget _showImage()
//  {
//    return Container(
//      constraints: BoxConstraints.expand(height: 300),
//      alignment: Alignment.center,
//      child: Image.asset(
//        "assets/synergy.jpeg",
//        fit: BoxFit.cover,
//      ),
//    );
//  }


  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Image.asset('assets/logo.jpg',width: 10,height: 100),
      //FlutterLogo(size: 100.0),
    );
  }

  Widget _showname() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Name',
            icon: new Icon(
              Icons.account_circle ,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return 'name can\'t be empty';
          }
        },
        onSaved: (value) => _name = value,
      ),
    );
  }





  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return 'Email can\'t be empty';
          }
        },
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return 'Email can\'t be empty';
          }
        },
        onSaved: (value) => _password = value,
      ),
    );
  }
  Widget _showRole() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child:

      new Row(

        children: <Widget>[
          Icon(

            Icons.group,

            color: Colors.grey,
            size: 30.0,

          ),

          new Radio(
            value: 'Doctor',
            groupValue: _role,
            onChanged: _handleRadioValueChange1,
          ),
          new Text(
            'Doctor',
            style: new TextStyle(fontSize: 16),
          ),
          new Radio(
            value: 'Nurse',
            groupValue:  _role,
            onChanged: _handleRadioValueChange1,
          ),
          new Text(
            'Nurse',
            style: new TextStyle(
              fontSize: 16,
            ),

          ),
          new Radio(
            value: 'Attender',
            groupValue:  _role,
            onChanged: _handleRadioValueChange1,
          ),

          new Text(
            'Attender',
            style: new TextStyle(
              fontSize: 16,
            ),

          ),
        ],
      ),
    );
  }

  void _handleRadioValueChange1( String value) {
    setState(() {
      _role = value;

    });
  }
  /*
void change_state(bool state){
    setState(() {
      visibilityObs = state;
    });

}*/






  Widget getCustomContainer() {
    switch
    (selectedWidgetMarker) {
      case
      WidgetMarker.loginpage:
        return
          getloginpage();
      case
      WidgetMarker.signuppage:
        return
          getsignuppage();

    }


  }


  Widget _showSecondaryButton() {


    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
          style: new TextStyle(fontSize: 18, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
          style:
          new TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    if(_formMode == FormMode.LOGIN){
      setState(() {
        selectedWidgetMarker = WidgetMarker.loginpage;
      });
    }
    if(_formMode == FormMode.SIGNUP){
      setState(() {
        selectedWidgetMarker = WidgetMarker.signuppage;
      });
    }

    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: _formMode == FormMode.LOGIN
                ?
            new Text('Login',
                style: new TextStyle(fontSize: 20, color: Colors.white))

                :  new Text('Create account',
                style: new TextStyle(fontSize: 20, color: Colors.white)),
            onPressed: _validateAndSubmit,

          ),
        ));
  }

}