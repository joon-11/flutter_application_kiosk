import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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
  dynamic resultView = const Text("주문중입니다..");

  Future<int> getOrderNumber() async {
    //가장 마지막 번호
    int number = 1;
    var now = DateTime.now();
    var s = DateTime(now.year, now.month, now.day);
    var today = Timestamp.fromDate(s);
    try {
      await firestore
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

  Future<void> setOrder() async {
    int number = await getOrderNumber();
    orderResult['orderNumber'] = number;
    orderResult['orderTime'] = Timestamp.fromDate(DateTime.now());
    orderResult['orderComplete'] = false;
    await firestore
        .collection(orderCollectionName)
        .add(orderResult)
        .then((value) {
      print('ok');
      showResult(number);
      return null;
    }).onError((error, stackTrace) {
      print('error');
      return null;
    });
  }

  void showResult(int number) {
    int duration = 5;
    setState(() {
      resultView = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("주문이 완료되었습니다."),
          Text('주문번호 $number'),
          Text('$duration 초 후에 창이 닫힙니다.'),
          Center(
            child: CircularCountDownTimer(
              width: 100,
              height: 100,
              duration: duration,
              fillColor: Colors.black,
              ringColor: Colors.greenAccent,
              isReverse: true,
              onComplete: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderResult = widget.orderResult;
    setOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ㄳ"),
      ),
      body: resultView,
    );
  }
}
