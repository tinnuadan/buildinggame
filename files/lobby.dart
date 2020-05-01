import 'package:objd/core.dart';
import '../files/scoreboards.dart';
import 'game_player.dart';
import 'globals.dart';
import 'gamechecker.dart';
import 'utils.dart';

class CountPlayers extends Widget {
  @override
  generate(Context context) {

    final gameround = 0;

    String allPlayers = Entity(type: Entities.player).toString();
    String readyPlayers = Entity(type: Entities.player, tags: [GetRoundReadyTag(gameround)]).toString();

    Score sc_readyPlayers = ScoreMgr.players.get();
    Score sc_allPlayers = ScoreMgr.playerAll.get();

    return If(ScoreMgr.gameState.get().matches(gameround),
    then: [
      sc_readyPlayers.setToResult(Command("execute if entity ${readyPlayers}")),
      sc_allPlayers.setToResult(Command("execute if entity ${allPlayers}")),
    ]);
  }
}

class StartGame extends Widget {
  
  @override
  generate(Context context) {
    Score scPlayers = ScoreMgr.gameStatePlayers.get();
    Score scTmp = ScoreMgr.tmp.get();
    final allPlayers = Entity(type: Entities.player).toString();
    final notProcessed = Entity(type: Entities.player, scores: [Score(Entity.All(), "orig_lane").matches(-1)]).toString();
    return For.of([
      If(Condition.and([
        ScoreMgr.gameState.get().matches(0)
      ]),
      then: [
        Say("Starting game"),
        // scPlayers.setToResult(Command("execute if entity ${allPlayers}")),
        scPlayers.set(0),
        scTmp.set(999),
        Score(Entity(type: Entities.player), "orig_lane").set(-1),
        Entity(type: Entities.player, scores: [Score(Entity.All(), "orig_lane").matches(-1)]).addTag("player"),
        Do.Until(
          Condition.score(scTmp.matches(0)),
          translate: Location.rel(x:0, y:0, z:0),
          then: [            
            Score(Entity(type: Entities.player, scores: [Score(Entity.All(), "orig_lane").matches(-1)], limit: 1), "orig_lane").setEqual(scPlayers),
            scPlayers.add(1),
            scTmp.setToResult(Command("execute if entity ${notProcessed}")),
        ]),
        If.not(scPlayers.matches(0), then: [
          SetGameround(10),
          // ScoreMgr.gameStatePlayers.get().setEqual(scPlayers),
          Timeout("to_test", ticks: 20, children: [Say("countdown")]),
          Title.resetTimes(Entity.All()),
          MyCountdown("to_lobby_cd", 5,
            message: "Starting Game",
            then: SetGameround(11))
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

class CheckChest extends Widget {
  @override
  generate(Context context) {
    return SetBlock(Blocks.chest, location: Globals.guiLocation);
  }
}
