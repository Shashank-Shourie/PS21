import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps = [
    'Select Admission',
    'Upload Documents',
    'Fill Application',
    'Verification'
  ];

  ProgressStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: index <= currentStep 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                step,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: index == currentStep 
                    ? FontWeight.bold 
                    : FontWeight.normal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}