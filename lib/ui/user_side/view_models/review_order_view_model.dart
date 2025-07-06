import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/furniture.dart';

class ReviewOrderViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FurnitureOrder _order; // The order for which the review is being written

  TextEditingController _reviewController = TextEditingController();
  double _currentRating = 0;
  bool _isEditing = false;
  String? _existingReviewId;
  bool _isLoading = false; // Add a loading state for review submission

  // Getters to expose state to the UI
  TextEditingController get reviewController => _reviewController;
  double get currentRating => _currentRating;
  bool get isEditing => _isEditing;
  FurnitureOrder get order => _order;
  bool get isLoading => _isLoading;

  // Constructor
  ReviewOrderViewModel(this._order) {
    _loadExistingReview();
  }

  // --- Load Existing Review ---
  Future<void> _loadExistingReview() async {
    _isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('orderId', isEqualTo: _order.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingReview = querySnapshot.docs.first;
        _existingReviewId = existingReview.id;
        _currentRating = (existingReview['rating'] as num?)?.toDouble() ?? 0.0;
        _reviewController.text = existingReview['reviewText'] as String? ?? '';
        _isEditing = true;
      }
    } catch (e) {
      print("Error loading existing review: $e");
      // Re-throw to allow UI to show snackbar
      throw Exception("Error loading review: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Update Rating from UI ---
  void updateRating(double rating) {
    _currentRating = rating;
    notifyListeners();
  }

  // --- Submit/Update Review ---
  Future<void> submitReview() async {
    if (_currentRating == 0) {
      throw Exception("Please provide a star rating.");
    }

    if (_reviewController.text.trim().isEmpty) {
      throw Exception("Please write a review.");
    }

    _isLoading = true;
    notifyListeners(); // Show loading indicator

    try {
      // It's safer to fetch the customerEmail from the order itself, or directly from FirebaseAuth if available
      // For simplicity, we'll use the email stored on the order in Firestore.
      String? customerEmail;
      try {
        final orderDoc = await _firestore.collection('orders').doc(_order.id).get();
        customerEmail = orderDoc.data()?['customerEmail'] as String?;
      } catch (e) {
        print("Error fetching customer email for review: $e");
        // Don't necessarily fail if email can't be fetched, but log it
      }

      final reviewData = {
        'orderId': _order.id,
        'userId': customerEmail, // Use the fetched customer email as userId for the review
        'productId': _order.items.isNotEmpty ? _order.items.first['productId'] : null,
        'rating': _currentRating,
        'reviewText': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _existingReviewId != null) {
        await _firestore.collection('reviews').doc(_existingReviewId).update(reviewData);
      } else {
        await _firestore.collection('reviews').add(reviewData);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error submitting review: $e");
      throw Exception("Error submitting review: $e"); // Re-throw for UI error handling
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}