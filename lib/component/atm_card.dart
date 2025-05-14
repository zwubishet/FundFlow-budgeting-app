import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart'; // Your TransactionProvider

class AtmCard extends StatefulWidget {
  final String? id; // Replaced email with cardholder name
  final double income;
  final double expense;
  final double net;

  const AtmCard({
    super.key,
    this.id,
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  _AtmCardState createState() => _AtmCardState();
}

class _AtmCardState extends State<AtmCard> with SingleTickerProviderStateMixin {
  bool _isFront = true; // Track card side for flip animation
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFront = !_isFront;
      _isFront ? _controller.reverse() : _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(
      context,
    ); // Optional: for dynamic data
    final cardNumber = '1234 5678 9012 3456'; // Replace with dynamic data
    final cvv = '123'; // Replace with dynamic data

    return GestureDetector(
      onTap: _flipCard, // Flip card on tap
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFront = _animation.value < 0.5;
          final angle = _animation.value * 3.14159; // Rotate 180 degrees
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(isFront ? angle : angle - 3.14159),
            child: isFront ? _buildFrontSide(cardNumber) : _buildBackSide(cvv),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(String cardNumber) {
    return Container(
      width: 350,
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFF3F51B5),
          ], // Premium dark blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle blurred background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('asset/money.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chip and Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.yellowAccent,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.memory,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                    Image.asset(
                      'asset/visa.png', // Replace with your logo asset
                      width: 50,
                      height: 30,
                      errorBuilder:
                          (context, error, stackTrace) => const Text(
                            'Bank',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                    ),
                  ],
                ),
                // Card Number
                Text(
                  cardNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Courier',
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Cardholder and Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cardholder',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          widget.id ?? 'John Doe',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Expires',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const Text(
                          '12/25', // Replace with dynamic data
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Financial Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFinancialItem('Income', widget.income, Colors.green),
                    _buildFinancialItem('Expense', widget.expense, Colors.red),
                    _buildFinancialItem('Net', widget.net, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide(String cvv) {
    return Container(
      width: 350,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark back for contrast
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Magnetic Strip
            Container(
              height: 40,
              color: Colors.black,
              margin: const EdgeInsets.only(bottom: 16),
            ),
            // CVV
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.white,
                  child: Text(
                    'CVV: $cvv',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // Signature Strip
            Container(
              height: 30,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'Authorized Signature',
                  style: TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
