import 'package:objd/core.dart';

class Point {
  double x; double y; double z;
  Point(this.x, this.y, this.z);

  Point multiply(double factor) {
    return Point(x*factor, y*factor, z*factor);
  }
  Point add(Point p) {
    return Point(x+p.x, y+p.y, z+p.z);
  }
}

class Globals {
  static EntityType entityToRename = Entities.sheep;
  static String entityToRenameInitialName = "RenameMe";

  static final Location plotStart = Location.glob(x:-224, y:4, z:96);

  static final int maxPlayers = 15;

  static Storage storage = Storage("bgstorage", autoNamespace: true);

  static Location guiLocation = Location.glob(x: 8, y: 4, z:8);

  static Map<int,int> sheepColors = {
    1: 0, // white
    2: 10, // purple
    3: 10,
    4: 13, // green
    5: 13,
    6: 9, // cyan
    7: 9, 
    8: 0, // white
  };
}  

class Global_Offsets {

  static double playerX = 31/2;
  static Point _playerRenameBase = Point(32.0/2.0, 2, 12);
  static Point _playerObjectiveBase = Point(32.0/2.0, 2, 18);

  static Point wallStart = Point(11,3,15);//Point(1,3,47);
  static Point wallLength = Point(9,3,0);

  static List<Point> nbTping = [ Point(15,0,121), Point(16,0,121) ];

  static Map<int, Point> playerBases = Map<int, Point>();
  static Point playerMove = Point(0, 0, 32);
  static Point laneMove = Point(32, 0, 0);

  static Point anvil = Point(0, 0, 2);
  static Point entityToRename = Point(-1, 0, 2);

  static Point instruction = Point(0, 1, -2);
  static Point build = Point(-1, 1, -2);

  static Point tpCommon = Point(-2, 0, 0);

  static initBases() {
    Global_Offsets.playerBases.clear();

    for(int i=1; i<=8; i++) {
      final renameOff = playerMove.multiply((i.toDouble()-1.0)/2.0);
      final objectiveOff = playerMove.multiply((i.toDouble()-2.0)/2.0);
      if(i%2!=0)
      {
        playerBases[i] = _playerRenameBase.add(renameOff);
      }
      else
      {
        playerBases[i] = _playerObjectiveBase.add(objectiveOff);
      }
      print("Blayerbase[$i] ${playerBases[i].x} ${playerBases[i].y} ${playerBases[i].z}");
    }
  }
}