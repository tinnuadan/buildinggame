import 'package:objd/core.dart';
// import all the files:
import 'package:objd_gui/gui.dart';
import '../files/load.dart';
import '../files/main.dart';
import '../files/game.dart';
import '../files/gamechecker.dart';
import '../files/lobby.dart';
import '../files/scoreboards.dart';
import '../files/globals.dart';


class BuildingGamePack extends Widget {

  BuildingGamePack() {
    Global_Offsets.initBases();
  }

  @override
  Widget generate(Context context) {
    return Pack(
      name: 'buildinggame', // name of the subpack
      modules: [
        SwitchToNextRoundChecker(11, [GameStateRename(11, objective: "Think of something to build"), SetGameround(12)]),
        RenameChecker(12),
        SwitchToNextRoundChecker(13, [ScoreMgr.players.getScore().set(0), ScoreMgr.roundTimer.getScore().set(0), SetGameround(20)]),

        SwitchToNextRoundChecker(20, [GameStateObjective(20), SetGameround(21)]),
        CalcReadyScores(21),
        ReadyChecker(21),
        SwitchToNextRoundChecker(22, [ScoreMgr.players.getScore().set(0),  SetGameround(30)]),

        SwitchToNextRoundChecker(30, [GameStateRename(31), SetGameround(32)]),
        RenameChecker(32),
        SwitchToNextRoundChecker(33, [ScoreMgr.players.getScore().set(0), ScoreMgr.roundTimer.getScore().set(0), SetGameround(40)]),

        SwitchToNextRoundChecker(40, [GameStateObjective(40), SetGameround(41)]),
        CalcReadyScores(41),
        ReadyChecker(41),
        SwitchToNextRoundChecker(42, [ScoreMgr.players.getScore().set(0), SetGameround(50)]),

        SwitchToNextRoundChecker(50, [GameStateRename(51), SetGameround(52)]),
        RenameChecker(52),
        SwitchToNextRoundChecker(53, [ScoreMgr.players.getScore().set(0), ScoreMgr.roundTimer.getScore().set(0), SetGameround(60)]),

        SwitchToNextRoundChecker(60, [GameStateObjective(60), SetGameround(61)]),
        CalcReadyScores(61),
        ReadyChecker(61),
        SwitchToNextRoundChecker(62, [ScoreMgr.players.getScore().set(0),  SetGameround(70)]),

        SwitchToNextRoundChecker(70, [GameStateRename(71), SetGameround(72)]),
        RenameChecker(72),
        SwitchToNextRoundChecker(73, [ScoreMgr.players.getScore().set(0), ScoreMgr.roundTimer.getScore().set(0), SetGameround(80)]),

        SwitchToNextRoundChecker(80, [GameStateObjective(80, objective: "Your term evolved into"), SetGameround(81)]),
        SwitchToNextRoundChecker(81, [ShowAllObjectives(), SetGameround(82)]),
      ],
      main: File(
          // definining a file that runs every tick
          'main',
          child: MainFile()),
      load: File(
          // definining a file that runs on reload
          'load',
          child: LoadFile()),
      files: [],
    );
  }
}
