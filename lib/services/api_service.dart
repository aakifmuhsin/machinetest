import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/feed.dart';
import '../models/category.dart';

class ApiService {
  // Mobile apps don't need CORS proxies. Use the API directly.
  static const String baseUrl = 'https://frijo.noviindus.in/api';
  static String? _token;

  // Build endpoint URI with CORS proxy when running on web
  static Uri _uri(String path) {
    final String url = '$baseUrl/$path';
    if (kIsWeb) {
      // Route via a simple CORS proxy for web builds
      // Note: For production, host your own proxy or enable CORS on the API
      return Uri.parse('https://cors-anywhere.herokuapp.com/' + Uri.encodeFull(url));
    }
    return Uri.parse(url);
  }

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  static Map<String, String> get _multipartHeaders {
    Map<String, String> headers = {};
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  // OTP Verification
  static Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String countryCode,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        _uri('otp_verified'),
        headers: _headers,
        body: jsonEncode({
          'country_code': countryCode,
          'phone': phone,
        }),
      );

      // Debug: log raw response
      // ignore: avoid_print
      print('otp_verified statusCode=${response.statusCode}');
      // ignore: avoid_print
      print('otp_verified body=${response.body}');

      final dynamic decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'raw': decoded};

      if (response.statusCode == 200 || response.statusCode == 202) {
        // Some APIs return a boolean field like `status` to indicate success.
        final bool status = (data['status'] == true) || (data['success'] == true);
        if (status || data.containsKey('token')) {
          return ApiResponse.success(data, message: 'OTP verified successfully');
        }
        return ApiResponse.error(
          data['message']?.toString() ?? 'OTP verification failed',
          message: 'Error',
        );
      }
      return ApiResponse.error(
        data['message']?.toString() ?? 'OTP verification failed',
        message: 'Error',
      );
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Get Categories
  static Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await http.get(
        _uri('category_list'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        final List raw = (data['categories'] as List?) ?? (data['data'] as List? ?? const []);
        final categories = raw
            .map((json) => Category.fromJson(json))
            .toList();
        return ApiResponse.success(categories, message: 'Categories fetched successfully');
      } else {
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch categories',
          message: 'Error',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Get Home Feeds
  static Future<ApiResponse<List<Feed>>> getHomeFeeds() async {
    try {
      final response = await http.get(
        _uri('home'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        // Server returns feeds under 'results'
        final List resultsList = (data['results'] as List? ?? const []);
        final feeds = resultsList.map((json) => Feed.fromJson(json as Map<String, dynamic>)).toList();
        return ApiResponse.success(feeds, message: 'Feeds fetched successfully');
      } else {
        return ApiResponse.error(
          data['message'] ?? 'Failed to fetch feeds',
          message: 'Error',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Create Feed
  static Future<ApiResponse<Map<String, dynamic>>> createFeed({
    File? video,
    Uint8List? videoBytes,
    String? videoName,
    File? thumbnail,
    Uint8List? thumbnailBytes,
    String? thumbnailName,
    required String description,
    required List<int> categories,
  }) async {
    try {
      print('🚀 Starting createFeed API call...');
      if (kIsWeb) {
        print('🌐 Running on Web');
        print('📁 Video name: $videoName');
        print('📁 Thumbnail name: $thumbnailName');
        print('📁 Video bytes: ${videoBytes?.length} bytes');
        print('📁 Thumbnail bytes: ${thumbnailBytes?.length} bytes');
      } else {
        print('📱 Running on Mobile');
        print('📁 Video path: ${video?.path}');
        print('📁 Thumbnail path: ${thumbnail?.path}');
      }
      print('📝 Description: $description');
      print('🏷️ Categories: $categories');
      print('🔑 Token: ${_token != null ? "Present" : "Missing"}');
      
      var request = http.MultipartRequest(
        'POST',
        _uri('my_feed'),
      );
      
      print('🌐 API URL: ${_uri('my_feed')}');
      
      request.headers.addAll(_multipartHeaders);
      print('📋 Headers: ${request.headers}');
      
      if (kIsWeb) {
        // Web: Use bytes
        if (videoBytes == null || videoName == null) {
          print('❌ Video bytes or name missing');
          return ApiResponse.error('Video file not found');
        }
        if (thumbnailBytes == null || thumbnailName == null) {
          print('❌ Thumbnail bytes or name missing');
          return ApiResponse.error('Thumbnail file not found');
        }
        
        print('📎 Adding video file (web)...');
        request.files.add(http.MultipartFile.fromBytes(
          'video',
          videoBytes,
          filename: videoName,
        ));
        
        print('📎 Adding thumbnail file (web)...');
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          thumbnailBytes,
          filename: thumbnailName,
        ));
      } else {
        // Mobile: Use File
        if (video == null || thumbnail == null) {
          print('❌ Video or thumbnail file missing');
          return ApiResponse.error('Files not found');
        }
        
        // Check if files exist
        if (!await video.exists()) {
          print('❌ Video file does not exist: ${video.path}');
          return ApiResponse.error('Video file not found');
        }
        if (!await thumbnail.exists()) {
          print('❌ Thumbnail file does not exist: ${thumbnail.path}');
          return ApiResponse.error('Thumbnail file not found');
        }
        
        print('📎 Adding video file (mobile)...');
        request.files.add(await http.MultipartFile.fromPath('video', video.path));
        
        print('📎 Adding thumbnail file (mobile)...');
        request.files.add(await http.MultipartFile.fromPath('image', thumbnail.path));
      }
      
      print('📝 Adding form fields...');
      request.fields['desc'] = description;
      request.fields['category'] = jsonEncode(categories);
      
      print('📤 Sending request...');
      final response = await request.send();
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response headers: ${response.headers}');
      
      final responseBody = await response.stream.bytesToString();
      print('📥 Response body: $responseBody');
      
      final data = jsonDecode(responseBody);
      print('📊 Parsed data: $data');
      
      if (response.statusCode == 200) {
        print('✅ Feed created successfully');
        return ApiResponse.success(data, message: 'Feed created successfully');
      } else {
        print('❌ Feed creation failed with status: ${response.statusCode}');
        return ApiResponse.error(
          data['message'] ?? 'Failed to create feed',
          message: 'Error',
        );
      }
    } catch (e) {
      print('💥 Exception in createFeed: $e');
      print('💥 Stack trace: ${StackTrace.current}');
      return ApiResponse.error('Network error: $e');
    }
  }
}

