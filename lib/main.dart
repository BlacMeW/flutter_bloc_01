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
      child: MaterialApp(
        title: 'Bloc App',
        debugShowCheckedModeBanner: false,
        home: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterBloc = context.read<CounterBloc>();
    final apiBloc = context.read<ApiBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bloc Counter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// BlocSelector
            BlocSelector<CounterBloc, CounterState, int>(
              selector: (state) => state.count,
              builder:
                  (context, count) => Text(
                    'Count: $count',
                    style: const TextStyle(fontSize: 24),
                  ),
            ),

            /// BlocBuilder (Regular)
            BlocBuilder<CounterBloc, CounterState>(
              builder:
                  (context, state) => Text(
                    'Count (BlocBuilder): ${state.count}',
                    style: const TextStyle(fontSize: 24),
                  ),
            ),

            /// BlocBuilder (Conditional)
            BlocBuilder<CounterBloc, CounterState>(
              buildWhen: (previous, current) => previous.count != current.count,
              builder:
                  (context, state) => Text(
                    'Updated Count: ${state.count}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.blueAccent,
                    ),
                  ),
            ),

            const SizedBox(height: 20),

            /// BlocListener for special count milestones
            BlocListener<CounterBloc, CounterState>(
              listenWhen: (previous, current) => current.count == 10,
              listener: (context, state) {
                showDialog(
                  context: context,
                  builder:
                      (_) => const AlertDialog(
                        title: Text("🎉 Count reached 10!"),
                      ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
            ),

            const SizedBox(height: 20),

            /// Counter2 using BlocConsumer
            const Counter2(),

            const SizedBox(height: 20),

            /// API Bloc Usage - Fetch Button & Result
            ElevatedButton.icon(
              onPressed: () {
                apiBloc.add(
                  FetchData(
                    url: 'https://jsonplaceholder.typicode.com/posts/1',
                    method: 'GET',
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Fetch API Data'),
            ),

            const SizedBox(height: 10),

            BlocBuilder<ApiBloc, ApiState>(
              builder: (context, state) {
                if (state.loading) {
                  return const CircularProgressIndicator();
                }
                if (state.error.isNotEmpty) {
                  return Text(
                    '❌ Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return Text(
                  state.data.isNotEmpty ? state.data : 'No API data yet',
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => counterBloc.add(Increment()),
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: () => counterBloc.add(Decrement()),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

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
        } else if (state.count == 20) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('🔥 Count reached 20!')));
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Text(
              'Counter2 Value: ${state.count}',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.read<CounterBloc>().add(Increment()),
              child: const Text('Increment (Counter2)'),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () => context.read<CounterBloc>().add(Decrement()),
              child: const Text('Decrement (Counter2)'),
            ),
          ],
        );
      },
    );
  }
}
