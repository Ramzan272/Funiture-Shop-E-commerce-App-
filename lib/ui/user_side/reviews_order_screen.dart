import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for Firestore types
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/user_side/view_models/review_order_view_model.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../components/constants.dart';
import '../../models/furniture.dart'; // Needed for FurnitureOrder model
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:math' as math; // Keep this import if you still use math.min for substring

class ReviewOrderScreen extends StatefulWidget {
  final FurnitureOrder order;

  const ReviewOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  _ReviewOrderScreenState createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  // ViewModel instance
  late ReviewOrderViewModel _reviewOrderViewModel;

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel with the order
    _reviewOrderViewModel = ReviewOrderViewModel(widget.order);
  }

  @override
  void dispose() {
    // ViewModel is disposed by Provider if created via `create`,
    // but if created directly with `.value`, manually dispose.
    _reviewOrderViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ChangeNotifierProvider.value to provide the existing ViewModel instance
    return ChangeNotifierProvider<ReviewOrderViewModel>.value(
      value: _reviewOrderViewModel,
      child: Consumer<ReviewOrderViewModel>(
        builder: (context, reviewViewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(reviewViewModel.isEditing ? "Edit Review" : "Rate Your Order"),
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            body: reviewViewModel.isLoading && !reviewViewModel.isEditing // Only show initial load if not editing (i.e., not already loaded text)
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${reviewViewModel.order.id.substring(0, math.min(8, reviewViewModel.order.id.length))}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: \$${reviewViewModel.order.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your Rating:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingBar.builder(
                      initialRating: reviewViewModel.currentRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        reviewViewModel.updateRating(rating); // Call ViewModel method
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your Review:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewViewModel.reviewController, // Use ViewModel's controller
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: reviewViewModel.isLoading // Disable button if loading
                          ? null
                          : () async {
                        try {
                          await reviewViewModel.submitReview();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(reviewViewModel.isEditing ? "Review updated successfully!" : "Review submitted successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Pop with 'true' to indicate a review was submitted/updated
                            Navigator.of(context).pop(true);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: reviewViewModel.isLoading // Show loading indicator in button
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                          : Text(reviewViewModel.isEditing ? "Update Review" : "Submit Review"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}