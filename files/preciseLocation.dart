import 'package:objd/core.dart';

class PreciseLocation extends Location {

  bool xPrecise = false;
  bool yPrecise = false;
  bool zPrecise = false;

  PreciseLocation.glob({double x = 0, double y = 0, double z = 0}) : super.glob(x: x, y: y, z: z);

  /// The Location class provides a wrapper for relative(~ ~ ~) coordinates:
  PreciseLocation.rel({double x = 0, double y = 0, double z = 0}) : super.rel(x: x, y: y, z: z);

  /// The Location class provides a wrapper for local(^ ^ ^) coordinates:
  PreciseLocation.local({double x = 0, double y = 0, double z = 0}) : super.local(x: x, y: y, z: z);

  @override
  String toString() {
    var xyz = location.trim().split(' ');
    if(!xPrecise) { xyz[0] = xyz[0].replaceAll('.0', ''); }
    if(!yPrecise) { xyz[1] = xyz[1].replaceAll('.0', ''); }
    if(!zPrecise) { xyz[2] = xyz[2].replaceAll('.0', ''); }
    return xyz.join(' ').trim();
  }
}