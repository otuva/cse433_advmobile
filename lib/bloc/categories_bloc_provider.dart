import 'package:flutter/cupertino.dart';
import 'package:cse433_advmobile/bloc/categories_bloc.dart';

class CategoriesBlocProvider extends InheritedWidget {
  const CategoriesBlocProvider({
    super.key,
    required this.categoriesBloc,
    required super.child,
  });

  final CategoriesBloc categoriesBloc;

  static CategoriesBlocProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CategoriesBlocProvider>();
  }

  @override
  bool updateShouldNotify(CategoriesBlocProvider oldWidget) => true;
}
