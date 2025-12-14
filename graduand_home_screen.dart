import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GraduandHomeScreen extends StatefulWidget {
  const GraduandHomeScreen({Key? key}) : super(key: key);

  @override
  _GraduandHomeScreenState createState() => _GraduandHomeScreenState();
}

class _GraduandHomeScreenState extends State<GraduandHomeScreen> {
  String selectedSize = 'XS'; // Currently selected size
  bool isLoading = true; // Loading state
  List<Map<String, dynamic>> robes = []; // List to hold robes
  Map<String, int> robeCounts = {}; // Holds robe counts from the API

  @override
  void initState() {
    super.initState();
    _fetchRobes();
  }

  // Fetch robes from the API
  Future<void> _fetchRobes() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.99.15:6000/robes?size=$selectedSize'));
      final countsResponse = await http.get(Uri.parse(
          'http://192.168.99.15:6000/count_robe')); // Correct endpoint

      if (response.statusCode == 200 && countsResponse.statusCode == 200) {
        setState(() {
          robes = List<Map<String, dynamic>>.from(json.decode(response.body));

          // Extract the first row from the count API response
          final countsData = json.decode(countsResponse.body);
          if (countsData.isNotEmpty) {
            robeCounts = Map<String, int>.from(countsData[0]); // Use first row
          } else {
            robeCounts = {}; // Default to empty map if no data
          }
        });
      } else {
        print('Failed to load robes or counts');
      }
    } catch (e) {
      print('Error fetching robes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hi User! Looking for a robe?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            _buildNotificationSection(),
            const Divider(),
            const SizedBox(height: 20),
            _buildFilterRow(),
            const SizedBox(height: 20),
            _buildRobeList(),
          ],
        ),
      ),
    );
  }

  // Notification Section (Don't delete)
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Latest Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        NotificationCard(
          dateTime: '03/12/2024 8:30 AM',
          message:
              'Booking Confirmed! Your robe booking is confirmed! Collection date...',
        ),
        SizedBox(height: 10),
        NotificationCard(
          dateTime: '03/12/2024 8:30 AM',
          message:
              'Don\'t Forget Your Robe! Your robe is ready for collection tomorrow...',
        ),
      ],
    );
  }

  // Filter Row
  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['XS', 'S', 'M', 'L'].map((size) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSize = size;
              _fetchRobes(); // Fetch robes again for the selected size
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 10),
            decoration: BoxDecoration(
              color: selectedSize == size ? Color(0xFF4C4DDC) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              size,
              style: TextStyle(
                color: selectedSize == size ? Colors.white : Color(0xFF939393),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Robe List Section
  Widget _buildRobeList() {
    return Column(
      children: robes.map((robe) {
        final robeKey =
            '${robe['types'].replaceAll(' ', '')}Robe_${robe['size']}';
        final count = robeCounts[robeKey] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RobeCard(
            robeType: robe['types'],
            size: robe['size'],
            availability: count > 0 ? 'Available' : 'Unavailable',
            availabilityColor:
                count > 0 ? Color(0xFF4C4DDC) : Color(0xFFDC4C4E),
            image: robe['image_url'],
          ),
        );
      }).toList(),
    );
  }
}

// Notification Card
class NotificationCard extends StatelessWidget {
  final String dateTime;
  final String message;

  const NotificationCard(
      {super.key, required this.dateTime, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_box_outlined, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Robe Card
class RobeCard extends StatelessWidget {
  final String robeType;
  final String size;
  final String availability;
  final Color availabilityColor;
  final String image;

  const RobeCard({
    super.key,
    required this.robeType,
    required this.size,
    required this.availability,
    required this.availabilityColor,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 6, // Blur radius
                offset: Offset(0, 3), // Shadow offset (x, y)
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(20), // Rounded corners for image
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover, // Ensure the image fits within the box
                ),
              ),
              child: image.isEmpty
                  ? const Icon(Icons.image_not_supported, size: 80)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type: $robeType',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text('Size: $size', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: availabilityColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            availability,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
