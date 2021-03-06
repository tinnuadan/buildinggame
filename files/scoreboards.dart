import 'package:objd/core.dart';

class ScorePlayerMgr {
  static Entity Main = Entity.PlayerName("bgplayer");
  static Entity Players = Entity.PlayerName("Ready");
  static Entity RoundTimer = Entity.PlayerName("Time");
}

class SBDisplay {
  static TextComponent GetDisplay(String name) {
    if(name == "player_count") {  return TextComponent("Players"); }
    if(name == "round_timer") { return TextComponent("Time left"); }
    return null;
  }
}

class ScoreWrapper {
  Entity player;
  String name;
  String display;

  ScoreWrapper(this.player, this.name, {this.display = 'sidebar'});

  Score getScore() {
    return Score(player, name);
  }
  Score get() {
    return getScore();
  }

  Scoreboard getScoreboard() {
    return Scoreboard(name, addIntoLoad: true, display: SBDisplay.GetDisplay(name));
  }
}

class InitScoreboard extends Widget {
  TextComponent display;
  ScoreWrapper swrapper;

  InitScoreboard(this.swrapper, {this.display = null});

  @override
  generate(Context context) {
    List<Widget> content = null;
    if(this.display != null) {
      content = List<Widget>();
      content.add(Scoreboard.remove(this.swrapper.name));
      content.add(Scoreboard(this.swrapper.name, addIntoLoad: false, display: this.display));
    }
    return For.of([
      // Scoreboard(this.swrapper.name, addIntoLoad: true, display: this.display),
      For.of(content),
      this.swrapper.getScore().set(0)
    ]);
  }
}

class ScoreMgr { 
  static final players = ScoreWrapper(ScorePlayerMgr.Players, "player_count");
  static final playerAll = ScoreWrapper(ScorePlayerMgr.Main, "player_count_all");

  static final isReady = ScoreWrapper(ScorePlayerMgr.Main, "is_ready", display: "list");

  static final gameState = ScoreWrapper(ScorePlayerMgr.Main, "game_state");
  static final gameStatePlayers = ScoreWrapper(ScorePlayerMgr.Main, "gs_player_count");

  static final termChecker = ScoreWrapper(ScorePlayerMgr.Main, "termcheck");
  static final termChecker2 = ScoreWrapper(ScorePlayerMgr.Main, "termcheck2");

  static final roundTimer = ScoreWrapper(ScorePlayerMgr.RoundTimer, "round_stats");

  static final tmp = ScoreWrapper(ScorePlayerMgr.Main, "tmp");
}



class InitScoreboards extends Widget {
  @override
  generate(Context context) {
    return For.of([
      Scoreboard("undef"),
      InitScoreboard(ScoreMgr.playerAll),
      InitScoreboard(ScoreMgr.players, display: TextComponent("Players")),
      InitScoreboard(ScoreMgr.playerAll),
      InitScoreboard(ScoreMgr.gameState),
      InitScoreboard(ScoreMgr.gameStatePlayers),
      InitScoreboard(ScoreMgr.termChecker),
      InitScoreboard(ScoreMgr.termChecker2),
      InitScoreboard(ScoreMgr.tmp),
      InitScoreboard(ScoreMgr.roundTimer, display: TextComponent("Round")),
    ]);
  }
}

class VisibleScore extends Widget{

  ScoreWrapper score;

  VisibleScore(this.score);

  @override
  generate(Context context) {
    if(score == null) {
      return Scoreboard.setdisplay("undef");
    }
    return Scoreboard.setdisplay(score.getScoreboard().name, display: score.display);
  }
}