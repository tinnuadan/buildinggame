import 'package:objd/core.dart';
import 'scoreboards.dart';

class SummonWorkaround extends Widget {
  
  Summon summon;
  SummonWorkaround(this.summon);

  @override
  generate(Context context) {
    return(Command(
      summon.generate(context).toString().replaceAll(".0d", ".0f")
    ));
  }
}
int GetRoundID(int gameround) {
  return (gameround.toDouble()/10.0).floor().toInt();
}

String GetRoundTag(int gameround) {
  final int r = GetRoundID(gameround);
  return "round${r}";
}

String GetRoundReadyTag(int gameround) {
  final int r = GetRoundID(gameround);
  return "ready_rnd${r}";
}

class MyCountdown extends Widget {
  int seconds;
  String message;
  Widget then;
  String file_id;

  MyCountdown(this.file_id, this.seconds, {this.message, this.then});

  @override
  generate(Context context) {
    return For.of([
      Title(
        Entity.All(),
        show: [
          TextComponent("${message} in ${seconds} seconds")
        ]),
      For(
        from:1,
        to: seconds-1,
        create: (idx) {
          int display = seconds - idx; 
          return Timeout("${file_id}_${idx}", ticks: 20*idx, children: [ 
            Title(
              Entity.All(),
              show: [
                TextComponent("${message} in ${display} seconds")
              ])
          ]);
        }),
        Timeout("to_cd_then", ticks: 20*(seconds), children: [
          Title.clear(Entity.All()), 
          this.then
        ])
    ]);
  }
}

class AdvanceGameState extends Widget {
  double seconds;
  static int _id = 0;

  AdvanceGameState({this.seconds = 1.0}) {
    _id+=1;
  }

  @override
  generate(Context context) {
    return Timeout("to_gamestate${_id}", ticks:(seconds*20).floor().toInt(), children:[ 
      Log("advancing games state"),
      ScoreMgr.gameState.get().add(1) ]);
  }
}