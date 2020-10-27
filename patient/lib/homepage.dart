import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'models/block.dart';
import 'providers/record_provider.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text.dart';
import 'widgets/record_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _isloading = false;
  var _isInit = true;
  List<Block> _updatedrecords;
  String _publicKey;

  CalendarController _calendarController;
  var i = 0;
  var _chosen = DateTime.now();

  final _selectedDay = DateTime.now();
  Map<DateTime, List> _events = {};
  List _selectedEvents;

  Future<void> fetch() async {
    await Provider.of<RecordsProvider>(context, listen: false).loadKeys();
    _publicKey = Provider.of<RecordsProvider>(context, listen: false).publickey;
    await Provider.of<RecordsProvider>(context, listen: false)
        .getPatientChain(_publicKey);
    await Provider.of<RecordsProvider>(context, listen: false)
        .resolveConflicts();
    _updatedrecords =
        Provider.of<RecordsProvider>(context, listen: false).records;
  }

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isloading = true;
      });
      fetch().then((value) {
        while (i < _updatedrecords.length) {
          _events.putIfAbsent(
              DateTime.fromMillisecondsSinceEpoch(
                  double.parse(_updatedrecords[i].timestamp).toInt() * 1000),
              () => _updatedrecords[i].transaction);
          i++;
        }
        _selectedEvents = _events[_selectedDay] ?? [];
        _calendarController = CalendarController();
        setState(() {
          _isloading = false;
        });
      });
    }
    super.didChangeDependencies();
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;

    return _isloading
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(deviceheight * 0.08),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Welcome,',
                      color: Colors.black54,
                      fontsize: 16,
                    ),
                    CustomText(
                      'Kenneth Erickson',
                      fontsize: 20,
                    ),
                  ],
                ),
                actions: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: CustomButton(
                      'ADD VISIT',
                      () {
                        Navigator.of(context)
                            .pushNamed('add_visit', arguments: _publicKey)
                            .then((value) => {
                                  setState(() {
                                    _isloading = true;
                                  }),
                                  fetch().then((value) => {
                                        setState(() {
                                          _isloading = false;
                                        }),
                                      }),
                                });
                      },
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10)
                ],
              ),
            ),
            body: Container(
              height: deviceheight,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TableCalendar(
                    headerStyle: HeaderStyle(centerHeaderTitle: true),
                    events: _events,
                    availableCalendarFormats: {CalendarFormat.month: 'Month'},
                    calendarController: _calendarController,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    initialCalendarFormat: CalendarFormat.month,
                    calendarStyle: CalendarStyle(
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.7),
                      todayColor: Theme.of(context).primaryColor,
                      markersColor: Theme.of(context).primaryColor,
                      outsideDaysVisible: false,
                    ),
                    onDaySelected: (day, events, holidays) {
                      _chosen = day;
                      setState(() {
                        _selectedEvents = events;
                      });
                    },
                    builders: CalendarBuilders(
                      markersBuilder: (context, date, events, holidays) {
                        final children = <Widget>[];
                        if (events.isNotEmpty) {
                          children.add(
                            Positioned(
                              right: 1,
                              bottom: 1,
                              child: _buildEventsMarker(date, events),
                            ),
                          );
                        }
                        return children;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(child: _buildEventList(_chosen)),
                ],
              ),
            ),
          );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.7),
      ),
      width: 8.0,
      height: 8.0,
    );
  }

  Widget _buildEventList(DateTime day) {
    final f = DateFormat('dd-MM-yyyy');
    String chosenday = f.format(day);
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (ctx, i) => RecordCard(
        _updatedrecords
            .where((element) =>
                f.format(DateTime.fromMillisecondsSinceEpoch(
                    double.parse(element.timestamp).toInt() * 1000)) ==
                chosenday)
            .toList()[i],
      ),
      itemCount: _updatedrecords
          .where((element) =>
              f.format(DateTime.fromMillisecondsSinceEpoch(
                  double.parse(element.timestamp).toInt() * 1000)) ==
              chosenday)
          .length,
    );
  }
}
