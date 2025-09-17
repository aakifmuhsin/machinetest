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
  bool _isSubmitting = false;

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
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: TextButton.styleFrom(
                backgroundColor: _isSubmitting ? Colors.grey : Colors.black,
                foregroundColor: AppColors.primaryText,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: const StadiumBorder(side: BorderSide(
          color: AppColors.accentRed, // 👈 your red border
          width: 1.5, // optional: adjust thickness
        ),),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
                      ),
                    )
                  : const Text(
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
            child: (_selectedVideo != null || _selectedVideoBytes != null)
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
                        kIsWeb ? (_selectedVideoName ?? 'Unknown') : _selectedVideo!.path.split(RegExp(r'[\\/]')).last,
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
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedVideo = null;
                            _selectedVideoBytes = null;
                            _selectedVideoName = null;
                          });
                        },
                        child: const Text('Remove', style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.accentRed,
                        )),
                      )
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
            child: (_selectedThumbnail != null || _selectedThumbnailBytes != null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!kIsWeb && _selectedThumbnail != null)
                        const Icon(Icons.image, color: AppColors.primaryText)
                      else
                        SvgPicture.asset(
                          'assests/images/image_outlined.svg',
                          width: 35,
                          height: 25,
                          colorFilter: const ColorFilter.mode(AppColors.primaryText, BlendMode.srcIn),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        kIsWeb ? (_selectedThumbnailName ?? 'Unknown') : _selectedThumbnail!.path.split(RegExp(r'[\\/]')).last,
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
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedThumbnail = null;
                            _selectedThumbnailBytes = null;
                            _selectedThumbnailName = null;
                          });
                        },
                        child: const Text('Remove', style: TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.accentRed,
                        )),
                      )
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
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        
        if (kIsWeb) {
          // For web, read the file as bytes
          final Uint8List bytes = await video.readAsBytes();
          setState(() {
            _selectedVideoBytes = bytes;
            _selectedVideoName = video.name;
            _selectedVideo = null; // Not used on web
          });
        } else {
          // For mobile, use File
          setState(() {
            _selectedVideo = File(video.path);
            _selectedVideoBytes = null;
            _selectedVideoName = video.name;
          });
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
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );
      if (image != null) {
        // Validate extension (server does not accept SVG)
        final String lowerName = image.name.toLowerCase();
        const allowedExts = [
          '.bmp', '.dib', '.gif', '.jfif', '.jpe', '.jpg', '.jpeg', '.png', '.apng',
          '.tif', '.tiff', '.webp', '.ico'
        ];
        final bool isAllowed = allowedExts.any((ext) => lowerName.endsWith(ext));
        if (!isAllowed) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unsupported thumbnail type. Please select JPG/PNG image.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        
        if (kIsWeb) {
          // For web, read the file as bytes
          final Uint8List bytes = await image.readAsBytes();
          setState(() {
            _selectedThumbnailBytes = bytes;
            _selectedThumbnailName = image.name;
            _selectedThumbnail = null; // Not used on web
          });
        } else {
          // For mobile, use File
          setState(() {
            _selectedThumbnail = File(image.path);
            _selectedThumbnailBytes = null;
            _selectedThumbnailName = image.name;
          });
        }
      } else {
        print('❌ No thumbnail selected');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    
    if (_isSubmitting) return; // Prevent multiple submissions
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (kIsWeb) {
        if (_selectedVideoBytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a video'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        if (_selectedThumbnailBytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a thumbnail'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      } else {
        if (_selectedVideo == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a video'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        
        if (_selectedThumbnail == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a thumbnail'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one category'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
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

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feed created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedProvider.error ?? 'Failed to create feed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

