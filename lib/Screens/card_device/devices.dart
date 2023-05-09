import 'package:alert/Screens/card_device/components/card_device.dart';
import 'package:alert/Screens/card_device/components/list_devices.dart';
import 'package:flutter/material.dart';

import '../../controllers/responsive.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: const Responsive(
        desktop: ListDevicePage(),
        tablet: ListDevicePage(),
        mobile: CardDevicePage()
      ),
    );
  }
}
