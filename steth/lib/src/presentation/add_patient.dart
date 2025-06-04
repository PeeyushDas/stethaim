import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/theme/app_theme.dart';
import 'dart:convert';
import 'package:stethaim/models/patient.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedGender = '';
  List<String> _selectedConditions = [];
  bool _isLoading = false;

  final List<String> _healthConditions = [
    'No Chronic Diseases',
    'Fever',
    '< 7 Days',
    '7 - 14 days',
    '> 14 Days',
    'Lethargy',
    'Irritability',
    'Poor feeding',
    'Vomiting',
    'Fast breathing',
    'Rash',
    'Seizure/Fit Sensorium',
    'Generalised body swelling',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.neutral1Color,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _savePatientData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender.isEmpty) {
      _showErrorSnackBar('Please select a gender');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final patient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dobController.text,
        gender: _selectedGender,
        weight:
            _weightController.text.trim().isEmpty
                ? null
                : _weightController.text.trim(),
        height:
            _heightController.text.trim().isEmpty
                ? null
                : _heightController.text.trim(),
        healthConditions: _selectedConditions,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Get existing patients
      final existingPatientsJson = prefs.getString('patients') ?? '[]';
      final List<dynamic> existingPatientsData = json.decode(
        existingPatientsJson,
      );

      // Convert to Patient objects
      final List<Patient> existingPatients =
          existingPatientsData.map((data) => Patient.fromJson(data)).toList();

      // Add new patient
      existingPatients.add(patient);

      // Convert back to JSON and save
      final patientsJson = existingPatients.map((p) => p.toJson()).toList();
      await prefs.setString('patients', json.encode(patientsJson));

      _showSuccessSnackBar('Patient added successfully!');
      _clearForm();

      Future.delayed(Duration(seconds: 0), () {
        context.go('/home'); // or wherever your patients list is
      });
    } catch (e) {
      _showErrorSnackBar('Failed to save patient data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _weightController.clear();
    _heightController.clear();
    setState(() {
      _selectedGender = '';
      _selectedConditions.clear();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context)
              .extension<AppTypography>()!
              .body1Medium
              .copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.accent3Color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context)
              .extension<AppTypography>()!
              .body1Medium
              .copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.accent4Color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.neutral1Color,
            size: 5 * SizeConfig.blockSizeHorizontal,
          ),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: Text(
          'Add a patient',
          style: Theme.of(context).extension<AppTypography>()!.heading5SemiBold,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4 * SizeConfig.blockSizeHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description text
                Text(
                  'By filling this form you provide the doctor with important information',
                  style: Theme.of(context)
                      .extension<AppTypography>()!
                      .body2MediumWithColor(AppTheme.neutral3Color),
                ),
                SizedBox(height: 2 * SizeConfig.blockSizeVertical),

                // Gender section
                Text(
                  'Gender*',
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.body1SemiBold,
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                Row(
                  children: [
                    _buildGenderOption('Male'),
                    SizedBox(width: 5 * SizeConfig.blockSizeHorizontal),
                    _buildGenderOption('Female'),
                    SizedBox(width: 5 * SizeConfig.blockSizeHorizontal),
                    _buildGenderOption('Others'),
                  ],
                ),
                SizedBox(height: 3 * SizeConfig.blockSizeVertical),

                // Name section
                Text(
                  'Name*',
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.body1SemiBold,
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                _buildTextField(
                  controller: _firstNameController,
                  hintText: 'First',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                _buildTextField(
                  controller: _middleNameController,
                  hintText: 'Middle (optional)',
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                _buildTextField(
                  controller: _lastNameController,
                  hintText: 'Last',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3 * SizeConfig.blockSizeVertical),

                // Date of birth
                Text(
                  'Date of birth*',
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.body1SemiBold,
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  style:
                      Theme.of(context).extension<AppTypography>()!.body1Medium,
                  decoration: InputDecoration(
                    hintText: 'DOB',
                    hintStyle: Theme.of(context)
                        .extension<AppTypography>()!
                        .body1MediumWithColor(AppTheme.neutral4Color),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        1 * SizeConfig.blockSizeHorizontal,
                      ),
                      borderSide: BorderSide(color: AppTheme.neutral5Color),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        1 * SizeConfig.blockSizeHorizontal,
                      ),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: AppTheme.neutral3Color,
                      size: 5 * SizeConfig.blockSizeHorizontal,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3 * SizeConfig.blockSizeHorizontal,
                      vertical: 2 * SizeConfig.blockSizeVertical,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Date of birth is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3 * SizeConfig.blockSizeVertical),

                // Weight
                Text(
                  'Weight',
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.body1SemiBold,
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style:
                      Theme.of(context).extension<AppTypography>()!.body1Medium,
                  decoration: InputDecoration(
                    hintText: 'Body Weight',
                    hintStyle: Theme.of(context)
                        .extension<AppTypography>()!
                        .body1MediumWithColor(AppTheme.neutral4Color),
                    suffixText: 'kg',
                    suffixStyle: Theme.of(context)
                        .extension<AppTypography>()!
                        .body1MediumWithColor(AppTheme.neutral3Color),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        1 * SizeConfig.blockSizeHorizontal,
                      ),
                      borderSide: BorderSide(color: AppTheme.neutral5Color),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        1 * SizeConfig.blockSizeHorizontal,
                      ),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3 * SizeConfig.blockSizeHorizontal,
                      vertical: 2 * SizeConfig.blockSizeVertical,
                    ),
                  ),
                ),
                SizedBox(height: 3 * SizeConfig.blockSizeVertical),

                // Height
                Text(
                  'Height',
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.body1SemiBold,
                ),
                SizedBox(height: 1.5 * SizeConfig.blockSizeVertical),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  style:
                      Theme.of(context).extension<AppTypography>()!.body1Medium,
                  decoration: InputDecoration(
                    hintText: 'Height',
                    hintStyle: Theme.of(context)
                        .extension<AppTypography>()!
                        .body1MediumWithColor(AppTheme.neutral4Color),
                    suffixText: 'cm',
                    suffixStyle: Theme.of(context)
                        .extension<AppTypography>()!
                        .body1MediumWithColor(AppTheme.neutral3Color),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        1 * SizeConfig.blockSizeHorizontal,
                      ),
                      borderSide: BorderSide(color: AppTheme.neutral5Color),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        1 * SizeConfig.blockSizeHorizontal,
                      ),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3 * SizeConfig.blockSizeHorizontal,
                      vertical: 2 * SizeConfig.blockSizeVertical,
                    ),
                  ),
                ),
                SizedBox(height: 3 * SizeConfig.blockSizeVertical),

                // Health conditions
                Text(
                  'Tell us about patient health condition.',
                  style:
                      Theme.of(
                        context,
                      ).extension<AppTypography>()!.body1SemiBold,
                ),
                SizedBox(height: 2 * SizeConfig.blockSizeVertical),

                // Health conditions checkboxes
                ...List.generate(_healthConditions.length, (index) {
                  final condition = _healthConditions[index];
                  return CheckboxListTile(
                    title: Text(
                      condition,
                      style:
                          Theme.of(
                            context,
                          ).extension<AppTypography>()!.body2Medium,
                    ),
                    value: _selectedConditions.contains(condition),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedConditions.add(condition);
                        } else {
                          _selectedConditions.remove(condition);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppTheme.primaryColor,
                  );
                }),

                SizedBox(height: 4 * SizeConfig.blockSizeVertical),

                // Add Patient button
                SizedBox(
                  width: double.infinity,
                  height: 6 * SizeConfig.blockSizeVertical,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePatientData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: AppTheme.neutral4Color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          1 * SizeConfig.blockSizeHorizontal,
                        ),
                      ),
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 0.5 * SizeConfig.blockSizeHorizontal,
                            )
                            : Text(
                              'Add Patient',
                              style: Theme.of(context)
                                  .extension<AppTypography>()!
                                  .body1SemiBoldWithColor(Colors.white),
                            ),
                  ),
                ),
                SizedBox(height: 2.5 * SizeConfig.blockSizeVertical),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: _selectedGender,
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            Text(
              gender,
              style: Theme.of(context).extension<AppTypography>()!.body2Medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).extension<AppTypography>()!.body1Medium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context)
            .extension<AppTypography>()!
            .body1MediumWithColor(AppTheme.neutral4Color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            1 * SizeConfig.blockSizeHorizontal,
          ),
          borderSide: BorderSide(color: AppTheme.neutral5Color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            1 * SizeConfig.blockSizeHorizontal,
          ),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            2 * SizeConfig.blockSizeHorizontal,
          ),
          borderSide: BorderSide(color: AppTheme.accent4Color),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 3 * SizeConfig.blockSizeHorizontal,
          vertical: 2 * SizeConfig.blockSizeVertical,
        ),
      ),
      validator: validator,
    );
  }
}
