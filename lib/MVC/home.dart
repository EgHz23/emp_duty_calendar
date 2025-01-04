import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../Data/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<String> _calendarFormats = ['Teden', 'Mesec'];

  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();

    // Listen for accelerometer changes to detect orientation
    accelerometerEvents.listen((event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      // Determine if the device is in landscape orientation
      bool isLandscape = (x.abs() > y.abs()) && z.abs() < 2.0;

      if (isLandscape != _isLandscape) {
        setState(() {
          _isLandscape = isLandscape;
          _calendarFormat = _isLandscape ? CalendarFormat.week : CalendarFormat.month;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _calendarFormat == CalendarFormat.month ? 'Mesec' : 'Teden',
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == 'Mesec') {
                      _calendarFormat = CalendarFormat.month;
                    } else {
                      _calendarFormat = CalendarFormat.week;
                    }
                  });
                },
                items: _calendarFormats
                    .map((format) => DropdownMenuItem<String>(
                  value: format,
                  child: Text(format),
                ))
                    .toList(),
                icon: const Icon(Icons.calendar_view_month, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                    markerDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  eventLoader: (day) => _events[day] ?? [],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: (_events[_selectedDay] ?? [])
                    .map((event) => Dismissible(
                  key: Key(event['name']),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editEventDialog(context, event);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      return await _confirmDeleteDialog(context);
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _events[_selectedDay]?.remove(event);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Dogodek zbrisan")),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        event['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Čas: ${event['time'].format(context)}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: const Icon(
                        Icons.edit,
                        color: Colors.blueAccent,
                      ),
                      onTap: () => _editEventDialog(context, event),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEventDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
  Future<bool> _confirmDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Potrdi izbris", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Ali žeilte zbrisati dogodek?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("prekini"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Zbriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _editEventDialog(BuildContext context, Map<String, dynamic> event) {
    final TextEditingController eventController = TextEditingController(text: event['name']);
    TimeOfDay selectedTime = event['time'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text("Uredi Dogodek", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: eventController,
                  decoration: const InputDecoration(hintText: "Uredi ime dogodka"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Text("Čas: ${selectedTime.format(context)}"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Prekini"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (eventController.text.isNotEmpty) {
                      final eventIndex = _events[_selectedDay]!.indexOf(event);
                      _events[_selectedDay]![eventIndex] = {
                        'name': eventController.text,
                        'time': selectedTime,
                      };
                      // Sort events by time
                      _events[_selectedDay]!.sort((a, b) =>
                      a['time'].hour.compareTo(b['time'].hour) == 0
                          ? a['time'].minute.compareTo(b['time'].minute)
                          : a['time'].hour.compareTo(b['time'].hour));
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text("Shrani", style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _events[_selectedDay]?.remove(event);
                  });
                  Navigator.pop(context);
                },
                child: const Text("Zbriši", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addEventDialog(BuildContext context) {
    final TextEditingController eventController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
          final dialogWidth = MediaQuery.of(context).size.width * (isLandscape ? 0.6 : 0.8);
          final dialogHeight = MediaQuery.of(context).size.height * (isLandscape ? 0.6 : 0.4);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Dodaj dogodek",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 18 : 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: eventController,
                      decoration: const InputDecoration(
                        hintText: "Ime dogodka",
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {}); // Trigger the dialog to rebuild and show selected time
                        }
                      },
                      child: Text(
                        selectedTime == null
                            ? "Izberi čas"
                            : "Čas: ${selectedTime!.format(context)}",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Prekini"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (eventController.text.isNotEmpty && selectedTime != null) {
                              setState(() {
                                final newEvent = {
                                  'name': eventController.text,
                                  'time': selectedTime!,
                                };
                                if (_events[_selectedDay] != null) {
                                  _events[_selectedDay]!.add(newEvent);
                                } else {
                                  _events[_selectedDay] = [newEvent];
                                }
                                // Sort events by time
                                _events[_selectedDay]!.sort((a, b) =>
                                a['time'].hour.compareTo(b['time'].hour) == 0
                                    ? a['time'].minute.compareTo(b['time'].minute)
                                    : a['time'].hour.compareTo(b['time'].hour));
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Dodaj"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


}
