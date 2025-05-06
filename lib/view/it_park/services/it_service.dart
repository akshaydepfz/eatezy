import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/it_park_model.dart';
import 'package:flutter/material.dart';

class ItService extends ChangeNotifier {
  List<ItParkModel>? parks;

  Future<void> fetchParks() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('it_parks').get();

      parks = snapshot.docs.map((doc) {
        return ItParkModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      notifyListeners();
    } catch (_) {}
  }
}
