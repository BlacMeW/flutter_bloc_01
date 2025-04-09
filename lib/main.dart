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
      child: MaterialApp(title: 'Bloc App', home: CounterPage()),
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
              return Text('Count: $count');
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
