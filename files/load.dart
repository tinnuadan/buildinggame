import 'package:objd/core.dart';
import '../files/scoreboards.dart';
import '../files/lobby.dart';
import 'utils.dart';
import 'game.dart';

class LoadFile extends Widget {
  LoadFile();
  @override
  Widget generate(Context context) {
    return For.of([
      InitScoreboards(),
      // clear tags
      For(from: 0, to:80, step: 10, create: (value){
        return Tag(GetRoundReadyTag(value), entity: Entity.All(), value: false);
      }),
      Tag("player", entity: Entity.All(), value: false),
      // other stuff
      VisibleScore(ScoreMgr.players),
      StartGameFn(),
      RoundTimer(),
    ]);
  }
}
