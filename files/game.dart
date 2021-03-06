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


class RemoveWalls extends Widget {
  @override
  generate(Context context) {
    // final rndID = GetRoundID(round);

    final wallStart = 
     Location.glob(
      x: Globals.plotStart.x + Global_Offsets.wallStart.x,
      y: Globals.plotStart.y + Global_Offsets.wallStart.y,
      z: Globals.plotStart.z + Global_Offsets.wallStart.z,
    );
    final wallLength = Global_Offsets.wallLength;
    final laneOffset = Global_Offsets.laneMove;
    final plotOffset = Global_Offsets.playerMove;
    return File("internal/removewalls",
      execute: true,
      child: For(from: 0, to: Globals.maxPlayers-1,
        create: (laneIDX) {
          final curLaneOffset = laneOffset.multiply(laneIDX.toDouble());
          return For(from: 0, to: 3, create: (i) {
            final curRoundOffset = plotOffset.multiply(i.toDouble());
            final l1 = Location.glob(
              x: wallStart.x + curLaneOffset.x + curRoundOffset.x, 
              y: wallStart.y + curLaneOffset.y + curRoundOffset.y, 
              z: wallStart.z + curLaneOffset.z + curRoundOffset.z
            );           
            final l2 = Location.glob(
              x: l1.x + wallLength.x, 
              y: l1.y + wallLength.y, 
              z: l1.z + wallLength.z
            );
            return Fill(
              Blocks.air,
              area: Area.fromLocations(l1, l2)
            );
          });
        }));
  }
}


class ActivateTPCmdBlocks extends Widget {
  @override
  generate(Context context) {
    final startOffset = Global_Offsets.playerBases[2];
    final globalBase = Location.glob(
      x: Globals.plotStart.x + startOffset.x,
      y: Globals.plotStart.y + startOffset.y,
      z: Globals.plotStart.z + startOffset.z,
    );
    final plotStart = Globals.plotStart;
    final tpOffsets = Global_Offsets.nbTping;
    final laneOffset = Global_Offsets.laneMove;
    print(plotStart);
    print(tpOffsets);
    return File("internal/tpstations",
      execute: true,
      child: For(from: 0, to: Globals.maxPlayers-1,
        create: (laneIDX) {
          final curLaneOffset = laneOffset.multiply(laneIDX.toDouble());
          final l1 = Location.glob(
              x: plotStart.x + curLaneOffset.x + tpOffsets[0].x, 
              y: plotStart.y + curLaneOffset.y + tpOffsets[0].y, 
              z: plotStart.z + curLaneOffset.z + tpOffsets[0].z
            );
          final l2 = Location.glob(
              x: plotStart.x + curLaneOffset.x + tpOffsets[1].x, 
              y: plotStart.y + curLaneOffset.y + tpOffsets[1].y, 
              z: plotStart.z + curLaneOffset.z + tpOffsets[1].z
            );
          final laneBase = Location.glob(
              x: globalBase.x + curLaneOffset.x, 
              y: globalBase.y + curLaneOffset.y, 
              z: globalBase.z + curLaneOffset.z            
          );
          return For.of([
            SetBlock(Blocks.command_block, location: l1, nbt: {"Command":"tp @p ${laneBase.toString()}"}),
            SetBlock(Blocks.command_block, location: l2, nbt: {"Command":"tp @p ${globalBase.toString()}"}), 
          ]);
        }));
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
    return File("internal/renamestations_${rndID}",
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
    return File("internal/objectives_${rndID}",
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
      Score(Entity(type: Entities.player, tags: ["player"]), ScoreMgr.isReady.name).set(0),
      AssignLanes(this.gameround),
      HideObjectives(),
      Title.resetTimes(Entity.All()),
      ScoreMgr.roundTimer.getScore().set(90),
      VisibleScore(ScoreMgr.roundTimer),
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
    final laneGameround = gameround < 80 ? gameround : 10;
    return For.of([
      Score(Entity(type: Entities.player, tags: ["player"]), ScoreMgr.isReady.name).set(0),
      AssignLanes(laneGameround),
      Title.resetTimes(Entity.All()),
      ScoreMgr.roundTimer.getScore().set(60*5),
      VisibleScore(gameround < 80 ? ScoreMgr.roundTimer : null),
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