import 'package:objd/core.dart';
import 'scoreboards.dart';
import 'gamechecker.dart';
import 'utils.dart';


class LobbyCountPlayers extends Module {
  @override
  Widget generate(Context context) {
    final players = Entity(type: Entities.player);
    return If(ScoreMgr.gameState.get().matches(0),
    then: [
      File("internal/lobby",
        child: For.of([
            ScoreMgr.players.get().setToResult(Command("execute if entity ${players}")),
        ]),
        execute: true
      )
    ]);
  }

  @override
  List<File> registerFiles() {
    return null;
  }
}



class StartGame extends Widget {
  
  @override
  generate(Context context) {
    Score scPlayers = ScoreMgr.gameStatePlayers.get();
    Score scTmp = ScoreMgr.tmp.get();
    final notProcessed = Entity(type: Entities.player, scores: [Score(Entity.All(), "orig_lane").matches(-1)]).toString();
    return For.of([
      If(Condition.and([
        ScoreMgr.gameState.get().matches(0)
      ]),
      then: [
        Say("Starting game"),
        If(
          ScoreMgr.players.get().matchesRange(Range(7, 15)), then: [
            scPlayers.set(0),
            scTmp.set(999),
            Score(Entity(type: Entities.player), ScoreMgr.isReady.name).set(0),
            VisibleScore(ScoreMgr.isReady),
            Score(Entity(type: Entities.player), "orig_lane").set(-1),
            Entity(type: Entities.player, scores: [Score(Entity.All(), "orig_lane").matches(-1)]).addTag("player"),
            Do.Until(
              Condition.score(scTmp.matches(0)),
              translate: Location.rel(x:0, y:0, z:0),
              then: [            
                Score(Entity(type: Entities.player, scores: [Score(Entity.All(), "orig_lane").matches(-1)], limit: 1).sort(Sort.random), "orig_lane").setEqual(scPlayers),
                scPlayers.add(1),
                scTmp.setToResult(Command("execute if entity ${notProcessed}")),
            ]),
            If.not(scPlayers.matches(0), then: [
              SetGameround(10),
              Timeout("to_test", ticks: 20, children: [Say("countdown")]),
              Title.resetTimes(Entity.All()),
              MyCountdown("to_lobby_cd", 5,
                message: "Starting Game",
                then: SetGameround(11))
            ])
          ], orElse: [
            Title.resetTimes(Entity.All()),
            Title(Entity.All(), show: [ TextComponent("7 to 15 players needed")])
          ])
      ])
    ]);
  }
}

class GetReady extends Widget {
  Entity player = null;
  GetReady(this.player);
  @override
  generate(Context context) {
    String tagStr = GetRoundReadyTag(0);
    return 
      For.of([
        Log(player),
    If(
      Condition.not(
        Tag(tagStr, entity: player) & true
      ),
      then: [
        Log(player),
        Score(player, "orig_lane").setEqual(ScoreMgr.players.get()), // before tagging to ensure somehow consistent state
        Tag(tagStr, entity: player, value: true),
        player.tellraw(show: [TextComponent("You marked yourself as ready")]),
        StartGame()
      ])]
    );
  }
}


class StartGameFn extends Widget {
  @override
  generate(Context context) {
    // TODO: implement generate
    return File("start", child: StartGame());
  }
}
