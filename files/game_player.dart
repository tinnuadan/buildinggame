import 'package:objd/core.dart';
import 'globals.dart';
import 'preciseLocation.dart';
import 'utils.dart';

class GenerateToBuildStation extends Widget {
  Location playerLocation;
  int round;
  int id;
  
  GenerateToBuildStation(this.playerLocation, this.round, this.id);

  @override
  generate(Context context) {
    PreciseLocation entA = PreciseLocation.glob(
      x: playerLocation.x + Global_Offsets.instruction.x,
      y: playerLocation.y + Global_Offsets.instruction.y,
      z: playerLocation.z + Global_Offsets.instruction.z,
    );
    entA.xPrecise = true;
    List<String> sourceTags = [GetRoundTag(round-10), "id${id}", "torename"];
    return For.of([
      SummonWorkaround(Summon(
        Globals.entityToRename,
        location: entA,
        name: TextComponent(Globals.entityToRenameInitialName, color: Color.Aqua),
        invulnerable: true,
        gravity: false,
        noAI: true,
        tags: [GetRoundTag(round), "build_instruction", "id${id}"],
        silent: true,
        rotation: Rotation.south()
      )),
      Data.modify(
        Entity(type: Globals.entityToRename, tags: [GetRoundTag(round), "build_instruction", "id${id}"], limit: 1), 
        path: "CustomName", 
        modify: DataModify.set(
          Entity(type: Globals.entityToRename, tags: sourceTags, limit: 1),
          fromPath: "CustomName"
        ))
    ]);
  }
}

class GenerateRenameStation extends Widget {
  Location playerLocation;
  int round;
  int id;

  GenerateRenameStation(this.playerLocation, this.round, this.id);

  @override
  generate(Context context) {
    Location anvil = Location.glob(
      x: this.playerLocation.x + Global_Offsets.anvil.x,
      y: this.playerLocation.y + Global_Offsets.anvil.y ,
      z: this.playerLocation.z + Global_Offsets.anvil.z,
    );
    Location entityLocation = Location.glob(
      x: playerLocation.x + Global_Offsets.entityToRename.x,
      y: playerLocation.y + Global_Offsets.entityToRename.y,
      z: playerLocation.z + Global_Offsets.entityToRename.z,
    );
    Location quartzA = Location.glob(
      x: this.playerLocation.x + Global_Offsets.anvil.x,
      y: this.playerLocation.y + Global_Offsets.anvil.y,
      z: this.playerLocation.z + Global_Offsets.anvil.z+1,
    );
    Location quartzB = Location.glob(
      x: playerLocation.x + Global_Offsets.entityToRename.x,
      y: playerLocation.y + Global_Offsets.entityToRename.y,
      z: playerLocation.z + Global_Offsets.entityToRename.z+1,
    );
    List<String> tags = [ GetRoundTag(round), "id${id}", "torename"];

    return For.of([
      SetBlock(Blocks.anvil, location: anvil),
      SetBlock(Blocks.gray_concrete, location: quartzA),
      SetBlock(Blocks.gray_concrete, location: quartzB),
      SummonWorkaround(Summon(
        Globals.entityToRename,
        location: entityLocation,
        name: TextComponent(Globals.entityToRenameInitialName, color: Color.Aqua),
        invulnerable: true,
        gravity: false,
        noAI: true,
        tags: tags,
        silent: true,
        rotation: Rotation.north()
      ))
    ]);
  }
}

class GameStateEnterPlayer extends Widget {
  Entity player;
  Location playerLocation;
  String objective;
  bool faceNorth = false;

  GameStateEnterPlayer(this.player, this.playerLocation, {this.objective = null, this.faceNorth = false});

  @override
  generate(Context context) {
    double add = faceNorth ? -1 : 1;
    Location facing = Location.rel(x: 0, y:0, z:add);

    if(this.objective != null) {
      return For.of([
        Teleport(player, to: playerLocation, facing: facing),
        Title(player, show: [ TextComponent(objective) ])
      ]);
    } else {
      return Teleport(player, to: playerLocation, facing: facing);
    }
  }
}
