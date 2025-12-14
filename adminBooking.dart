import 'package:flutter/material.dart';
import 'package:selabdev4/adminMain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminBooking extends StatefulWidget {
  const AdminBooking({super.key});

  @override
  State<AdminBooking> createState() => _AdminBookingState();
}

class _AdminBookingState extends State<AdminBooking> {
  String selectedStatus = 'Active';
  String selectedRobeType = 'Bachelor Robe';
  String selectedSize = 'XS';
  late Future<List<Map<String, dynamic>>> bookings;

  final List<String> bookingStatuses = ['Active', 'Past'];
  final List<String> robeTypes = ['Bachelor Robe', 'Master Robe', 'PhD Robe'];
  final List<String> sizes = ['XS', 'S', 'M', 'L'];

  @override
  void initState() {
    super.initState();
    bookings = fetchBookings(selectedRobeType, selectedSize, selectedStatus);
  }

  Future<List<Map<String, dynamic>>> fetchBookings(String robeType, String size, String status) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.99.15:5000/api/bookings?robeType=$robeType&size=$size&status=$status'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      throw Exception('Unable to load bookings. Check connection.');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      print('Updating booking ID: $bookingId with collection status: $newStatus');
      final response = await http.put(
        Uri.parse('http://192.168.99.15:5000/api/bookings/$bookingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'collection_status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
        setState(() {
          bookings = fetchBookings(selectedRobeType, selectedSize, selectedStatus);
        });
      } else {
        throw Exception('Failed to update booking status');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminMain(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection('Booking Status', bookingStatuses, selectedStatus, (value) {
              setState(() {
                selectedStatus = value;
                bookings = fetchBookings(selectedRobeType, selectedSize, selectedStatus);
              });
            }),
            const SizedBox(height: 16),
            _buildFilterSection('Robe Type', robeTypes, selectedRobeType, (value) {
              setState(() {
                selectedRobeType = value;
                bookings = fetchBookings(selectedRobeType, selectedSize, selectedStatus);
              });
            }),
            const SizedBox(height: 16),
            _buildFilterSection('Size', sizes, selectedSize, (value) {
              setState(() {
                selectedSize = value;
                bookings = fetchBookings(selectedRobeType, selectedSize, selectedStatus);
              });
            }),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: bookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('No bookings found. Data: ${snapshot.data}');
                    return const Center(child: Text('No bookings found'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final booking = snapshot.data![index];
                      final robeImage = _getRobeImage(booking['robeType']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Image.asset(
                            robeImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text('Type: ${booking['robeType']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Booking ID: ${booking['booking_id']}'),
                              Text('Size: ${booking['size']}'),
                              Text('Status: ${booking['status']}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) =>
                                updateBookingStatus(booking['booking_id'].toString(), value),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Collected', child: Text('Mark as Collected')),
                              const PopupMenuItem(value: 'Returned', child: Text('Mark as Returned')),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String label, List<String> options, String selectedValue, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: options
              .map(
                (option) => ElevatedButton(
                  onPressed: () => onSelected(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedValue == option ? Color(0xFF4C4DDC) : Colors.white,
                    foregroundColor: selectedValue == option ? Colors.white : Colors.black,
                  ),
                  child: Text(option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _getRobeImage(String robeType) {
    switch (robeType) {
      case 'Master Robe':
        return 'assets/Master_robe.jpg';
      case 'PhD Robe':
        return 'assets/PHD_robe.jpg';
      case 'Bachelor Robe':
      default:
        return 'assets/Bachelor_robe.jpg';
    }
  }
}
