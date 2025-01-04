import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Data/database_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEventsForDay(_selectedDay);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadEventsForDay(selectedDay);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(event['name']),
                    subtitle: Text("Time: ${event['time']}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(event['id']),
                    ),
                    onTap: () => _editEventDialog(event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addEventDialog,
      ),
    );
  }

  Future<void> _addEventDialog() async {
    final nameController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                SizedBox(height: 10),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty && selectedTime != null) {
                    final newEvent = {
                      'date': _formatDate(_selectedDay),
                      'name': nameController.text,
                      'time': '${selectedTime!.hour}:${selectedTime!.minute}',
                    };
                    await DatabaseHelper.instance.insertEvent(newEvent);
                    _loadEventsForDay(_selectedDay);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event added')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editEventDialog(Map<String, dynamic> event) async {
    final nameController = TextEditingController(text: event['name']);
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(event['time'].split(':')[0]),
      minute: int.parse(event['time'].split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                ),
                SizedBox(height: 10),
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
                  child: Text("Time: ${selectedTime.format(context)}"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final updatedEvent = {
                    'date': _formatDate(_selectedDay),
                    'name': nameController.text,
                    'time': '${selectedTime.hour}:${selectedTime.minute}',
                  };
                  await DatabaseHelper.instance.updateEvent(event['id'], updatedEvent);
                  _loadEventsForDay(_selectedDay);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event updated')),
                  );
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteEvent(int id) async {
    await DatabaseHelper.instance.deleteEvent(id);
    _loadEventsForDay(_selectedDay);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event deleted')),
    );
  }
}
