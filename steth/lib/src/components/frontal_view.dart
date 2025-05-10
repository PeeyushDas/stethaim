import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stethaim/utils/size_config.dart';

class StackedSvgImages extends StatelessWidget {
  final String upperImagePath;
  final double xCoordinate;
  final double yCoordinate;
  final String lowerImagePath; // Fixed lower image

  const StackedSvgImages({
    Key? key,
    required this.upperImagePath,
    required this.xCoordinate,
    required this.yCoordinate,
    required this.lowerImagePath, // Fixed lower image
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      width: double.infinity,
      height: SizeConfig.screenHeight * 0.6, // Adjust as needed
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Lower fixed image (base image)
          Image.asset(lowerImagePath, fit: BoxFit.contain),

          // Upper positioned image (indicator)
          Positioned(
            left: xCoordinate * SizeConfig.blockSizeHorizontal,
            top: yCoordinate * SizeConfig.blockSizeVertical,
            child: SvgPicture.asset(
              upperImagePath,
              height: SizeConfig.blockSizeHorizontal * 55, // Responsive size
              width: SizeConfig.blockSizeHorizontal * 5,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
