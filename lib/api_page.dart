import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/apibloc.dart';

class ApiPage extends StatelessWidget {
  const ApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Fetch with Bloc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<ApiBloc, ApiState>(
          listener: (context, state) {
            if (state.error.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<ApiBloc>().add(
                      FetchData(
                        url: 'https://jsonplaceholder.typicode.com/posts/1',
                        method: 'GET',
                      ),
                    );
                  },
                  child: const Text('Fetch Data (GET)'),
                ),
                const SizedBox(height: 20),
                Text(
                  state.data.isNotEmpty ? state.data : 'No data yet',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
