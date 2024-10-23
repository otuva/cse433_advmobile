import 'package:flutter/material.dart';
import 'package:cse433_advmobile/bloc/categories_bloc.dart';
import 'package:cse433_advmobile/bloc/categories_bloc_provider.dart';
// import 'package:cse433_advmobile/theme/theme.dart';
import 'package:cse433_advmobile/ui/screens/navigation/book_navigation_screen.dart';

void main() {
  runApp(const BookStoreApp());
}

class BookStoreApp extends StatelessWidget {
  const BookStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoriesBlocProvider(
      categoriesBloc: CategoriesBloc(),
      child: MaterialApp(
        // theme: BookAppTheme.themeData,
        home: const BookNavigationScreen(),
      ),
    );
  }
}
