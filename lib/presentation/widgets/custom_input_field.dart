import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final bool enabled;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines != null && maxLines! > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: minLines,
              keyboardType: keyboardType,
              enabled: enabled,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.blackColor,
                fontWeight: isMultiline ? FontWeight.w400 : FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                fillColor: Colors.white,
                filled: true,
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppConstants.secondaryColor.withOpacity(0.5),
                  fontSize: 14,
                ),

                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: isMultiline ? 0 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
