import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String orderCollectionName = 'cafe-order';
var firestore = FirebaseFirestore.instance;

class OrderResult extends StatefulWidget {
  Map<String, dynamic> orderResult;
  OrderResult({super.key, required this.orderResult});

  @override
  State<OrderResult> createState() => _OrderResultState();
}

class _OrderResultState extends State<OrderResult> {
  late Map<String, dynamic> orderResult;

  Future<int> getOrderNumber() async {
    //가장 마지막 번호
    int number = 1;
    var now = DateTime.now();
    var s = DateTime(now.year, now.month, now.day);
    var today = Timestamp.fromDate(s);
    try {
      firestore
          .collection(orderCollectionName)
          .where('orderTime', isGreaterThan: today)
          .orderBy('orderTime', descending: true)
          .limit(1)
          .get()
          .then((value) {
        var data = value.docs;
        number = data[0]['orderNumber'] + 1;
      });
    } catch (e) {
      number = 1;
    }
    print(number);
    return number;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderResult = widget.orderResult;
    getOrderNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(orderResult.toString()),
    );
  }
}
