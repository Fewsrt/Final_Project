    // refsensor.child('Direction').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _direction = int.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Temp_real').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _temperature = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Humidity').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _humidity = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Utra').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _ultrasonicleft = int.parse(event.snapshot.value.toString());
    //     ultrasonicleftvalue = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('Utra2').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _ultrasonicright = int.parse(event.snapshot.value.toString());
    //     ultrasonicrightvalue = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('rain_real').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _rain = double.parse(event.snapshot.value.toString());
    //   });
    // });
    // refsensor.child('wind_real').onValue.listen((DatabaseEvent event) {
    //   setState(() {
    //     _windspeed = double.parse(event.snapshot.value.toString());
    //   });
    // });


                // const SizedBox(height: 16.0),
            // const Text(
            //   'Sensor Value:',
            //   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 16.0),
            // Text('Direction: $_direction'),
            // Text('Temperature: $_temperature'),
            // Text('Humidity: $_humidity'),
            // Text('Ultrasonic Left: $_ultrasonicleft'),
            // Text('Ultrasonic Right: $_ultrasonicright'),
            // Text('Rain: $_rain'),
            // Text('Wind Speed: $_windspeed'),
            // Row(
            //   children: [
            //     Expanded(
            //         child: SfRadialGauge(axes: <RadialAxis>[
            //       RadialAxis(minimum: 0, maximum: 20, ranges: <GaugeRange>[
            //         GaugeRange(startValue: 0, endValue: 5, color: Colors.green),
            //         GaugeRange(
            //             startValue: 5, endValue: 12, color: Colors.orange),
            //         GaugeRange(startValue: 12, endValue: 20, color: Colors.red)
            //       ], pointers: <GaugePointer>[
            //         NeedlePointer(
            //           value: ultrasonicleftvalue,
            //           enableAnimation: true,
            //         )
            //       ], annotations: <GaugeAnnotation>[
            //         GaugeAnnotation(
            //             widget: Text('$_ultrasonicleft cm',
            //                 style: const TextStyle(
            //                     fontSize: 14, fontWeight: FontWeight.bold)),
            //             angle: 90,
            //             positionFactor: 0.5)
            //       ])
            //     ])),
            //     Expanded(
            //         child: SfRadialGauge(axes: <RadialAxis>[
            //       RadialAxis(minimum: 0, maximum: 20, ranges: <GaugeRange>[
            //         GaugeRange(startValue: 0, endValue: 5, color: Colors.green),
            //         GaugeRange(
            //             startValue: 5, endValue: 12, color: Colors.orange),
            //         GaugeRange(startValue: 12, endValue: 20, color: Colors.red)
            //       ], pointers: <GaugePointer>[
            //         NeedlePointer(
            //           value: ultrasonicrightvalue,
            //           enableAnimation: true,
            //         )
            //       ], annotations: <GaugeAnnotation>[
            //         GaugeAnnotation(
            //             widget: Text('$_ultrasonicright cm',
            //                 style: const TextStyle(
            //                     fontSize: 14, fontWeight: FontWeight.bold)),
            //             angle: 90,
            //             positionFactor: 0.5)
            //       ])
            //     ]))
            //   ],
            // )

  // var _direction = 0;
  // double _humidity = 0;
  // double _temperature = 0;
  // int _ultrasonicleft = 0;
  // var _ultrasonicright = 0;
  // double ultrasonicleftvalue = 0;
  // double ultrasonicrightvalue = 0;
  // double _rain = 0;
  // double _windspeed = 0;