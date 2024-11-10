import 'package:flutter/material.dart';

class PredictionResult extends StatelessWidget {
  final String prediction;
  final double confidence;

  const PredictionResult({
    super.key,
    required this.prediction,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Prediction: $prediction',
                style: const TextStyle(fontSize: 20)),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
