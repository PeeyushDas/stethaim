import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:stethaim/constants/app_constants.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool _isVerifying = false;
  String _enteredOtp = "";

  void _verifyOtp(String otp) {
    setState(() {
      _isVerifying = true;
      _enteredOtp = otp;
    });

    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isVerifying = false);

      // Example of handling verification result
      if (otp == "123456") {
        // Replace with actual verification logic
        _showSuccessDialog();
      } else {
        _showErrorDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Success",
              style: TextStyle(color: AppConstants.primaryColor),
            ),
            content: const Text("OTP verified successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to next screen
                },
                child: Text(
                  "Continue",
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: AppConstants.accent4Color),
            ),
            content: const Text("Invalid OTP. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  void _resendOtp() {
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("OTP resent successfully"),
        backgroundColor: AppConstants.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConstants.neutral1Color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We just sent you a SMS",
                style:
                    Theme.of(
                      context,
                    ).extension<AppTypography>()!.heading4SemiBold,
              ),
              SizedBox(height: SizeConfig.heightMultiplier * 2),
              Text(
                "Enter the verification code we sent to",
                style:
                    Theme.of(context).extension<AppTypography>()!.body1Medium,
              ),
              Text(
                "******${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}",
                style:
                    Theme.of(context).extension<AppTypography>()!.body1SemiBold,
              ),
              SizedBox(height: SizeConfig.heightMultiplier * 3),
              OtpTextField(
                numberOfFields: 6,
                borderColor: AppConstants.neutral5Color,
                focusedBorderColor: Colors.black,
                showFieldAsBox: true,
                borderWidth: 1.0,
                fieldWidth: SizeConfig.blockSizeHorizontal * 13,
                textStyle: TextStyle(
                  fontSize: SizeConfig.textMultiplier * 2.2,
                  fontWeight: FontWeight.bold,
                ),
                borderRadius: BorderRadius.circular(4),
                onCodeChanged: (String code) {
                  // Handle code changes if needed
                },
                onSubmit: _verifyOtp,
              ),
              SizedBox(height: SizeConfig.heightMultiplier * 3),
              SizedBox(
                width: double.infinity,
                height: SizeConfig.heightMultiplier * 6,
                child: ElevatedButton(
                  onPressed:
                      _isVerifying
                          ? null
                          : () {
                            if (_enteredOtp.length == 6) {
                              _verifyOtp(_enteredOtp);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child:
                      _isVerifying
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Done",
                            style: Theme.of(context)
                                .extension<AppTypography>()!
                                .body1SemiBoldWithColor(Colors.white),
                          ),
                ),
              ),
              SizedBox(height: SizeConfig.heightMultiplier * 2),
              Center(
                child: TextButton(
                  onPressed: _resendOtp,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Didn't receive a code? ",
                          style:
                              Theme.of(
                                context,
                              ).extension<AppTypography>()!.body1Medium,
                        ),
                        TextSpan(
                          text: "Resend",
                          style: Theme.of(
                            context,
                          ).extension<AppTypography>()!.body1SemiBoldWithColor(
                            AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
