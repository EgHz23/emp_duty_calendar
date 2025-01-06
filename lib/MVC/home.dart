import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/database_helper.dart';
import 'login.dart';
import '../Data/HolidaysAPI.dart';
import 'app_drawer.dart';
import '../main.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _events = [];
  Map<DateTime, List<Map<String, dynamic>>> _eventMap = {};
  Set<DateTime> _daysWithGroupEvents = {};
  int? _selectedGroupId;
  List<Map<String, dynamic>> _groups = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _fetchAndSaveHolidays();
    _loadGroups();
    _loadAllEvents();
    _loadEventsForDay(_selectedDay);
  }

  Future<void> _loadGroups() async {
    final groups = await DatabaseHelper.instance.getGroups();
    setState(() {
      _groups = groups;
    });
  }

  Future<void> _loadAllEvents() async {
    final dbHelper = DatabaseHelper.instance;
    final allEvents = await dbHelper.getAllEvents();
    final eventMap = <DateTime, List<Map<String, dynamic>>>{};
    final groupEventDays = <DateTime>{};

    for (var event in allEvents) {
      final eventDate = DateTime.parse(event['date']);
      eventMap[eventDate] ??= [];
      eventMap[eventDate]!.add(event);

      if (_selectedGroupId != null && event['group_id'] == _selectedGroupId) {
        groupEventDays.add(eventDate);
      }
    }

    setState(() {
      _eventMap = eventMap;
      _daysWithGroupEvents = groupEventDays;
    });
  }

  Future<void> _fetchAndSaveHolidays() async {
    final holidays = await fetchPublicHolidaysForCurrentYear();
    print("Holidays fetched and saved: $holidays");
    _loadAllEvents();
  }

  Future<void> _loadEventsForDay(DateTime date) async {
    final formattedDate = _formatDate(date);
    final events = await DatabaseHelper.instance.getEventsByDate(formattedDate);
    setState(() {
      _events = events;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dogodki',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: isDarkTheme ? Colors.black : Colors.blueAccent,
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
                    } else if (newValue == 'Teden') {
                      _calendarFormat = CalendarFormat.week;
                    }
                  });
                },
                items: ['Mesec', 'Teden']
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
      drawer: AppDrawer(
        isDarkTheme: isDarkTheme,
        onThemeChanged: (bool value) {
          ref.read(themeProvider.notifier).state = value;
        },
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
                    _loadEventsForDay(selectedDay);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final normalizedDate = DateTime(date.year, date.month, date.day);

                      if (_daysWithGroupEvents.contains(normalizedDate)) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (_eventMap[normalizedDate] != null &&
                          _eventMap[normalizedDate]!
                              .any((e) => e['is_holiday'] == 1)) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (_eventMap[normalizedDate] != null &&
                          _eventMap[normalizedDate]!.isNotEmpty) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.all(6.0),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: _selectedGroupId,
              isExpanded: true,
              hint: const Text("Select Group"),
              items: _groups.map((group) {
                return DropdownMenuItem<int>(
                  value: group['id'],
                  child: Text(group['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                  _loadAllEvents();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Dismissible(
                    key: Key(event['id'].toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Deletion"),
                              content: const Text(
                                  "Are you sure you want to delete this event?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (confirm) {
                        await _deleteEvent(event['id']);
                      }
                      return confirm;
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
                          "Time: ${event['time']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            print("Edit icon tapped for event: ${event['id']}");
                            _editEventDialog(context, event);
                          },
                          child: const Icon(Icons.edit, color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  );
                },
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

  Future<void> _deleteEvent(int eventId) async {
    await DatabaseHelper.instance.deleteEvent(eventId);
    _loadAllEvents();
    _loadEventsForDay(_selectedDay);
  }

  void _addEventDialog(BuildContext context) async {
    final TextEditingController eventController = TextEditingController();
    TimeOfDay? selectedTime;
    List<Map<String, dynamic>> groups = await DatabaseHelper.instance.getGroups();
    List<Map<String, dynamic>> locations = await DatabaseHelper.instance.getLocations();
    int? selectedGroupId;
    int? selectedLocationId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text("Add Event"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: eventController,
                  decoration: const InputDecoration(hintText: "Event Name"),
                ),
                TextButton(
                  onPressed: () async {
                    selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {});
                  },
                  child: Text(
                    selectedTime == null
                        ? "Select Time"
                        : "Time: ${selectedTime!.format(context)}",
                  ),
                ),
                DropdownButton<int>(
                  value: selectedGroupId,
                  isExpanded: true,
                  hint: const Text("Select Group"),
                  items: groups.map((group) {
                    return DropdownMenuItem<int>(
                      value: group['id'],
                      child: Text(group['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGroupId = value;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: selectedLocationId,
                  isExpanded: true,
                  hint: const Text("Select Location"),
                  items: locations.map((location) {
                    return DropdownMenuItem<int>(
                      value: location['id'],
                      child: Text(location['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLocationId = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (eventController.text.isNotEmpty && selectedTime != null) {
                    final newEvent = {
                      'date': _formatDate(_selectedDay),
                      'name': eventController.text,
                      'time': selectedTime!.format(context),
                      'group_id': selectedGroupId,
                      'location_id': selectedLocationId,
                    };
                    await DatabaseHelper.instance.insertEvent(newEvent);
                    _loadEventsForDay(_selectedDay);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

 void _editEventDialog(BuildContext context, Map<String, dynamic> event) async {
  // Create a mutable copy of the event
  final mutableEvent = Map<String, dynamic>.from(event);
  final TextEditingController eventController =
      TextEditingController(text: mutableEvent['name']);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Event"),
      content: TextField(
        controller: eventController,
        decoration: const InputDecoration(hintText: "Event Name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final newName = eventController.text.trim();
            if (newName.isNotEmpty) {
              try {
                // Update the mutable copy
                mutableEvent['name'] = newName;

                // Update the event in the database
                await DatabaseHelper.instance.updateEvent(mutableEvent);

                // Reload events to reflect the updated name
                _loadAllEvents();
                _loadEventsForDay(_selectedDay);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Event updated successfully")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update event: $e")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Event name cannot be empty")),
              );
            }

            Navigator.pop(context); // Close the dialog
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

}

