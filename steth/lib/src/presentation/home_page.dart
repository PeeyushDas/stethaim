import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stethaim/models/patient.dart';
import 'package:stethaim/src/components/no_patient.dart';
import 'package:stethaim/theme/text_theme.dart';
import 'package:stethaim/utils/size_config.dart';
import 'package:stethaim/theme/app_theme.dart';
import 'dart:convert';

class AllPatientsScreen extends StatefulWidget {
  const AllPatientsScreen({Key? key}) : super(key: key);

  @override
  State<AllPatientsScreen> createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  List<Patient> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientsJson = prefs.getString('patients') ?? '[]';
      final List<dynamic> patientsData = json.decode(patientsJson);

      setState(() {
        _patients =
            patientsData
                .map((data) => Patient.fromJson(data))
                .toList()
                .reversed // Show newest first
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load patients: $e');
    }
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

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day} ${_getMonthName(date.month)} ${date.year}";
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Clear All Patients',
              style:
                  Theme.of(
                    context,
                  ).extension<AppTypography>()!.heading5SemiBold,
            ),
            content: Text(
              'Are you sure you want to delete all patient data? This action cannot be undone.',
              style: Theme.of(context).extension<AppTypography>()!.body1Medium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: Theme.of(context)
                      .extension<AppTypography>()!
                      .body1SemiBoldWithColor(AppTheme.neutral3Color),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearAllPatients();
                },
                child: Text(
                  'Clear All',
                  style: Theme.of(context)
                      .extension<AppTypography>()!
                      .body1SemiBoldWithColor(AppTheme.accent4Color),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _clearAllPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('patients', '[]'); // Set to empty array

      setState(() {
        _patients.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All patients cleared successfully',
            style: Theme.of(context)
                .extension<AppTypography>()!
                .body1Medium
                .copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.accent3Color,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to clear patients: $e');
    }
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
            Icons.settings,
            color: AppTheme.neutral1Color,
            size: 6 * SizeConfig.blockSizeHorizontal,
          ),
          onPressed: () {
            // Settings functionality
          },
        ),
        title: SvgPicture.asset(
          'assets/Stethaim.svg',
          height: 6 * SizeConfig.blockSizeVertical,
          width: 20 * SizeConfig.blockSizeHorizontal,
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearConfirmationDialog();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever,
                          color: AppTheme.accent4Color,
                        ),
                        SizedBox(width: 2 * SizeConfig.blockSizeHorizontal),
                        Text(
                          'Clear All Patients',
                          style:
                              Theme.of(
                                context,
                              ).extension<AppTypography>()!.body2Medium,
                        ),
                      ],
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: AppTheme.neutral1Color,
              size: 6 * SizeConfig.blockSizeHorizontal,
            ),
            onPressed: () {
              // Navigate to Add Patient screen
              context.go('/add_patient');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Success message if coming from add patient
            if (ModalRoute.of(context)?.settings.arguments == 'patient_added')
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3 * SizeConfig.blockSizeHorizontal),
                margin: EdgeInsets.all(4 * SizeConfig.blockSizeHorizontal),
                decoration: BoxDecoration(
                  color: AppTheme.accent3Color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    2 * SizeConfig.blockSizeHorizontal,
                  ),
                  border: Border.all(color: AppTheme.accent3Color),
                ),
                child: Text(
                  'Patient Added',
                  style: Theme.of(context)
                      .extension<AppTypography>()!
                      .body1SemiBoldWithColor(AppTheme.accent3Color),
                  textAlign: TextAlign.center,
                ),
              ),

            // All Patients header
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 4 * SizeConfig.blockSizeHorizontal,
                vertical: 2 * SizeConfig.blockSizeVertical,
              ),
            ),

            // Patients list - Fixed layout constraint issue
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                          strokeWidth: 0.8 * SizeConfig.blockSizeHorizontal,
                        ),
                      )
                      : _patients.isEmpty
                      ? buildEmptyState(context)
                      : Column(
                        children: [
                          // Header with lines
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4 * SizeConfig.blockSizeHorizontal,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppTheme.neutral5Color,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        4 * SizeConfig.blockSizeHorizontal,
                                  ),
                                  child: Text(
                                    'All Patients',
                                    style: Theme.of(context)
                                        .extension<AppTypography>()!
                                        .body1SemiBoldWithColor(
                                          AppTheme.neutral2Color,
                                        ),
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
                          ),

                          SizedBox(height: 2 * SizeConfig.blockSizeVertical),

                          // Patient list
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4 * SizeConfig.blockSizeHorizontal,
                              ),
                              itemCount: _patients.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    color: AppTheme.neutral5Color,
                                    thickness: 1,
                                    height: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final patient = _patients[index];
                                return _buildPatientTile(patient);
                              },
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientTile(Patient patient) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4 * SizeConfig.blockSizeHorizontal,
        vertical: 0 * SizeConfig.blockSizeVertical,
      ),
      title: Text(
        patient.fullName,
        style: Theme.of(context).extension<AppTypography>()!.body1SemiBold,
      ),
      subtitle: Text(
        _formatDate(patient.createdAt),
        style: Theme.of(context)
            .extension<AppTypography>()!
            .body2MediumWithColor(AppTheme.neutral3Color),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: AppTheme.neutral3Color,
        size: 6 * SizeConfig.blockSizeHorizontal,
      ),
      onTap: () {
        // Navigate to patient details screen with patient ID and object
        context.go('/patient_details/${patient.id}', extra: patient);
      },
    );
  }
}
