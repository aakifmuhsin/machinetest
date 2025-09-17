# Section App - Flutter Video Feed Application

A Flutter application that implements a video feed platform with user authentication, video playback, and content creation features.

## Features

### 1. Login Screen
- Phone number input with country code selection
- OTP verification using the `otp_verified` API
- Dark theme UI matching the Figma design
- Form validation and error handling

### 2. Home Screen
- Video feed with category filtering
- Custom video player with controls
- User profile information
- Category tabs (Explore, Trending, All Categories, etc.)
- Floating action button for adding new feeds

### 3. Add Feeds Screen
- Video upload from gallery
- Thumbnail image selection
- Description input with validation
- Multi-category selection
- Form validation and error handling

## Architecture

The app follows clean architecture principles with:

- **Models**: Data classes for API responses (User, Feed, Category, ApiResponse)
- **Services**: API service for network calls
- **Providers**: State management using Provider pattern
- **Screens**: UI screens for different app sections
- **Widgets**: Reusable UI components
- **Constants**: App colors and theme configuration

## Dependencies

- `provider`: State management
- `http`: HTTP requests
- `video_player`: Video playback
- `image_picker`: Image and video selection
- `shared_preferences`: Local storage for authentication token
- `cached_network_image`: Image caching
- `permission_handler`: Permission handling

## API Integration

### Endpoints Used:
1. **POST /otp_verified** - Phone number verification
2. **GET /category_list** - Fetch categories
3. **GET /home** - Fetch home feed
4. **POST /my_feed** - Create new feed

### API Configuration:
Update the `baseUrl` in `lib/services/api_service.dart` with your actual API endpoint.

## Setup Instructions

1. **Install Flutter**: Make sure Flutter is installed and added to your PATH
2. **Install Dependencies**: Run `flutter pub get`
3. **Update API URL**: Replace the placeholder URL in `api_service.dart`
4. **Run the App**: Use `flutter run` for development
5. **Build APK**: Use `flutter build apk --release` for production

## Project Structure

```
lib/
├── constants/
│   ├── app_colors.dart
│   └── app_theme.dart
├── models/
│   ├── api_response.dart
│   ├── category.dart
│   ├── feed.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart
│   └── feed_provider.dart
├── screens/
│   ├── add_feeds_screen.dart
│   ├── home_screen.dart
│   └── login_screen.dart
├── services/
│   └── api_service.dart
├── widgets/
│   ├── feed_item.dart
│   └── video_player_widget.dart
└── main.dart
```

## UI Design

The app implements a dark theme matching the provided Figma designs with:
- Dark background colors
- White text for primary content
- Red accent color for interactive elements
- Clean, minimal design
- Responsive layout

## Features Implemented

✅ Login screen with phone number input
✅ OTP verification integration
✅ Home screen with video feed
✅ Category filtering
✅ Custom video player
✅ Add feeds screen
✅ Video and image upload
✅ Category selection
✅ Form validation
✅ Error handling
✅ Dark theme UI
✅ State management with Provider
✅ Clean architecture

## Next Steps

1. Update the API base URL in `api_service.dart`
2. Test the app with actual API endpoints
3. Build and deploy the APK
4. Set up Git repository for version control

## Building APK

To build the APK for distribution:

```bash
flutter build apk --release
```

The APK will be generated in `build/app/outputs/flutter-apk/app-release.apk`

## Screenshots

The app includes three main screens:
1. **Login Screen**: Phone number input with country code selection
2. **Home Screen**: Video feed with category tabs and user profile
3. **Add Feeds Screen**: Content creation with video/image upload and category selection

All screens follow the dark theme design from the provided Figma mockups.