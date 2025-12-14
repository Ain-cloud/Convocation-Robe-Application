import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraduandPaymentScreen extends StatefulWidget {
  @override
  _GraduandPaymentScreenState createState() => _GraduandPaymentScreenState();
}

class _GraduandPaymentScreenState extends State<GraduandPaymentScreen> {
  final TextEditingController _paymentAmountController =
      TextEditingController();
  double outstandingAmount = 0.00;
  bool isLoading = false;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String token = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    fetchOutstandingPayment();
    _loadTokenAndUserId();
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

  Future<void> fetchOutstandingPayment() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.99.15:6000/api/outstanding-payment/21'),
        headers: {
          'Authorization': 'Bearer $token',
        }, // Replace with dynamic user ID
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          outstandingAmount = double.tryParse(
                  data['outstanding_payment']?.toString() ?? '0.0') ??
              0.0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch outstanding payment.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> createPaymentIntent(String amount, String currency) async {
    final url = Uri.parse(
        'https://convorobeapplication-5a89faa4f33a.herokuapp.com/create-payment-intent');
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body.containsKey('clientSecret')) {
          final clientSecret = body['clientSecret'];

          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Convocation Robe Application',
            ),
          );
          await Stripe.instance.presentPaymentSheet();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );

          // Update outstanding payment
          await updateOutstandingPayment(amount);

          // Fetch updated outstanding payment
          await fetchOutstandingPayment();
        } else {
          throw Exception(
              'Payment intent creation did not return clientSecret');
        }
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Unknown error';
        throw Exception('Failed to create payment intent: $errorMessage');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOutstandingPayment(String amount) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.99.15:5000/api/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId, // Replace with actual user ID
          'paymentAmount': double.parse(amount) / 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          outstandingAmount = data['updatedOutstanding'] ?? 0.0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update outstanding payment.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating payment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fine"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fine Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Outstanding Payment",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    "RM${outstandingAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _paymentAmountController,
              decoration: InputDecoration(
                labelText: "Enter Payment Amount (RM)",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.money),
                suffixText: "RM",
              ),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final paymentAmount =
                            double.tryParse(_paymentAmountController.text);
                        if (paymentAmount != null &&
                            paymentAmount > 0 &&
                            paymentAmount <= outstandingAmount) {
                          final amountInCents =
                              (paymentAmount * 100).toInt().toString();
                          await createPaymentIntent(amountInCents, 'myr');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enter a valid payment amount')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text("Pay"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
