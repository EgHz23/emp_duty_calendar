import 'package:sensors_plus/sensors_plus.dart';

class TiltDetector {
  // Variables to store the accelerometer values
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;

  // Method to listen to accelerometer events and check for landscape orientation
  Stream<bool> get landscapeStream async* {
    await for (var event in accelerometerEvents) {
      _x = event.x;
      _y = event.y;
      _z = event.z;

      // Check if the phone is in landscape orientation (landscape if either x or y is large)
      if (_isInLandscape()) {
        yield true; // Yielding true when the phone is in landscape mode
      } else {
        yield false; // Yielding false when the phone is not in landscape
      }
    }
  }

  // Function to check if the phone is in landscape orientation
  bool _isInLandscape() {
    // In landscape mode, either x or y axis should be large, and z should be near 0 (flat)
    return (_x.abs() > _y.abs()) && _z.abs() < 2.0;
  }
}
