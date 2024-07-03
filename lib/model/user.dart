
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';


import '../constant.dart';

class Register{
  final String docId;
  final String userId;
  final String name;
  final Timestamp regdate;

  Register({required this.docId, required this.userId, required this.name, required this.regdate});

  Register.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : name = snapshot.data()[userNameFieldName],
        userId = snapshot.data()[userIdFieldName],
        regdate = snapshot.data()[userRegDateFieldName] as Timestamp,
        docId = snapshot.id;
  Register.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot)
      : name = snapshot.data()![userNameFieldName],
        userId = snapshot.data()![userIdFieldName],
        regdate = snapshot.data()![userRegDateFieldName] as Timestamp,
        docId = snapshot.id;
}

class CloudRegister{
  static final CloudRegister _singleton = CloudRegister._internal();

  factory CloudRegister() {
    return _singleton;
  }

  CloudRegister._internal();
  
  final registerCollection =
         FirebaseFirestore.instance.collection(registerCollectionName);
  
  Future<Register> createRegister({required name}) async {
    final docRef = await registerCollection.add({
      userNameFieldName: name,
      userIdFieldName: const Uuid().v4(),
      userRegDateFieldName: FieldValue.serverTimestamp(),
    });
    final fetchedRegister = await docRef.get();
    return Register.fromDocumentSnapshot(fetchedRegister);
  }

  Stream<List<Register>>? getNewRegisters() {
    try {
      return registerCollection.where(userRegDateFieldName, isGreaterThanOrEqualTo: getTimestamp()).snapshots().map(
            (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
                .map<Register>((document) =>
                    Register.fromDocumentSnapshot(document))
                .toList(),
          );
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

}

Timestamp getTimestamp() {
  DateTime now = DateTime.now();
  DateTime desiredDateTime;

  if (now.isAfter(DateTime(now.year, 7, 1))) {
    // If the current date is after July 1st of this year, get a timestamp for July 1st of this year
    desiredDateTime = DateTime(now.year, 7, 1);
  } else {
    // If the current date is on or before July 1st of this year, get a timestamp for December 1st of last year
    desiredDateTime = DateTime(now.year - 1, 12, 1);
  }

  return Timestamp.fromDate(desiredDateTime);
}
