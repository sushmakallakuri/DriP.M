import 'package:firebase_database/firebase_database.dart';

class users {
  String key;
  String name;
  String role;
  String userId;

  users( this.name, this.userId, this.role);

  users.fromSnapshot(DataSnapshot snapshot) :
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