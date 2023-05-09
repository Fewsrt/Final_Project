
import 'package:alert/Screens/userlist/components/user_tabel_desktop.dart';
import 'package:alert/Screens/userlist/components/user_table_mobile.dart';
import 'package:flutter/material.dart';

import '../../controllers/responsive.dart';

class RoleUserScreen extends StatelessWidget {
  const RoleUserScreen({Key? key}) : super(key: key);
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
        desktop: UserDesktopScreen(),
        tablet: UserDesktopScreen(),
        mobile: UserMobileScreen()
      ),
    );
  }
}
