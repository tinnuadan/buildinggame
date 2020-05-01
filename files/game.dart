import 'package:objd/core.dart';

import 'scoreboards.dart';
import 'globals.dart';
import 'game_player.dart';
import 'utils.dart';

class RoundTimer extends Widget {
  @override
  Widget generate(Context context) {
    return Timer("roundtimer1",
      children: [
        If(Condition.score(ScoreMgr.roundTimer.get() > 0), then: [ScoreMgr.roundTimer.get().subtract(1)])],
      ticks: 20
    );
  }
}

class AssignLanes extends Widget {
  int round;
  AssignLanes(this.round);

  @override
  generate(Context context) {
    final rnd = (round.toDouble() / 10.0).floor().toInt() - 1;
    return Entity(tags: ["player"]).forEach((Entity e, List<Widget> ln) {
      return Score(e, "curr_lane")
          .set(rnd)
          .subtractScore(Score(e, "orig_lane"))
          .modulo(ScoreMgr.gameStatePlayers.get());
    });
  }
}

class GameStateClearInventories extends Widget {
  @override
  generate(Context context) {
    return Command("clear @e[type=player]");
  }
}

class GameStateGiveRenameTools extends Widget {
  @override
  generate(Context context) {
    return For.of([
      GameStateClearInventories(),
      Entity(type: Entities.player, tags: ["player"]).give(Item(Items.name_tag))
    ]);
  }
}


class HideObjectives extends Widget {
  @override
  generate(Context context) {
    List<String> hideTags = [ "build_instruction" ];
    return Effect(EffectType.invisibility, entity: Entity(type:Entities.sheep, tags:hideTags), duration: 86400, showParticles: false);
  }  
}

class ShowAllObjectives extends Widget {
    @override
  generate(Context context) {
    List<String> hideTags = [ "build_instruction" ];
    return Effect.clear(Entity(type:Entities.sheep, tags:hideTags));
  }  
}


class GenerateRenameStations extends Widget {
  int round;

  GenerateRenameStations(this.round);

  @override
  generate(Context context) {
    final rndID = GetRoundID(round);
    final startOffset = Global_Offsets.playerBases[rndID];
    print("startOffset ${startOffset.x} ${startOffset.y} ${startOffset.z}");
    final startLocationCommon = Location.glob(
      x: Globals.plotStart.x + startOffset.x,
      y: Globals.plotStart.y + startOffset.y,
      z: Globals.plotStart.z + startOffset.z,
    );
    final laneOffset = Global_Offsets.laneMove;
    return File("renamestations${rndID}",
      execute: true,
      child: For(from: 0, to: Globals.maxPlayers-1,
        create: (idx) {
        final offset = laneOffset.multiply(idx.toDouble());
        final loc = Location.glob(
          x: startLocationCommon.x + offset.x, 
          y: startLocationCommon.y + offset.y, 
          z: startLocationCommon.z + offset.z);
        return If(ScoreMgr.gameStatePlayers.get() > (idx),
        then: [
          GenerateRenameStation(loc, round, idx)
        ]);
    }));
  }
}

class GenerateObjectives extends Widget {
  int round;

  GenerateObjectives(this.round);

  @override
  generate(Context context) {
    final rndID = GetRoundID(round);
    final startOffset = Global_Offsets.playerBases[rndID];
    print("startOffset ${startOffset.x} ${startOffset.y} ${startOffset.z}");
    final startLocationCommon = Location.glob(
      x: Globals.plotStart.x + startOffset.x,
      y: Globals.plotStart.y + startOffset.y,
      z: Globals.plotStart.z + startOffset.z,
    );
    final laneOffset = Global_Offsets.laneMove;
    return File("objectives${rndID}",
      execute: true,
      child: For(from: 0, to: Globals.maxPlayers-1,
        create: (idx) {
        final offset = laneOffset.multiply(idx.toDouble());
        final loc = Location.glob(
          x: startLocationCommon.x + offset.x, 
          y: startLocationCommon.y + offset.y, 
          z: startLocationCommon.z + offset.z);
        return If(ScoreMgr.gameStatePlayers.get() > (idx),
        then: [
          GenerateToBuildStation(loc, round, idx)
        ]);
    }));
  }
}


// // coming from the lobby to the first rename station
// 1x, 3x, 5x, 7x
class GameStateRename extends Widget {
  int gameround;
  String objective;
  GameStateRename(this.gameround, {this.objective = "Write down what you see"});

  @override
  generate(Context context) {
    final startOffset = Global_Offsets.playerBases[GetRoundID(gameround)];
    final startLocationCommon = Location.glob(
      x: Globals.plotStart.x + startOffset.x,
      y: Globals.plotStart.y + startOffset.y,
      z: Globals.plotStart.z + startOffset.z,
    );
    final tp = Location.rel(
        x: Global_Offsets.laneMove.x,
        y: Global_Offsets.laneMove.y,
        z: Global_Offsets.laneMove.z);
    return For.of([
      AssignLanes(this.gameround),
      HideObjectives(),
      Title.resetTimes(Entity.All()),
      Execute(
        children: [ForEach(ScoreMgr.gameStatePlayers.get(),
        translate: tp,
        then: (idx) {
          return Entity(tags: ["player"]).forEach((Entity e, List<Widget> l) {
            return If(Condition(Score(e, "curr_lane").isBiggerOrEqual(idx)),
                then: [
                  GameStateEnterPlayer(e, Location.here(), objective: this.objective)
                ]);
          });
        })],
        location: startLocationCommon),
      GameStateGiveRenameTools(),
      GenerateRenameStations(this.gameround)
    ]);
  }
}
// Round 2x,4x,6x, (8x)
class GameStateObjective extends Widget {
  int gameround;
  String objective;
  GameStateObjective(this.gameround, {this.objective = "Build what the sheep says"});

  @override
  generate(Context context) {
    final startOffset = Global_Offsets.playerBases[GetRoundID(gameround)];
    final startLocationCommon = Location.glob(
      x: Globals.plotStart.x + startOffset.x,
      y: Globals.plotStart.y + startOffset.y,
      z: Globals.plotStart.z + startOffset.z,
    );
    final tp = Location.rel(
        x: Global_Offsets.laneMove.x,
        y: Global_Offsets.laneMove.y,
        z: Global_Offsets.laneMove.z);
    return For.of([
      AssignLanes(gameround),
      Title.resetTimes(Entity.All()),
      ScoreMgr.roundTimer.getScore().set(60*5),
      VisibleScore(ScoreMgr.roundTimer),
      Execute(
        children: [ForEach(ScoreMgr.gameStatePlayers.get(),
        translate: tp,
        then: (idx) {
          return Entity(tags: ["player"]).forEach((Entity e, List<Widget> l) {
            return If(Condition(Score(e, "curr_lane").isBiggerOrEqual(idx)),
                then: [
                  GameStateEnterPlayer(e, Location.here(), objective: this.objective, faceNorth: true)
                ]);
          });
        })],
        location: startLocationCommon),
      GameStateClearInventories(),
      GenerateObjectives(this.gameround)
    ]);
  }
}