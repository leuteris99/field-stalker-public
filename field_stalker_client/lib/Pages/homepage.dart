import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_stalker_client/charts/timeSeriesBar.dart';
import 'package:field_stalker_client/models/package.dart';
import 'package:flutter/material.dart';
import '../charts/simpleChart.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _packageStream = FirebaseFirestore.instance
      .collection("package")
      .orderBy("timestamp")
      .snapshots();

  int _selectedValue = 0;

  _HomePageState();

  @override
  Widget build(BuildContext context) {
    double chartHeight = getScreenHeight(context) / 3;
    double chartWidth = getScreenHeight(context) * 2 / 3;
    return StreamBuilder<QuerySnapshot>(
        stream: _packageStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<Package> packages = [];
          packages.addAll(snapshot.data.docs
              .map((document) => Package.fromMap(document.data())));

          Set arduinosSet = new Set();
          arduinosSet.addAll(packages.map((element) => element.ardId).toSet());
          List<String> arduinosList = [];
          for (var el in arduinosSet) {
            arduinosList.add(el.toString());
          }
          List<Package> selectedPackages = [];
          packages.forEach((element) {
            if (element.ardId == int.parse(arduinosList[_selectedValue])) {
              selectedPackages.add(element);
            }
          });
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Container(
                width: getScreenWidth(context),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Select a plant:",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        getDropDown(arduinosList),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "This Week",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            getLineDescriber("Temperature", Colors.teal),
                            SizedBox(
                              width: 10,
                            ),
                            getLineDescriber("Light", Colors.yellow),
                            SizedBox(
                              width: 10,
                            ),
                            getLineDescriber("Humidity", Colors.red),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 0, 22, 30),
                          height: chartHeight,
                          width: chartWidth,
                          child: SimpleTimeSeriesChart.withPackageData(
                              getCurWeekPackages(selectedPackages)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Temperatures",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 0, 22, 30),
                          height: chartHeight,
                          width: chartWidth,
                          child: SimpleTimeSeriesChart.withPackageData(
                            selectedPackages,
                            type: 'temperature',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Light",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 0, 22, 30),
                          height: chartHeight,
                          width: chartWidth,
                          child: TimeSeriesBar.withPackageData(
                              selectedPackages, 'light'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Humidity",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(22, 0, 22, 30),
                          height: chartHeight,
                          width: chartWidth,
                          child: TimeSeriesBar.withPackageData(
                              selectedPackages, 'humidity'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget getDropDown(List items) {
    List<DropdownMenuItem> menuItems = [];
    for (int i = 0; i < items.length; i++) {
      Widget tmp = DropdownMenuItem(
        child: Text(items[i]),
        value: i,
      );
      menuItems.add(tmp);
    }
    return DropdownButton(
      value: _selectedValue,
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
        });
      },
      items: menuItems,
    );
  }
}

Widget getLineDescriber(String lineType, Color color) {
  return Row(
    children: [
      Container(
        margin: EdgeInsets.only(right: 5),
        height: 20,
        width: 20,
        color: color,
      ),
      Text(lineType),
    ],
  );
}

List<Package> getCurWeekPackages(List<Package> data) {
  List<Package> res = [];
  DateTime now = DateTime.now();
  data.forEach((element) {
    for (var i = 0; i < 7; i++) {
      if (element.timestamp.add(Duration(days: -i)).isSameDate(now)) {
        res.add(element);
        break;
      }
    }
  });
  return res;
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

double getScreenWidth(var context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(var context) {
  return MediaQuery.of(context).size.height;
}
