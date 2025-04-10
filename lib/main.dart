import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/apibloc.dart';
import 'bloc/bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterBloc()),
        BlocProvider(create: (_) => ApiBloc()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterBloc = context.read<CounterBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bloc Counter & API Fetch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Counter display
            BlocBuilder<CounterBloc, CounterState>(
              builder:
                  (context, state) => Text(
                    'Counter: ${state.count}',
                    style: const TextStyle(fontSize: 24),
                  ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () => counterBloc.add(Increment()),
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => counterBloc.add(Decrement()),
                  child: const Text('Decrement'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Counter2(),

            const Divider(height: 40),
            const Text(
              '🔎 API Fetch Section',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const ApiInputWidget(),

            const SizedBox(height: 20),

            /// API Result display
            BlocBuilder<ApiBloc, ApiState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.error.isNotEmpty) {
                  return Text(
                    '❌ Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                } else if (state.data.isNotEmpty) {
                  return Text(
                    '✅ Response:\n${state.data}',
                    style: const TextStyle(fontSize: 14),
                  );
                } else {
                  return const Text('No response yet.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Counter2 with BlocConsumer
class Counter2 extends StatelessWidget {
  const Counter2({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterBloc, CounterState>(
      listener: (context, state) {
        if (state.count == 10) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('🎯 Count reached 10!')));
        }
      },
      builder:
          (context, state) => Column(
            children: [
              Text(
                'Counter2: ${state.count}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => context.read<CounterBloc>().add(Increment()),
                child: const Text('Increment (Counter2)'),
              ),
            ],
          ),
    );
  }
}

/// API Input Widget
class ApiInputWidget extends StatefulWidget {
  const ApiInputWidget({super.key});

  @override
  State<ApiInputWidget> createState() => _ApiInputWidgetState();
}

class _ApiInputWidgetState extends State<ApiInputWidget> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedMethod = 'GET';
  final List<String> _methods = ['GET', 'POST', 'PUT', 'DELETE'];

  @override
  Widget build(BuildContext context) {
    final apiBloc = context.read<ApiBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("API URL:"),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'Enter API URL...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const Text("HTTP Method:"),
        DropdownButton<String>(
          value: _selectedMethod,
          items:
              _methods
                  .map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedMethod = value);
            }
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isNotEmpty) {
              apiBloc.add(FetchData(url: url, method: _selectedMethod));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid URL')),
              );
            }
          },
          child: const Text('Fetch Data'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
