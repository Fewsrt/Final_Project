import 'package:alert/Screens/history/components/history_tabel_desktop.dart';
import 'package:flutter/material.dart';

import '../../controllers/responsive.dart';

class HistoryDeviceScreen extends StatelessWidget {
  const HistoryDeviceScreen({Key? key}) : super(key: key);
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
        desktop: HistoryPage(),
        tablet: HistoryPage(),
        mobile: HistoryPage(),
      ),
    );
  }
}
