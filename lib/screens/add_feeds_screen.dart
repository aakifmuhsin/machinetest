import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../providers/feed_provider.dart';
import '../constants/app_colors.dart';

class AddFeedsScreen extends StatefulWidget {
  const AddFeedsScreen({super.key});

  @override
  State<AddFeedsScreen> createState() => _AddFeedsScreenState();
}

class _AddFeedsScreenState extends State<AddFeedsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedVideo;
  File? _selectedThumbnail;
  Uint8List? _selectedVideoBytes;
  Uint8List? _selectedThumbnailBytes;
  String? _selectedVideoName;
  String? _selectedThumbnailName;
  List<int> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      feedProvider.loadCategories();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            'assests/images/arrow_back.svg',
            width: 26,
            height: 26,
          ),
        ),
        title: const Text(
          'Add Feeds',
          style: TextStyle(
    fontFamily: 'Montserrat',
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _handleSubmit,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: AppColors.primaryText,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: const StadiumBorder(side: BorderSide(
          color: AppColors.accentRed, // 👈 your red border
          width: 1.5, // optional: adjust thickness
        ),),
              ),
              child: const Text(
                'Share Post',
                style: TextStyle(
    fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video upload section
              _buildVideoUploadSection(),
              const SizedBox(height: 20),
              // Thumbnail upload section
              _buildThumbnailUploadSection(),
              const SizedBox(height: 20),
              // Description section
              _buildDescriptionSection(),
              const SizedBox(height: 20),
              // Categories section
              _buildCategoriesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Video',
          style: TextStyle(
    fontFamily: 'Montserrat',
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.borderColor,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedVideo != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assests/images/video_library_outlined.svg',
                        width: 54,
                        height: 53,
                        colorFilter: const ColorFilter.mode(AppColors.primaryText, BlendMode.srcIn),
                      ),
                      SizedBox(height: 12),
                      Text(
                        kIsWeb ? _selectedVideoName ?? 'Unknown' : _selectedVideo!.path.split(RegExp(r'[\\/]')).last,
                        style: const TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Video selected',
                        style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assests/images/video_library_outlined.svg',
                        width: 54,
                        height: 53,
                        colorFilter: const ColorFilter.mode(AppColors.primaryText, BlendMode.srcIn),
                      ),
                      SizedBox(height: 12),
                      const Text(
                        'Select a video from Gallery',
                        style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Thumbnail',
          style: TextStyle(
    fontFamily: 'Montserrat',
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.borderColor,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedThumbnail != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assests/images/image_outlined.svg',
                        width: 35,
                        height: 25,
                        colorFilter: const ColorFilter.mode(AppColors.primaryText, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kIsWeb ? _selectedThumbnailName ?? 'Unknown' : _selectedThumbnail!.path.split(RegExp(r'[\\/]')).last,
                        style: const TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Thumbnail selected',
                        style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assests/images/image_outlined.svg',
                        width: 35,
                        height: 25,
                        colorFilter: const ColorFilter.mode(AppColors.primaryText, BlendMode.srcIn),
                      ),
                      SizedBox(width: 12),
                      const Text(
                        'Add a Thumbnail',
                        style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Description',
          style: TextStyle(
    fontFamily: 'Montserrat',
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          style: const TextStyle(
    fontFamily: 'Montserrat',color: AppColors.primaryText),
          decoration: const InputDecoration(
            hintText: 'Lorem ipsum dolor sit amet consectetur. Congue nec lectus eget fringilla urna viverra integer justo vitae. Tincidunt cum pellentesque ipsum mi. Posuere at diam lorem est pharetra. Ac suspendisse lorem vel vestibulum non volutpat faucibus',
            hintStyle: TextStyle(
    fontFamily: 'Montserrat',color: AppColors.hintText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.accentRed),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories This Project',
                  style: TextStyle(
    fontFamily: 'Montserrat',
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Show all categories
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.primaryText,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primaryText,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (feedProvider.isLoading && feedProvider.categories.isEmpty)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: feedProvider.categories.map((category) {
                  final intId = int.tryParse(category.id) ?? -1;
                  final isSelected = _selectedCategories.contains(intId);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (intId == -1) return;
                        if (isSelected) {
                          _selectedCategories.remove(intId);
                        } else {
                          _selectedCategories.add(intId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentRed : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.accentRed : AppColors.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
    fontFamily: 'Montserrat',
                          color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    print('🎥 _pickVideo called');
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        print('✅ Video selected: ${video.path}');
        print('📁 Video name: ${video.name}');
        
        if (kIsWeb) {
          // For web, read the file as bytes
          final Uint8List bytes = await video.readAsBytes();
          setState(() {
            _selectedVideoBytes = bytes;
            _selectedVideoName = video.name;
            _selectedVideo = null; // Not used on web
          });
          print('📁 Video bytes loaded: ${bytes.length} bytes');
        } else {
          // For mobile, use File
          setState(() {
            _selectedVideo = File(video.path);
            _selectedVideoBytes = null;
            _selectedVideoName = video.name;
          });
          print('📁 Video file created: ${_selectedVideo!.path}');
          print('📁 Video file exists: ${_selectedVideo!.existsSync()}');
        }
      } else {
        print('❌ No video selected');
      }
    } catch (e) {
      print('💥 Error picking video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking video: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickThumbnail() async {
    print('🖼️ _pickThumbnail called');
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('✅ Thumbnail selected: ${image.path}');
        print('📁 Thumbnail name: ${image.name}');
        
        if (kIsWeb) {
          // For web, read the file as bytes
          final Uint8List bytes = await image.readAsBytes();
          setState(() {
            _selectedThumbnailBytes = bytes;
            _selectedThumbnailName = image.name;
            _selectedThumbnail = null; // Not used on web
          });
          print('📁 Thumbnail bytes loaded: ${bytes.length} bytes');
        } else {
          // For mobile, use File
          setState(() {
            _selectedThumbnail = File(image.path);
            _selectedThumbnailBytes = null;
            _selectedThumbnailName = image.name;
          });
          print('📁 Thumbnail file created: ${_selectedThumbnail!.path}');
          print('📁 Thumbnail file exists: ${_selectedThumbnail!.existsSync()}');
        }
      } else {
        print('❌ No thumbnail selected');
      }
    } catch (e) {
      print('💥 Error picking thumbnail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    print('📝 AddFeedsScreen._handleSubmit called');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    print('✅ Form validation passed');

    if (kIsWeb) {
      if (_selectedVideoBytes == null) {
        print('❌ No video selected (web)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a video'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      print('✅ Video selected (web): ${_selectedVideoName}');
      
      if (_selectedThumbnailBytes == null) {
        print('❌ No thumbnail selected (web)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a thumbnail'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      print('✅ Thumbnail selected (web): ${_selectedThumbnailName}');
    } else {
      if (_selectedVideo == null) {
        print('❌ No video selected (mobile)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a video'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      print('✅ Video selected (mobile): ${_selectedVideo!.path}');
      
      if (_selectedThumbnail == null) {
        print('❌ No thumbnail selected (mobile)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a thumbnail'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      print('✅ Thumbnail selected (mobile): ${_selectedThumbnail!.path}');
    }

    if (_selectedCategories.isEmpty) {
      print('❌ No categories selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    print('✅ Categories selected: $_selectedCategories');

    print('📤 Calling FeedProvider.createFeed...');
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    
    final success = await feedProvider.createFeed(
      videoPath: kIsWeb ? null : _selectedVideo?.path,
      thumbnailPath: kIsWeb ? null : _selectedThumbnail?.path,
      videoBytes: kIsWeb ? _selectedVideoBytes : null,
      thumbnailBytes: kIsWeb ? _selectedThumbnailBytes : null,
      videoName: kIsWeb ? _selectedVideoName : null,
      thumbnailName: kIsWeb ? _selectedThumbnailName : null,
      description: _descriptionController.text.trim(),
      categories: _selectedCategories,
    );

    print('📥 FeedProvider.createFeed result: $success');

    if (success && mounted) {
      print('✅ Feed creation successful, showing success message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feed created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      print('❌ Feed creation failed: ${feedProvider.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedProvider.error ?? 'Failed to create feed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

