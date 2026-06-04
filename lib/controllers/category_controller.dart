import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/repository/category_repository.dart';

class CategoryController extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CategoryController() {
    _init();
  }

  void _init() {
    _repository.getCategoriesStream().listen((event) {
      _categories = event;
      notifyListeners();
    });
  }

  Future<void> addCategory(String name, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final category = CategoryModel(id: '', name: name, type: type);
      await _repository.addCategory(category);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _repository.updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
  }
}
