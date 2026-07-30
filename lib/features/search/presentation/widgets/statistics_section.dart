import 'package:flutter/material.dart';

class StatisticsSection extends StatelessWidget {

  const StatisticsSection({
    super.key,
    required this.resultCount,
    required this.duration,
  });
  final int resultCount;
  final Duration duration;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        'About $resultCount results (${duration.inMilliseconds / 1000.0} seconds)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey,
        ),
      ),
    );
}
