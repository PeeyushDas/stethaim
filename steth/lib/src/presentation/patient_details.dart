import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stethaim/models/patient.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/theme/app_theme.dart';
import 'dart:convert';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final Patient? patient;

  const PatientDetailsScreen({Key? key, required this.patientId, this.patient})
    : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _patient = widget.patient;
      _isLoading = false;
    } else {
      _loadPatient();
    }
  }

  Future<void> _loadPatient() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientsJson = prefs.getString('patients') ?? '[]';
      final List<dynamic> patientsData = json.decode(patientsJson);

      final patientData = patientsData.firstWhere(
        (data) => data['id'] == widget.patientId,
        orElse: () => null,
      );

      if (patientData != null) {
        setState(() {
          _patient = Patient.fromJson(patientData);
          _isLoading = false;
        });
      } else {
        // Patient not found, go back
        context.go('/home');
      }
    } catch (e) {
      context.go('/home');
    }
  }

  void _editPatient() {
    // Navigate to edit patient screen (you'll need to implement this)
    context.go('/add_patient', extra: _patient);
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.contains('/')) {
        return dateString;
      }
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.neutral1Color,
              size: 6 * SizeConfig.blockSizeHorizontal,
            ),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_patient == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppTheme.neutral1Color,
              size: 6 * SizeConfig.blockSizeHorizontal,
            ),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const Center(child: Text('Patient not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.neutral1Color,
            size: 6 * SizeConfig.blockSizeHorizontal,
          ),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: _editPatient,
            child: Text(
              'Edit',
              style: Theme.of(context)
                  .extension<AppTypography>()!
                  .body1SemiBoldWithColor(AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4 * SizeConfig.blockSizeHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Name
              Text(
                'Hello,',
                style:
                    Theme.of(context).extension<AppTypography>()!.body1Medium,
              ),
              SizedBox(height: 0.5 * SizeConfig.blockSizeVertical),
              Text(
                _patient!.fullName,
                style:
                    Theme.of(
                      context,
                    ).extension<AppTypography>()!.heading3SemiBold,
              ),

              SizedBox(height: 4 * SizeConfig.blockSizeVertical),

              // Connect Button
              SizedBox(
                width: double.infinity,
                height: 6 * SizeConfig.blockSizeVertical,
                child: ElevatedButton(
                  onPressed:
                      () =>
                          context.go('/scan/${_patient!.id}', extra: _patient),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: AppTheme.primaryColor.withOpacity(
                      0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        2 * SizeConfig.blockSizeHorizontal,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth,
                        color: Colors.white,
                        size: 5 * SizeConfig.blockSizeHorizontal,
                      ),
                      SizedBox(width: 2 * SizeConfig.blockSizeHorizontal),
                      Text(
                        'Connect',
                        style: Theme.of(context)
                            .extension<AppTypography>()!
                            .body1SemiBoldWithColor(Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4 * SizeConfig.blockSizeVertical),

              // Patient Details Section
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    // Section Header with Lines
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.neutral5Color,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4 * SizeConfig.blockSizeHorizontal,
                          ),
                          child: Text(
                            'Patient Details',
                            style: Theme.of(context)
                                .extension<AppTypography>()!
                                .body1SemiBoldWithColor(AppTheme.neutral2Color),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppTheme.neutral5Color,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4 * SizeConfig.blockSizeVertical),

                    // Patient Details List
                    Column(
                      children: [
                        _buildDetailItem(
                          'Date of birth',
                          _formatDate(_patient!.dateOfBirth),
                        ),
                        if (_patient!.weight != null &&
                            _patient!.weight!.isNotEmpty)
                          _buildDetailItem('Weight', '${_patient!.weight} kg'),
                        if (_patient!.height != null &&
                            _patient!.height!.isNotEmpty)
                          _buildDetailItem('Height', '${_patient!.height} cm'),
                        _buildDetailItem(
                          'Diseases',
                          _patient!.healthConditions.isEmpty
                              ? 'No Chronic Diseases'
                              : _patient!.healthConditions.join(', '),
                          isLast: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isLast = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 0.5 * SizeConfig.blockSizeVertical,
      ),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(color: AppTheme.neutral5Color, width: 1),
                ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 0.5 * SizeConfig.blockSizeVertical),

          Text(
            label,
            style: Theme.of(context)
                .extension<AppTypography>()!
                .body2SemiBoldWithColor(AppTheme.primaryColor),
          ),
          Text(
            value,
            style: Theme.of(context).extension<AppTypography>()!.body1Medium,
          ),
        ],
      ),
    );
  }
}
