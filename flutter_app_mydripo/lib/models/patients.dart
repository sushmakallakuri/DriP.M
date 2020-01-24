import 'package:firebase_database/firebase_database.dart';

class Patients {
  String key;
  String age;
  String name;
  String roomno;
  String gender;
  String details;
  //int dripcount;
  bool trackstate = false;
  String percent = '0';
  String speed =  '0';
  String volume= '0';
  String volumepre= '0';
  String estTime= '0';
  String prev = '0';
  String alert = '0';
  //String barcode;
  String flow = '0';


  Patients(/*this.barcode,*/this.roomno,this.name, this.age, this.gender,this.details);

  Patients.fromSnapshot(DataSnapshot snapshot) :

        key = snapshot.key,
        //barcode = snapshot.value["barcode"],
        roomno = snapshot.value["roomno"],
        name = snapshot.value["name"],
        age = snapshot.value["age"],
        gender = snapshot.value["gender"],
        details = snapshot.value["details"],
        percent = snapshot.value["percent"],
        trackstate = snapshot.value['state'],
        speed = snapshot.value['speed'],
        volume = snapshot.value['Vol'],
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
      "speed":speed,
      "Vol" : volume,
      "estime": estTime,
      "alert":alert,
      //"barcode":barcode,
      "flow":flow,



    };
  }


}