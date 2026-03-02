import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quimanda/app/modules/home/cubit/home_cubit.dart';
import 'package:quimanda/app/modules/home/views/home_view.dart';
import 'package:quimanda/app/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}
w
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'quiManda',
      theme: AppTheme.theme,
      home: BlocProvider(
        create: (_) => HomeCubit(),
        child: const HomeView(),
      ),
    );
  }
}
