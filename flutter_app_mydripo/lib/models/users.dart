import 'package:firebase_database/firebase_database.dart';

class Users {
  String key;
  String name;
  String role;
  String userId;

  Users( this.name, this.userId, this.role);

  Users.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        role = snapshot.value["role"],
        name = snapshot.value["name"];

  toJson() {
    return {
      "userId": userId,
      "name": name,
      "role": role,
    };
  }
}