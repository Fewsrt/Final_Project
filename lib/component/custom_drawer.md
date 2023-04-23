import 'package:alert/Screens/your_directory/custom_drawer.dart';

// ...

class _CardDeviceState extends State<CardDevicePage> {
  // ...
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      drawer: CustomDrawer(), // Use the CustomDrawer widget here
      // ...
    );
  }
}
