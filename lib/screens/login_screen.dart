import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+91');
  
  @override
  void dispose() {
    _phoneController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title
              const Text(
                'Enter Your\nMobile Number',
                style: TextStyle(
    fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              const Text(
                'Lorem ipsum dolor sit amet consectetur. Porta at id hac vitae. Et tortor at vehicula euismod mi viverra.',
                style: TextStyle(
    fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              // Phone number form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Country code field
                        Container(
                          width: 80,
                          child: TextFormField(
                            controller: _countryCodeController,
                            style: const TextStyle(
    fontFamily: 'Montserrat',color: AppColors.primaryText),
                            decoration: InputDecoration(
                              hintText: '+91',
                              hintStyle: const TextStyle(
    fontFamily: 'Montserrat',color: AppColors.hintText),
                              suffixIcon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.primaryText,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.accentRed),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              // TODO: Show country code picker
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Phone number field
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
    fontFamily: 'Montserrat',color: AppColors.primaryText),
                            decoration: const InputDecoration(
                              hintText: 'Enter Mobile Number',
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
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return TextButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: AppColors.primaryText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primaryButtonBorder),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Continue',
                                  style: TextStyle(
    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.primaryText,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Error message
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.error != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: const TextStyle(
    fontFamily: 'Montserrat',
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.verifyOtp(
        countryCode: _countryCodeController.text,
        phone: _phoneController.text,
      );

      if (success && mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }
}

