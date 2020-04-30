// import the core of the framework:
import 'package:objd/core.dart';
// import the custom pack:
import './packs/buildingGamePack.dart';

void main(List<String> args) {
  createProject(
    Project(
      name: 'theBuildingGame',
      target: '../',
      generate: BuildingGamePack(),
    ),
    args,
  );
}
