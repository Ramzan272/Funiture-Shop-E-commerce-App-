import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../components/constants.dart';
import '../../../models/furniture.dart';

class AdminReviewViewScreen extends StatefulWidget {
  final String orderId;
  final FurnitureOrder order;

  const AdminReviewViewScreen({Key? key, required this.orderId, required this.order}) : super(key: key);

  @override
  _AdminReviewViewScreenState createState() => _AdminReviewViewScreenState();
}

class _AdminReviewViewScreenState extends State<AdminReviewViewScreen> {
  Map<String, dynamic>? _reviewData;
  bool _isLoading = true;
  bool _reviewFound = false;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('orderId', isEqualTo: widget.orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _reviewData = querySnapshot.docs.first.data();
          _reviewFound = true;
        });
      } else {
        setState(() {
          _reviewFound = false;
        });
      }
    } catch (e) {
      print("Error fetching review for admin: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading review: $e"), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _reviewFound = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Review"),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _reviewFound
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review for Order #${widget.order.id.substring(0, math.min(8, widget.order.id.length))}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Customer: ${widget.order.customerName ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "Rating:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: RatingBarIndicator(
                rating: (_reviewData!['rating'] as num?)?.toDouble() ?? 0.0,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 40.0,
                direction: Axis.horizontal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Review Text:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _reviewData!['reviewText'] as String? ?? 'No review text provided.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_reviewData!['timestamp'] != null)
              Text(
                'Submitted on: ${_formatTimestamp(_reviewData!['timestamp'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "No review found for this order.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate().toLocal().toString().split(' ')[0];
    }
    return 'N/A';
  }
}