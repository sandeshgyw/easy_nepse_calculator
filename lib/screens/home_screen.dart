import 'package:easy_nepse_calculator/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Select Transaction Type",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: 'Buying', // Default value
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'Buying',
                    child: Text('Buying'),
                  ),
                  const DropdownMenuItem(
                    value: 'Selling',
                    child: Text('Selling'),
                  ),
                  const DropdownMenuItem(
                    value: 'Bonus Share Adjustment',
                    child: Text('Bonus Share Adjustment'),
                  ),
                  const DropdownMenuItem(
                    value: 'Right Share Adjustment',
                    child: Text('Right Share Adjustment'),
                  ),
                  const DropdownMenuItem(
                    value: 'Merger',
                    child: Text('Merger'),
                  ),
                ],
                onChanged: (value) {
                  // Handle the selection change logic here
                  print(value); // Or setState if needed
                },
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const CustomTextField(
                hintText: "Enter the buying price per share",
                labelText: "Buying Price per Share",
                keyboardType: TextInputType.phone,
              ),
              const Divider(),
              const CustomTextField(
                hintText: "Enter the total shares you're purchasing",
                labelText: "Number of Shares",
                keyboardType: TextInputType.phone,
              ),
              const Divider(),
              const CustomTextField(
                hintText: "Total Amount ",
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
