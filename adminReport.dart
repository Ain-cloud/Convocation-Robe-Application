import 'package:flutter/material.dart';
import 'package:selabdev4/adminMain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  @override
  State<AdminReport> createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  String selectedBatch = '2024'; // Default batch
  String selectedRobeType = 'Bachelor Robe'; // Default robe type

  final List<String> batches = ['2024', '2023', '2022', '2021'];
  final List<String> robeTypes = ['Bachelor Robe', 'Master Robe', 'PhD Robe'];

  Map<String, dynamic> inventoryData = {};
  bool isLoading = false;

  // Fetch report data from the backend
  Future<void> fetchReportData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://192.168.99.15:5000/api/report?robeType=$selectedRobeType&batch=$selectedBatch'));

      if (response.statusCode == 200) {
        setState(() {
          inventoryData = json.decode(response.body)['sizes'] ?? {};
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load report. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading report. Please try again.')),
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
    fetchReportData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(),
                  _buildBatchSelector(),
                  const SizedBox(height: 16),
                  _buildRobeTypeSelector(),
                  const SizedBox(height: 20),
                  const Text(
                    'Inventory Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInventoryGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildBatchSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Batch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: batches.map((batch) {
            final isSelected = selectedBatch == batch;
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedBatch = batch;
                  fetchReportData(); // Reload data
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xFF4C4DDC) : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(batch),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRobeTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Robe Type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: robeTypes.map((robeType) {
            final isSelected = selectedRobeType == robeType;
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedRobeType = robeType;
                  fetchReportData(); // Reload data
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xFF4C4DDC) : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(robeType),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInventoryGrid() {
    if (inventoryData.isEmpty) {
      return const Center(
        child: Text('No data available for the selected robe type and batch.'),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: inventoryData.entries.map((entry) {
        final size = entry.key;
        final stats = entry.value as Map<String, dynamic>;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  size,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total Stock: ${stats['stock']}'),
                Text('Collected: ${stats['collected']}'),
                Text('Returned: ${stats['returned']}'),
                Text('Future Needs: ${stats['future_req']}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
