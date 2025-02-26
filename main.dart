import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(FitnessTrackerApp());

class FitnessTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _stepEntries = [];
  final List<Map<String, dynamic>> _waterEntries = [];
  final DateFormat _dateFormatter = DateFormat('MM/dd/yyyy');

  // Categorize steps
  String _getStepCategory(int steps) {
    if (steps < 4000) return 'Bad';
    if (steps <= 8000) return 'Average';
    return 'Good';
  }

  // Categorize water intake
  String _getWaterCategory(double liters) {
    if (liters < 1.5) return 'Bad';
    if (liters <= 2) return 'Average';
    return 'Good';
  }

  // Shared date picker
  Future<DateTime?> _pickDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
  }

  // Add steps with validation
  Future<void> _addSteps() async {
    final date = await _pickDate();
    if (date == null) return;

    final stepsController = TextEditingController();
    final steps = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Steps'),
        content: TextField(
          controller: stepsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter steps'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final parsedSteps = int.tryParse(stepsController.text);
              if (parsedSteps == null) {
                _showErrorDialog('Invalid steps input');
                return;
              }
              Navigator.pop(context, parsedSteps);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (steps != null) {
      setState(() {
        _stepEntries.add({
          'date': date,
          'steps': steps,
          'category': _getStepCategory(steps)
        });
      });
    }
  }

  // Add water with validation
  Future<void> _addWater() async {
    final date = await _pickDate();
    if (date == null) return;

    final amountController = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water Intake'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter liters'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final parsedAmount = double.tryParse(amountController.text);
              if (parsedAmount == null) {
                _showErrorDialog('Invalid water input');
                return;
              }
              Navigator.pop(context, parsedAmount);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (amount != null) {
      setState(() {
        _waterEntries.add({
          'date': date,
          'amount': amount,
          'category': _getWaterCategory(amount)
        });
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Tracker')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _addSteps,
                child: const Text('Add Steps'),
              ),
              ElevatedButton(
                onPressed: _addWater,
                child: const Text('Add Water'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                _buildEntriesSection(
                  title: 'Step Entries',
                  entries: _stepEntries,
                  valueBuilder: (entry) => '${entry['steps']} steps',
                ),
                _buildEntriesSection(
                  title: 'Water Intake Entries',
                  entries: _waterEntries,
                  valueBuilder: (entry) => '${entry['amount']} L',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesSection({
    required String title,
    required List<Map<String, dynamic>> entries,
    required String Function(Map<String, dynamic>) valueBuilder,
  }) {
    return ExpansionTile(
      title: Text(title),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              title: Text(
                '${_dateFormatter.format(entry['date'])}: ${valueBuilder(entry)}',
              ),
              subtitle: Text('Category: ${entry['category']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => entries.removeAt(index)),
              ),
            );
          },
        ),
      ],
    );
  }
}
