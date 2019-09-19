import 'package:firebase_database/firebase_database.dart';

class patients {
  String key;
  String age;
  String name;
  String roomno;
  String gender;
  String details;
  int dripcount;
  bool trackstate = false;
  String percent = '0';
  String Speed =  '0';
  String Volume= '0';
  String Volumepre= '0';
  String estTime= '0';
  String prev = '0';
  int alert = 0;
  String barcode;
  String flow = '0';


  patients(this.barcode,this.roomno,this.name, this.age, this.gender,this.details);

  patients.fromSnapshot(DataSnapshot snapshot) :

        key = snapshot.key,
        barcode = snapshot.value["barcode"],
        roomno = snapshot.value["roomno"],
        name = snapshot.value["name"],
        age = snapshot.value["age"],
        gender = snapshot.value["gender"],
        details = snapshot.value["details"],
        percent = snapshot.value["percent"],
        trackstate = snapshot.value['state'],
        Speed = snapshot.value['speed'],
        Volume = snapshot.value['Vol'],
        alert=snapshot.value['alert'],
        flow = snapshot.value['flow'],
        estTime = snapshot.value['estime'];




  toJson() {
    return {
      "roomno": roomno,
      "name": name,
      "age": age,
      "gender": gender,
      "details": details,
      "percent" : percent,
      "state" : false,
      "speed":Speed,
      "Vol" : Volume,
      "estime": estTime,
      "alert":alert,
      "barcode":barcode,
      "flow":flow,



    };
  }


}