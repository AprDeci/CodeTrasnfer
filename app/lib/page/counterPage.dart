import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:code_transfer/bloc/cubit/counter_cubit.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterCubit, int>(
        builder: (context, count) {
          return Center(
            child: Text('$count', style: TextStyle(fontSize: 24.0)),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
                heroTag: Object(),
              child: Icon(Icons.add),
              onPressed: () => context.read<CounterCubit>().increment(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
    heroTag: Object(),
              child: Icon(Icons.remove),
              onPressed: () => context.read<CounterCubit>().decrement(),
            ),
          ),
        ],
      ),
    );
  }
}
