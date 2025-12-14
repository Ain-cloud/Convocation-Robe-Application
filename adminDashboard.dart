import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'adminLogin.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedRobeType = 'Bachelor Robe';
  String selectedSize = 'XS';

  final List<String> robeTypes = ['Bachelor Robe', 'Master Robe', 'PhD Robe'];
  final List<String> sizes = ['XS', 'S', 'M', 'L'];

  Map<String, dynamic> readyStock = {};
  List<dynamic> bookingStatuses = [];
  List<dynamic> flaggedItems = [];

  bool isLoading = true;

  // Fetch data from the backend
  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://192.168.99.15:5000/api/admin-dashboard?robeType=$selectedRobeType&size=$selectedSize'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          readyStock = data['readyStock'] ?? {};
          bookingStatuses = data['bookingStatuses'] ?? [];
          flaggedItems = data['flaggedItems'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load data. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading data. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLogin()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hi Staff/Admin! Have a nice day!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildReadyStockOverview(),
                  const SizedBox(height: 20),
                  _buildFilterSection(),
                  const SizedBox(height: 20),
                  const Text(
                    'Booking Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildBookingStatusList(),
                  const SizedBox(height: 20),
                  const Text(
                    'Flagged Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildFlaggedItemsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildReadyStockOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Robe Ready Stock',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: sizes.map((size) {
                  final stock = readyStock[size] ?? 0;
                  return Expanded(
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              size,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$stock Ready',
                              style: const TextStyle(
                                color: Color(0xFF4C4DDC),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Robe Type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 10,
          children: robeTypes
              .map((type) => _buildFilterButton(type, selectedRobeType, (value) {
                    setState(() {
                      selectedRobeType = value;
                      fetchDashboardData();
                    });
                  }))
              .toList(),
        ),
        const SizedBox(height: 10),
        const Text(
          'Size',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 10,
          children: sizes
              .map((size) => _buildFilterButton(size, selectedSize, (value) {
                    setState(() {
                      selectedSize = value;
                      fetchDashboardData();
                    });
                  }))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFilterButton(
      String label, String selectedValue, ValueChanged<String> onTap) {
    final isSelected = selectedValue == label;
    return ElevatedButton(
      onPressed: () => onTap(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF4C4DDC) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSelected ? Color(0xFF4C4DDC) : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildBookingStatusList() {
    return bookingStatuses.isEmpty
        ? const Center(child: Text('No bookings found for this selection.'))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookingStatuses.length,
            itemBuilder: (context, index) {
              final item = bookingStatuses[index];
              final robeImage = _getRobeImage(selectedRobeType);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Image.asset(
                    robeImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text('Booking ID: ${item['bookingId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Size: ${item['size']}'),
                      Text('Status: ${item['status']}'),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildFlaggedItemsList() {
    return flaggedItems.isEmpty
        ? const Center(child: Text('No flagged items available.'))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: flaggedItems.length,
            itemBuilder: (context, index) {
              final item = flaggedItems[index];
              final robeImage = _getRobeImage(selectedRobeType);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Image.asset(
                    robeImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text('Robe ID: ${item['robeId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Size: ${item['size']}'),
                      Text('Condition: ${item['flaggedCondition']}'),
                    ],
                  ),
                ),
              );
            },
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
