import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/feed.dart';
import '../models/category.dart';

class FeedProvider with ChangeNotifier {
  List<Feed> _feeds = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;

  List<Feed> get feeds => _feeds;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getCategories();
      
      if (response.success && response.data != null) {
        _categories = response.data!;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeeds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getHomeFeeds();
      
      if (response.success && response.data != null) {
        _feeds = response.data!;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Feed> get filteredFeeds {
    if (_selectedCategory == null || _selectedCategory == 'All Categories' || _selectedCategory == 'Explore' || _selectedCategory == 'Trending') {
      return _feeds;
    }
    
    return _feeds.where((feed) {
      // Our feed items currently don't include category ids from the home API
      // So we filter by category name only if categories were attached later
      return true;
    }).toList();
  }

  Future<bool> createFeed({
    required String videoPath,
    required String thumbnailPath,
    required String description,
    required List<int> categories,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Note: In a real app, you'd need to convert file paths to File objects
      // This is a simplified version
      final response = await ApiService.createFeed(
        video: File(videoPath),
        thumbnail: File(thumbnailPath),
        description: description,
        categories: categories,
      );

      if (response.success) {
        // Reload feeds after successful creation
        await loadFeeds();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
