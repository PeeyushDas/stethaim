import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:stethaim/constants/app_constants.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(
         onTap: onTap,
         onLongPress: onLongPress,
         enabled: enabled,
         leading: Container(
           width: 40,
           height: 40,
           decoration: BoxDecoration(
             shape: BoxShape.circle,
             color: AppConstants.primaryColor.withOpacity(0.1),
           ),
           child: Icon(
             Icons.bluetooth,
             color: AppConstants.primaryColor,
             size: 20,
           ),
         ),
         title: Text(
           device.name ?? "Unknown device",
           style: TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.w500,
             color: AppConstants.neutral1Color,
           ),
         ),
         subtitle: Text(
           device.address,
           style: TextStyle(fontSize: 14, color: AppConstants.neutral3Color),
         ),
         trailing: Row(
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
             if (rssi != null)
               Container(
                 margin: EdgeInsets.all(8.0),
                 child: DefaultTextStyle(
                   style: _computeTextStyle(rssi),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       Text(rssi.toString()),
                       Text('dBm', style: TextStyle(fontSize: 10)),
                     ],
                   ),
                 ),
               ),
             if (device.bondState == BluetoothBondState.bonded)
               Icon(Icons.link, color: AppConstants.accent3Color, size: 20)
             else
               Container(width: 0, height: 0),
             Icon(
               Icons.keyboard_arrow_right,
               color: AppConstants.neutral3Color,
               size: 20,
             ),
           ],
         ),
       );

  static TextStyle _computeTextStyle(int rssi) {
    if (rssi >= -35)
      return TextStyle(color: AppConstants.accent3Color, fontSize: 12);
    else if (rssi >= -45)
      return TextStyle(
        color: Color.lerp(
          AppConstants.accent3Color,
          Colors.lightGreen,
          -(rssi + 35) / 10,
        ),
        fontSize: 12,
      );
    else if (rssi >= -55)
      return TextStyle(
        color: Color.lerp(
          Colors.lightGreen,
          Colors.lime[600],
          -(rssi + 45) / 10,
        ),
        fontSize: 12,
      );
    else if (rssi >= -65)
      return TextStyle(
        color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10),
        fontSize: 12,
      );
    else if (rssi >= -75)
      return TextStyle(
        color: Color.lerp(
          Colors.amber,
          Colors.deepOrangeAccent,
          -(rssi + 65) / 10,
        ),
        fontSize: 12,
      );
    else if (rssi >= -85)
      return TextStyle(
        color: Color.lerp(
          Colors.deepOrangeAccent,
          AppConstants.accent4Color,
          -(rssi + 75) / 10,
        ),
        fontSize: 12,
      );
    else
      return TextStyle(color: AppConstants.accent4Color, fontSize: 12);
  }
}
