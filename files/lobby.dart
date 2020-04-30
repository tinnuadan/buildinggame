import 'package:objd/core.dart';
import '../files/scoreboards.dart';
import 'game_player.dart';
import 'globals.dart';
import 'gamechecker.dart';
import 'utils.dart';

class StartGame extends Widget {
  
  @override
  generate(Context context) {
    String allPlayers = Entity(type: Entities.player).toString();

    Score sc_readyPlayers = ScoreMgr.players.get();
    Score sc_allPlayers = ScoreMgr.players.get();

    return For.of([
      sc_allPlayers.setToResult(Command("execute if entity ${allPlayers}")),
      If(Condition.and([
        sc_allPlayers.isEqual(sc_readyPlayers),
        ScoreMgr.gameState.get().matches(0)
      ]),
      then: [
        Say("Starting game"),
        Entity(type:Entities.player, tags:[GetRoundReadyTag(0)]).forEach((Entity e, List<Widget> l) {
          return e.addTag("player");// before tagging to ensure somehow consistent state
        }),
        SetGameround(10),
        ScoreMgr.gameStatePlayers.get().setEqual(sc_readyPlayers),
        Timeout("to_test", ticks: 20, children: [Say("countdown")]),
        MyCountdown("to_lobby_cd", 5,
          message: "Starting Game",
          then: SetGameround(11))
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
    return If(
      Condition.not(
        Tag(tagStr, entity: player) & true
      ),
      then: [
        Score(player, "orig_lane").setEqual(ScoreMgr.players.get()), // before tagging to ensure somehow consistent state
        Tag(tagStr, entity: player, value: true),
        player.tellraw(show: [TextComponent("You marked yourself as ready")]),
        StartGame()
      ]
    );
  }
}


class CheckChest extends Widget {
  @override
  generate(Context context) {
    return SetBlock(Blocks.chest, location: Globals.guiLocation);
  }
}