import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_record.dart';
import 'providers/record_provider.dart';
import 'providers/node_provider.dart';
import 'records_detail.dart';
import 'screen.dart';
import 'add_visit.dart';
import 'view_open_transactions.dart';
import 'widgets/visit_details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => RecordsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NodeProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EhrDoctor',
        theme: ThemeData(
          primaryColor: Color(0xff3FD5AE),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Screen(),
        routes: {
          'records_detail': (ctx) => RecordsDetail(),
          'visit_detail': (ctx) => VisitDetails(),
          'add_record': (ctx) => AddRecord(),
          'view_open_transaction': (ctx) => ViewOpenTransactions(),
          'add_visit': (ctx) => AddVisit(),
        },
      ),
    );
  }
}
