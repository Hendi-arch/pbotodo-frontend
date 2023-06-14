import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthFieldValidationWidget extends StatelessWidget {
  final String title;
  final bool isValid;

  const AuthFieldValidationWidget({
    super.key,
    required this.isValid,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Radio.adaptive(
              value: true,
              groupValue: isValid,
              onChanged: null,
            ),
            SizedBox(width: 8.0.w),
            Text(title)
          ],
        ),
      ),
    );
  }
}
