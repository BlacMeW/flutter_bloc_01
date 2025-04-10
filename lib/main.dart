import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<CounterBloc>(create: (_) => CounterBloc())],
      child: MaterialApp(
        title: 'Bloc App',
        home: CounterPage(),
        debugShowCheckedModeBanner: false,
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
        // Side effect when the count reaches a certain value
        if (state.count == 10) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Count reached 10!')));
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count2: ${state.count}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CounterBloc>().add(Increment());
              },
              child: const Text('Increment (Counter2)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<CounterBloc>().add(Decrement());
              },
              child: const Text('Decrement (Counter2)'),
            ),
          ],
        );
      },
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CounterBloc>();
    final bloc = context.read<CounterBloc>();

    return Scaffold(
      appBar: AppBar(title: Text('Bloc Counter')),
      body: Column(
        children: [
          BlocSelector<CounterBloc, CounterState, int>(
            selector: (state) => state.count,
            builder: (context, count) {
              return Text(
                'Count: $count',
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
          BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              return Text(
                'Count (BlockBuilder): ${state.count}',
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
          BlocBuilder<CounterBloc, CounterState>(
            buildWhen: (previous, current) => previous.count != current.count,
            builder: (context, state) {
              return Text(
                'Count (BlockBuilder): ${state.count}',
                style: const TextStyle(fontSize: 24),
              );
            },
          ),
          BlocListener<CounterBloc, CounterState>(
            listenWhen: (previous, current) => current.count == 10,
            listener: (context, state) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(title: Text("Reached 10!")),
              );
            },
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CounterBloc>().add(Increment()),
                  child: Text('Increment'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<CounterBloc>().add(Decrement()),
                  child: Text('Decrement'),
                ),
              ],
            ),
          ),
          Counter2(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => bloc.add(Increment()),
            child: Icon(Icons.add),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => bloc.add(Decrement()),
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
