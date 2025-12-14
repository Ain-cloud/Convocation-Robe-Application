import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraduandBookingScreen extends StatefulWidget {
  @override
  _GraduandBookingScreenState createState() => _GraduandBookingScreenState();
}

class _GraduandBookingScreenState extends State<GraduandBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String selectedSize = "XS";
  List<Map<String, dynamic>> robes = [];
  bool isLoading = false;
  double outstandingAmount = 0.0;
  String token = '';
  int userId = 0;
  int robeId = 0;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadTokenAndUserId();
    fetchRobes();
  }

  Future<void> _loadTokenAndUserId() async {
    final storedToken = await secureStorage.read(key: 'token');
    final storedUserId = await secureStorage.read(key: 'userId');
    if (storedToken != null && storedUserId != null) {
      setState(() {
        token = storedToken;
        userId = int.parse(storedUserId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in again.')),
      );
      Navigator.pushReplacementNamed(context, 'graduandLogin');
    }
  }

  Future<void> fetchRobes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.99.15:5000/api/robes?size=$selectedSize'),
      );

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('application/json') ==
              true) {
        final data = json.decode(response.body);

        setState(() {
          robes = List<Map<String, dynamic>>.from(data);
        });
      } else {
        _showSnackBar('Unexpected response: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error loading robes: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> bookRobe(
      int robeId, int userId, DateTime selectedDate, double price) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.99.15:6000/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'robe_id': robeId,
          'booking_date': _selectedDate.toIso8601String().split('T')[0],
          'price': price,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message']);
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['error'] ?? responseBody['message']);
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message']);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Screen"),
        centerTitle: true, // Centers the title
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, 'notificationScreen');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF4C4DDC),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["XS", "S", "M", "L"].map((size) {
              return GestureDetector(
                onTap: () {
                  if (selectedSize != size) {
                    setState(() {
                      selectedSize = size;
                      fetchRobes();
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 37),
                  decoration: BoxDecoration(
                    color:
                        selectedSize == size ? Color(0xFF4C4DDC) : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: selectedSize == size ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: robes.isEmpty
                      ? const Center(child: Text("No robes available"))
                      : ListView.builder(
                          itemCount: robes.length,
                          itemBuilder: (context, index) {
                            final robe = robes[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                elevation: 3,
                                child: ListTile(
                                  leading: Image.asset(
                                    robe['image_url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    robe['type'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                      "Size: ${robe['size']}  Price: RM${robe['price']}"),
                                  trailing: ElevatedButton(
                                    onPressed: () => bookRobe(
                                        robe['robe_id'] is int
                                            ? robe['robe_id']
                                            : 0,
                                        userId,
                                        _selectedDate,
                                        double.parse(robe['price']
                                            .toString())), // Pass the price),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4C4DDC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation:
                                          3, // Controls the depth of the shadow
                                    ),
                                    child: const Text(
                                      'Book',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
