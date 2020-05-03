import 'package:objd/core.dart';

import 'scoreboards.dart';
import 'globals.dart';
import 'utils.dart';

class SwitchToNextRoundChecker extends Module {

  int gameround;
  List<Widget> action;
  SwitchToNextRoundChecker(this.gameround, this.action);

  @override
  Widget generate(Context context) {
    return If(ScoreMgr.gameState.get().matches(gameround), then: action, targetFileName: "roundchecker${gameround}");
  }

  @override
  List<File> registerFiles() {
    // TODO: implement registerFiles
    return null;
  }
}


class SetGameround extends Widget {
  int round;
  SetGameround(this.round);
  @override
  generate(Context context) {
    return For.of([
      Log("Setting gameround to $round"),
      ScoreMgr.gameState.getScore().set(round)
      ]);
  }
}


class CalcReadyScores extends Module {
   final int gameround;

  CalcReadyScores(this.gameround);

  @override
  Widget generate(Context context) {
    String readyPlayers = Entity(type: Entities.player, tags: [GetRoundReadyTag(gameround)]).toString();
    Score sc_readyPlayers = ScoreMgr.players.get();
    return If(ScoreMgr.gameState.get().matches(gameround),
    then: [
      sc_readyPlayers.setToResult(Command("execute if entity ${readyPlayers}")),
    ]);
  }

  @override
  List<File> registerFiles() {
    // TODO: implement registerFiles
    return null;
  }
}

class ReadyChecker extends Module {
  final int gameround;

  ReadyChecker(this.gameround);

  @override
  Widget generate(Context context) {
    Score sc_readyPlayers = ScoreMgr.players.get();
    Score sc_allPlayers = ScoreMgr.gameStatePlayers.get();

    return For.of([
      If(Condition.and([
        ScoreMgr.gameState.get().matches(gameround),
        sc_allPlayers.isEqual(sc_readyPlayers)
      ]),
      then: [
        Log("All players ready in round $gameround"),
        ScoreMgr.gameState.get().add(1)
      ])
    ]);
  }

  @override
  List<File> registerFiles() {
    // TODO: implement registerFiles
    return null;
  }
}

class RenameCheckerInternal extends Widget {
  final int gameround;

  RenameCheckerInternal(this.gameround);

  @override
  Widget generate(Context context) {
    Score sc_currentGameRound = ScoreMgr.gameState.get();
    final Score sc_players = ScoreMgr.gameStatePlayers.get();
    Score sc_termChecker = ScoreMgr.termChecker.get();
    Score sc_termChecker2 = ScoreMgr.termChecker2.get();
    final Entity toCheck = Entity(type: Globals.entityToRename, name: Globals.entityToRenameInitialName, tags: [GetRoundTag(gameround)]);
    final String toCheckStr = toCheck.toString();
    return File("internal/renamecheck_$gameround",
      execute: true,
      child: For.of([
      sc_termChecker.setToResult(Command("execute if entity ${toCheckStr}")),
      sc_termChecker2.setEqual(sc_players),
      sc_termChecker2.subtractScore(sc_termChecker),
      ScoreMgr.players.getScore().setEqual(sc_termChecker2),
      If(
        sc_termChecker2.isEqual(sc_players),
        then: [
        Log("Everything renamed in gameround $gameround"),
        sc_currentGameRound.add(1)
      ])
    ]));
  }

}

// checks if all enteties have been renamed and advances the gameround
class RenameChecker extends Module {

  final int gameround;

  RenameChecker(this.gameround);

  @override
  Widget generate(Context context) {
    return For.of([
      If(ScoreMgr.gameState.get().matches(gameround),
        then: [
          RenameCheckerInternal(gameround)
      ])
    ]);
  }

  @override
  List<File> registerFiles() {
    // TODO: implement registerFiles
    return null;
  }

}