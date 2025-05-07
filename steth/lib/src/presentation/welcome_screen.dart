import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:stethaim/src/presentation/otp_screen.dart';
import 'package:stethaim/theme/text_theme.dart';
import '../../constants/app_constants.dart';
import '../../utils/size_config.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = '';
  bool _isPhoneValid = false;

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppConstants.neutral1Color,
            size: 5 * SizeConfig.blockSizeHorizontal,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Implement help functionality
            },
            child: Text(
              'Help',
              style: Theme.of(context)
                  .extension<AppTypography>()!
                  .body1SemiBoldWithColor(AppConstants.primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding + 4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(
                'Welcome to ${AppConstants.appName}!',
                style:
                    Theme.of(
                      context,
                    ).extension<AppTypography>()!.heading4SemiBold,
              ),
              SizedBox(height: 2 * SizeConfig.blockSizeVertical),

              // Description
              Text(
                'Enter your mobile number.',
                style:
                    Theme.of(context).extension<AppTypography>()!.body1Medium,
              ),
              Text(
                'We will send a verification code to you.',
                style:
                    Theme.of(context).extension<AppTypography>()!.body1Medium,
              ),
              SizedBox(height: 3 * SizeConfig.blockSizeVertical),

              // Phone Number Label
              Text(
                'Phone Number',
                style:
                    Theme.of(context).extension<AppTypography>()!.body1SemiBold,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical),

              // IntlPhoneField for phone input
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: 'Enter Your Number',
                  hintStyle: TextStyle(
                    color: AppConstants.neutral4Color,
                    fontSize: 1.8 * SizeConfig.textMultiplier,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppConstants.neutral5Color),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppConstants.primaryColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2 * SizeConfig.blockSizeHorizontal,
                    vertical: 1.8 * SizeConfig.blockSizeVertical,
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  // Check if number has exactly 10 digits (for India)
                  setState(() {
                    phoneNumber = phone.completeNumber;
                    _isPhoneValid = phone.number.length == 10;
                  });
                },
                style: TextStyle(
                  fontSize: 2 * SizeConfig.textMultiplier,
                  color: AppConstants.neutral1Color,
                ),
                dropdownTextStyle: TextStyle(
                  fontSize: 1.8 * SizeConfig.textMultiplier,
                  color: AppConstants.neutral1Color,
                ),
                flagsButtonMargin: EdgeInsets.only(
                  left: 1.5 * SizeConfig.blockSizeHorizontal,
                ),
                dropdownIconPosition: IconPosition.trailing,
                showDropdownIcon: true,
                dropdownIcon: Icon(
                  Icons.arrow_drop_down,
                  color: AppConstants.neutral3Color,
                ),
              ),

              SizedBox(height: 3 * SizeConfig.blockSizeVertical),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 6 * SizeConfig.blockSizeVertical,
                child: ElevatedButton(
                  onPressed:
                      _isPhoneValid
                          ? () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OtpVerificationScreen(
                                        phoneNumber: phoneNumber,
                                      ),
                                ),
                              );
                            }
                          }
                          : null, // Button is disabled when phone is invalid
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPhoneValid
                            ? AppConstants.primaryColor
                            : AppConstants.neutral4Color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppConstants.neutral4Color,
                    disabledForegroundColor: Colors.white,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 2 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2 * SizeConfig.blockSizeVertical),

              // Terms and Privacy
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 1.6 * SizeConfig.textMultiplier,
                    color: AppConstants.neutral2Color,
                  ),
                  children: [
                    const TextSpan(text: 'By clicking, I accept the '),
                    TextSpan(
                      text: 'terms of service',
                      style: TextStyle(
                        color: AppConstants.neutral1Color,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'privacy policy.',
                      style: TextStyle(
                        color: AppConstants.neutral1Color,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
