import 'package:flutter/material.dart';
import 'package:flutter_app_mydripo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app_mydripo/models/todo.dart';
import 'dart:async';
import 'package:flutter_app_mydripo/models/patients.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


//firebase animated list
import 'package:firebase_database/ui/firebase_animated_list.dart';
var count = 0;
String _gender;
class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool check= true;
  bool check2 = true;
 String barcode = "";

  List<patients> _patientList;
  List<bool> state;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //bool isSwitched = true;
  int percent = 0 ;
  final _textEditingController1 = TextEditingController();
  final _textEditingController2 = TextEditingController();
  final _textEditingController3 = TextEditingController();
  final _textEditingController4 = TextEditingController();
  final _textEditingController5 = TextEditingController();
  final _textEditingController6 = TextEditingController();
  final double dogAvatarSize = 150;
  // This is the starting value of the slider.
  double _sliderValue = 10.0;
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _patientList = new List();
    _todoQuery = _database
        .reference()
        .child("patients")
        .orderByChild("roomno");

    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _todoQuery.onChildChanged.listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }







  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {

                Navigator.of(context).pop();
                _signOut();
              },
            ),
          ],
        );
      },
    );
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }
  /*
  void abc(int a)
  { int c = _patientList[a].Volumepre;
    int b =_patientList[a].Volume;

    if((b - c) != 0)
      check = true;
    else
      check =false;
    c = b ;
  }
*/
  _onEntryChanged(Event event) {

    var oldEntry =_patientList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _patientList[_patientList.indexOf(oldEntry)] = patients.fromSnapshot(event.snapshot);
      // abc(_patientList.indexOf(oldEntry));
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _patientList.add(patients.fromSnapshot(event.snapshot));
    });
  }

  _signOut() async {
    try {
      await widget.auth.signOut();

      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _addNewTodo(String barcode, String roomno, String name, String age, String gender, String details) {
    if ( barcode.length > 0 && roomno.length > 0 && name.length >0  && age.length > 0 && gender.length > 0 && details.length > 0) {

      patients patient = new patients(barcode,roomno, name, age, gender,details);
      _database.reference().child("patients").child(roomno).set(patient.toJson());
    }
  }

  _updateTodo(Todo todo){
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  _deleteTodo(String roomno, int index) {
    _database.reference().child("patients").child(roomno).remove().then((_) {
      print("Delete $roomno successful");
      setState(() {
        _patientList.removeAt(index);
      });
    });
  }

  _showDialog(BuildContext context) async {
    _textEditingController1.clear();
    _textEditingController2.clear();
    _textEditingController3.clear();
    _textEditingController4.clear();
    _textEditingController5.clear();

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(

            content:
            new Column(

              children: <Widget>[
                new Expanded(child: new TextField(
                  controller: _textEditingController1,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Room No.',
                  ),
                )),
                new Expanded(child: new TextField(
                  controller: _textEditingController2,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Name',
                  ),
                )),

                new Expanded(child: new TextField(
                  controller: _textEditingController3,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Age',
                  ),
                )),
//                new Expanded(child: new TextField(
//                  controller: _textEditingController4,
//                  autofocus: true,
//                  decoration: new InputDecoration(
//                    labelText: 'Gender',
//                  ),
//                )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
//                      child: new Text("Gender",style: new TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                    ),

                  ],
                ),
                MyDialogContent(),


                new Expanded(child: new TextField(
                  controller: _textEditingController5,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Details for Medication',
                  ),
                )),

//                new Expanded(child: new TextField(
//                  controller: _textEditingController6,
//                  autofocus: true,
//                  decoration: new InputDecoration(
//                    labelText: 'barcode',
//                  ),
//                )),




              ],
            ),

            actions: <Widget>[
              new RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  splashColor: Colors.blueGrey,
                  onPressed: scan,
                  child: const Text('SCAN QR CODE')
              ),
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    _addNewTodo(barcode,_textEditingController1.text.toString(), _textEditingController2.text.toString(),_textEditingController3.text.toString(),_gender,_textEditingController5.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }








  Widget _showTodoList() {
    var LeftContiners= new Container();
    var RighContiners= new Container();
    var MidContiners= new Expanded();
    var LeftContiners2= new Container();
    var MiddleContiners2= new Container();
    var RighContiners2= new Container();
    if (_patientList.length > 0) {
      return ListView.builder(

          shrinkWrap: true,
          itemCount: _patientList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _patientList[index].key;
            /*
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            String userId = _todoList[index].userId;
            */


            String roomno = _patientList[index].roomno;
            String name = _patientList[index].name;
            String age = _patientList[index].age;
            String gender = _patientList[index].gender;
            String details = _patientList[index].details;
            String percent = _patientList[index].percent;
            bool isSwitched = _patientList[index].trackstate;
            String speed = _patientList[index].Speed;
            String Vol = _patientList[index].Volume;
            int alert = _patientList[index].alert;
            String flow = _patientList[index].flow;

            String estime = _patientList[index].estTime;
            if((alert) == 0){
              check2 = true;
            }
            else
              check2 = false;


            int dripcount ;
            int percentage;
            if (double.parse(percent)>0)
             percentage = ((double.parse(percent) - double.parse(Vol))*100/double.parse(percent)).toInt();
            else
              percentage = 0;

            _database.reference().child("patients").child(roomno).once().then((DataSnapshot snapshot) {
              dripcount = snapshot.value['dripcount'];

            });
            if( alert== 0 )//|| percentage >10
              check2 = true;
            else
              check2 = false;
            if( percentage >10 )//||
              check = true;
            else
              check = false;

            LeftContiners= new Container(
              child: new CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 5.0,
                percent:  percentage*0.01,
                center: new Text(percentage.toString()+'%'),
                progressColor: check?Colors.green:Colors.red,

              ),
            );

            MidContiners = new Expanded(
                child:
                new Container(
                  padding: new EdgeInsets.only(left: 50.0),
                  child:
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[

                      new Text("Bed No."+roomno,
                        style:
                        new TextStyle(
                          color: Colors.
                          black,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.
                          w600,
                          fontSize: ScreenUtil.instance.setSp(18),
                        ),),

                      new Text("Patient Name : "+name, style:

                      new TextStyle(color: Colors.blueGrey ,fontStyle: FontStyle.italic,fontSize: ScreenUtil.instance.setSp(16)),),
                      new Text("Volume : "+Vol.toString(), style:

                      new TextStyle(color: Colors.blueGrey,fontStyle: FontStyle.italic,fontSize: ScreenUtil.instance.setSp(16))),


                      new Text("Estimate Time : "+estime.toString(), style:

                      new TextStyle(color: Colors.blueGrey,fontStyle: FontStyle.italic,fontSize: ScreenUtil.instance.setSp(16))),
                      new Text("Estimated Speed : "+flow.toString(), style:

                      new TextStyle(color: Colors.blueGrey,fontStyle: FontStyle.italic,fontSize: ScreenUtil.instance.setSp(16)),),

                    ],
                  ),
                ));
            RighContiners = new Container(
              margin: EdgeInsets.all(5),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  check?
                  Icon(
                    Icons.done,
                    color: Colors.green,
                    size: 30.0,
                  ): Icon(
                    Icons.notification_important,
                    color: Colors.red,
                    size: 30.0,
                  ),
                ],
              ),
            );

            LeftContiners2= new Container(

              child: Row(
                children: <Widget>[
                  Text("Set flow"),

                  Container(
                    width :ScreenUtil.instance.setWidth(170),
                    child: Slider(
                      activeColor: Colors.indigoAccent,
                      min: 0,
                      max: 50,

                      onChanged: (newRating) {
                        setState(() => speed = newRating.toString()

                        );
                        _database.reference().child("patients").child(roomno).update({'speed':speed}) ;
                      },
                      value: double.parse(speed),
                    ),
                  ),
                  Text('${double.parse(speed).floor()}',
                      style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),




                ],
              ),



            );
            RighContiners2= new Container(

              margin: EdgeInsets.all(2),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Text(" IV"),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched=value;
                        _database.reference().child("patients").child(roomno).update({'state':isSwitched}) ;
                      });
                    },
                    activeTrackColor: Colors.lightBlueAccent,
                    activeColor: Colors.lightBlue,
                  ),
                ],),
            );









            return Dismissible(
              key: Key(roomno),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteTodo(roomno, index);
              },

              child: new Card(
                  elevation:5,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                        child: Row(
                          children: <Widget>[
                            //percentage
                            LeftContiners,
                            MidContiners,
                            RighContiners,

                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            //percentage
                            LeftContiners2,
                            RighContiners2,


                          ],
                        ),
                      ),


                    ],
                  )

              ),
            );
          });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: ScreenUtil.instance.setSp(30),),));
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      allowFontScaling: true,
    )..init(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("DriP.M"),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: ScreenUtil.instance.setSp(17), color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        )
    );
  }
}

class MyDialogContent extends StatefulWidget {


  @override
  _MyDialogContentState createState() => new _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  int _selectedIndex = 0;

  @override
  void initState(){
    super.initState();
  }

  _getContent(){


    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
          child: new Text("Gender",style: new TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[

            new Radio(
              value: 'Male',
              groupValue: _gender,
              onChanged: (String value) {
                setState((){
                  _gender = value;
                });
              },
            ),
            new Text(
              'Male',
              style: new TextStyle(fontSize: ScreenUtil.instance.setSp(15))
            ),
            new Radio(
              value: 'Female',
              groupValue: _gender,
              onChanged: (String value) {
                setState((){
                  _gender = value;
                });
              },
            ),
            new Text(
              'Female',
              style: new TextStyle(
                fontSize: ScreenUtil.instance.setSp(12),
              ),
            ),
            new Radio(
              value: 'Other',
              groupValue: _gender,
              onChanged: (String value) {
                setState((){
                  _gender = value;
                });
              },
            ),
            new Text(
              'Other',
              style: new TextStyle(fontSize: ScreenUtil.instance.setSp(12)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}