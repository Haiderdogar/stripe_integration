import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_integration/webviewScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51PXhhWHFN9uHDd0rnxsPH6aOs7EZGAvcTRHXCQAfQbYWbf7mqejZEfAfIogri0DqDBSxVKeKd7QuO0cP2SRxwb9h008QssWoSB';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await makePayment();
            },
            child: Center(
              child: Container(
                height: 50,
                width: 200,
                decoration: const BoxDecoration(color: Colors.green),
                child: const Center(
                  child: Text("Pay"),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Webviewscreen()),
              );
            },
            child: const Center(
              child: Center(
                child: Text("Next page"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent("2000",
          "USD"); // Ensure amount is in the smallest currency unit (e.g., cents for USD)

      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            merchantDisplayName: 'Haider',
            style: ThemeMode.dark,
          ),
        );

        displayPaymentSheet();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successfully completed')),
      );
    } on StripeException catch (e) {
      print('Error from Stripe: ${e.error.localizedMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      print('Payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card', // Correct the key
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization':
              'Bearer sk_test_51PXhhWHFN9uHDd0r5S4iQd02YzaZg8KNMohuomTjZ9FOuvV4RsSltt7YZg2AyiSz5hpKUWEkryxHYGIhRNudkleC00YHAv93L3',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to create payment intent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }
}
