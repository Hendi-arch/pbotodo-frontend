import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo/services/database_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();

  bool _isLoading = false;

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      String feedbackText = _feedbackController.text;

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await DatabaseService().addFeedback(feedbackText);

        if (response.statusCode == 200) {
          _showDialog('Success',
              'Thank you for your suggestion! We appreciate your feedback and will take it into consideration as we continue to improve our services.');
        } else {
          _showDialog('Error', 'Failed to submit feedback. Please try again.');
        }
      } catch (e) {
        Future.delayed(Duration.zero, () {
          _showDialog('Error', 'An error occurred. ${e.toString()}');
        });
      } finally {
        setState(() {
          _isLoading = false;
          _feedbackController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0).w,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Enter your feedback',
                ),
                maxLines: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    child: child,
                  );
                },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitFeedback,
                        child: const Text('Submit Feedback'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
