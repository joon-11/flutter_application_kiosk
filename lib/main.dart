import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'firebase_option.dart';
import 'package:intl/intl.dart';

var f = NumberFormat.currency(locale: 'ko_KR', symbol: '');

var db = FirebaseFirestore.instance;
String categoryCollectionName = 'cafe-category';
String itemCollectionName = 'cafe-item';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({
    super.key,
  });

  @override
  State<Main> createState() => _MainState();
}

// 진입점
class _MainState extends State<Main> {
  dynamic categoryList = const Text("category");
  dynamic itemList = const Text("items");

  // 패널 (장바구니) 컨트롤러
  PanelController panelController = PanelController();
  // 카테고리 기능 보기
  Future<void> showCategoryList() async {
    categoryList = FutureBuilder(
      future: db.collection("cafe-category").get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var datas = snapshot.data!.docs;

        return CustomRadioButton(
          defaultSelected: 'toAll',
          elevation: 0,
          buttonLables: ['전체보기', for (var data in datas) data['categoryName']],
          buttonValues: ['toAll', for (var data in datas) data.id],
          radioButtonValue: (p0) {
            getItems(p0);
          },
          selectedColor: Colors.amber,
          unSelectedColor: Colors.white,
        );
      },
    );
  }

  // 아이템 보기 기능
  Future<void> getItems(String p0) async {
    setState(() {
      itemList = FutureBuilder(
        future: p0 != 'toAll'
            ? db
                .collection(itemCollectionName)
                .where('categoryId', isEqualTo: p0)
                .get()
            : db.collection(itemCollectionName).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData == true) {
            var items = snapshot.data!.docs;
            if (items.isEmpty) {
              return const Center(child: Text('empty!'));
            } else {
              List<Widget> lt = [];
              for (var item in items) {
                lt.add(Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['itemName']),
                      Text(f.format(item['itemPrice']))
                    ],
                  ),
                ));
              }

              return Wrap(
                children: lt,
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showCategoryList();
    getItems('toAll');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cafe",
        ),
        centerTitle: true,
        actions: [
          Transform.translate(
            offset: const Offset(-10, 8),
            child: Badge(
              label: const Text("1"),
              child: IconButton(
                onPressed: () {
                  if (panelController.isPanelOpen) {
                    panelController.close();
                  } else {
                    panelController.open();
                  }
                },
                icon: const Icon(Icons.shopping_cart),
              ),
            ),
          )
        ],
      ),
      body: SlidingUpPanel(
        controller: panelController,
        minHeight: 50,
        maxHeight: 600,
        panel: Container(
          color: Colors.amber,
        ),
        body: Column(
          children: [
            // 카테고리 목록
            categoryList,
            Expanded(child: itemList)

            // 아이템 목록
          ],
        ),
      ),
    );
  }
}
