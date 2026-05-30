import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/repository/store_repository.dart';

class StoreController extends ChangeNotifier {
  final StoreRepository _repository = StoreRepository();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  bool _isLoading = false;

  List<ProductModel> get products => _filteredProducts;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  StoreController() {
    _init();
  }

  void _init() {
    _isLoading = true;
    _repository.getProductsStream().listen((products) {
      _allProducts = products;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery) ||
          product.category.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'Tất cả' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.addProduct(product);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateProduct(product);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteProduct(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
