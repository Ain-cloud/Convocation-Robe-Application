import 'package:flutter/material.dart';
import 'package:selabdev4/adminMain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminInventory extends StatefulWidget {
  const AdminInventory({super.key});

  @override
  State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory> {
  String selectedRobeType = 'Bachelor Robe'; // Default robe type
  String selectedSize = 'XS'; // Default size

  final List<String> robeTypes = ['Bachelor Robe', 'Master Robe', 'PhD Robe'];
  final List<String> sizes = ['XS', 'S', 'M', 'L'];

  List<Map<String, dynamic>> inventoryData = [];
  bool isLoading = false;
  bool isUpdating = false;

  // Fetch data from API
  Future<void> fetchInventory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
        'http://192.168.99.15:5000/api/inventory?robeType=$selectedRobeType&size=$selectedSize',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          inventoryData = data
              .map((item) => {
                    'robe_id': item['robe_id'].toString(),
                    'type': item['type'].toString(),
                    'size': item['size'].toString(),
                    'status': item['status'].toString(),
                    'robe_condition': item['robe_condition'].toString(),
                  })
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load inventory. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading inventory. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update robe condition
  Future<void> updateCondition(String robe_id, String newCondition) async {
    setState(() {
      isUpdating = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://192.168.99.15:5000/api/inventory/$robe_id'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode({'robe_condition': newCondition}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final item = inventoryData.firstWhere((element) => element['robe_id'] == robe_id);
          item['robe_condition'] = newCondition;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Condition updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update condition. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating condition. Please try again.')),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  // Show confirmation dialog for condition update
  void showConfirmationDialog(String robe_id, String newCondition) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: Text('Are you sure you want to update the condition to "$newCondition"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                updateCondition(robe_id, newCondition);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
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
            _buildFilterSection(
              'Robe Type',
              robeTypes,
              selectedRobeType,
              (value) {
                setState(() {
                  selectedRobeType = value;
                });
                fetchInventory();
              },
            ),
            const SizedBox(height: 10),
            _buildFilterSection(
              'Size',
              sizes,
              selectedSize,
              (value) {
                setState(() {
                  selectedSize = value;
                });
                fetchInventory();
              },
            ),
            const SizedBox(height: 10),
            Expanded(child: isLoading ? const Center(child: CircularProgressIndicator()) : _buildInventoryList()),
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: options
              .map(
                (option) => ElevatedButton(
                  onPressed: () => onSelected(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: option == selectedValue ? Color(0xFF4C4DDC) : Colors.white,
                    foregroundColor: option == selectedValue ? Colors.white : Colors.black,
                  ),
                  child: Text(option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInventoryList() {
    if (inventoryData.isEmpty) {
      return const Center(
        child: Text('No items available for this selection.'),
      );
    }

    return ListView.separated(
      itemCount: inventoryData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = inventoryData[index];
        final robeImage = _getRobeImage(item['type']);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  robeImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: ${item['type']}',
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        'Robe ID: ${item['robe_id']}',
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        'Size: ${item['size']}',
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      Text(
                        'Condition: ${item['robe_condition']}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    showConfirmationDialog(item['robe_id']!, value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Perfect',
                      child: Text('Mark as Perfect'),
                    ),
                    const PopupMenuItem(
                      value: 'Maintenance',
                      child: Text('Flag for Maintenance'),
                    ),
                    const PopupMenuItem(
                      value: 'Repair',
                      child: Text('Flag for Repair'),
                    ),
                  ],
                ),
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
