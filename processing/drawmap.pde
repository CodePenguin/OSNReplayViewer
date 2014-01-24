import java.util.Iterator;
import java.util.Map;

PFont f = createFont("Arial Black", 16, true);

String map_name;
JSONObject map_data;
int TEXT_YOFFSET = 0;

final int TILE_NONE = 0;
final int TILE_FLOOR = 1;
final int TILE_OBSTACLE = 2;
final int TILE_BASE = 3;
final int TILE_WIT = 4;
final int TILE_SPAWN = 5;

final int UNIT_SOLDIER = 1;
final int UNIT_RUNNER = 2;
final int UNIT_HEAVY = 3;
final int UNIT_SNIPER = 4;
final int UNIT_MEDIC = 5;
final int UNIT_SCRAMBLER = 6;
final int UNIT_MOBI = 7;
final int UNIT_BOMBSHELL = 8;
final int UNIT_BRAMBLE = 9;
final int UNIT_THORN = 10;

final int FRAME_ACTIVEHEAL = 1;
final int FRAME_EAT = 2;
final int FRAME_ENDTURN = 3;
final int FRAME_MOVEUNIT = 4;
final int FRAME_RANGEATTACK = 5;
final int FRAME_SCRAMBLERSPELL = 6;
final int FRAME_SELECTSPAWNTILE = 7;
final int FRAME_SELECTUNIT = 8;
final int FRAME_SPIT = 9;
final int FRAME_STARTTURN = 10;
final int FRAME_STATE = 11;
final int FRAME_SPAWNUNIT = 12;
final int FRAME_TOGGLEBOMBSHELLMODE = 13;
final int FRAME_ROOTBRAMBLE = 14;
final int FRAME_SPAWNTHORN = 15;
final int FRAME_RETRACTTHORN = 16;

final int RACE_FEEDBACK = 1;
final int RACE_ADORABLES = 2;
final int RACE_SCALLYWAGS = 3;
final int RACE_VEGGIENAUTS = 4;

final int VER_10 = 1000;
final int VER_12 = 1200;
final int VER_15 = 1500;
final int VER_16 = 1600;

final int ALT_OFFSET = 10;

String IMAGE_PATH = "images/";

class Player {
  int colorID;
  String leagueName;
  String name;
  int playerID;
  int raceID;
  int teamID;
  Player(int _playerID, String _name, int _colorID, int _raceID, int _teamID) {
    playerID = _playerID;
    name = _name;
    colorID = _colorID;
    raceID = _raceID;
    teamID = _teamID;
  }
}

class Base {
  int i;
  int j;
  int health;
  Base(int _i, int _j, int _health) {
    i = _i; 
    j = _j; 
    health = _health;
  }
}

class Tile {
  int i;
  int j;
  int tileType;
  int subType;
  int owner;
  boolean used;
  Tile (int _i, int _j) {
    tileType = TILE_FLOOR;
    subType = 0;
    owner = 0;
    i = _i;
    j = _j;
    used = false;
  };
}

class Turn {
  int turnID, startFrame, endFrame, keyFrame;
  Turn(int _turnID, int _startFrame, int _endFrame, int _keyFrame) {
    turnID = _turnID;
    startFrame = _startFrame;
    endFrame = _endFrame;
    keyFrame = _keyFrame;
  }
}

class Frame {
  int frameType;
  int frameID;
  boolean isKeyFrame;
  int turnID;
  JSONObject frameData;
  Frame(int _turnID, int _frameID) {
    turnID = _turnID;
    frameID = _frameID;
  }

  Frame(int _turnID, int _frameID, JSONObject _frameObj) {
    try {
      turnID = _turnID;
      frameID = _frameID; 
      frameData = JSONObject.parse(_frameObj.getString("frameData"));
      String frameName = _frameObj.getString("frameName");
      if (frameName.equals("ActiveHealAction"))
        frameType = FRAME_ACTIVEHEAL;
      else if (frameName.equals("EatAction"))
        frameType = FRAME_EAT;
      else if (frameName.equals("EndTurnAction"))
        frameType = FRAME_ENDTURN;
      else if (frameName.equals("MoveUnitAction"))
        frameType = FRAME_MOVEUNIT;
      else if (frameName.equals("RangeAttackAction"))
        frameType = FRAME_RANGEATTACK;
      else if (frameName.equals("ScramblerSpellAction"))
        frameType = FRAME_SCRAMBLERSPELL;
      else if (frameName.equals("SelectSpawnTileAction"))
        frameType = FRAME_SELECTSPAWNTILE;
      else if (frameName.equals("SelectUnitAction"))
        frameType = FRAME_SELECTUNIT;
      else if (frameName.equals("SpitAction"))
        frameType = FRAME_SPIT;
      else if (frameName.equals("StartTurnAction"))
        frameType = FRAME_STARTTURN;
      else if (frameName.equals("State"))
        frameType = FRAME_STATE;
      else if (frameName.equals("SpawnUnitAction"))
        frameType = FRAME_SPAWNUNIT;
      else if (frameName.equals("ToggleBombShellModeAction"))
        frameType = FRAME_TOGGLEBOMBSHELLMODE;
      else if (frameName.equals("RootBrambleAction"))
        frameType = FRAME_ROOTBRAMBLE;
      else if (frameName.equals("SpawnThornAction"))
        frameType = FRAME_SPAWNTHORN;
      else if (frameName.equals("RetractThornAction"))
        frameType = FRAME_RETRACTTHORN;
      else
        handleError("Error: Unhandled frame type at frame " + _frameID + ": " + frameName);
    } 
    catch (Exception e) {
      handleError("There was an error parsing the JSONObject (Frame): " + e);
    };
  }
}

class Unit {
  int altHealth = 0;
  int base_altHealth = 0;
  int base_health;
  int health;
  int damage = 0;
  boolean hasAttacked = false;
  boolean hasMoved = false;
  int i;
  int identifier;
  int isAlt = 0;
  int j;
  int moves;
  int owner;
  int parent;
  int race;
  int spawnedFrom;
  int teamID;
  int unitClass;
  int unitColor;
  int vision;
  Object specialData;
  Unit(int _identifier, int _class, Player _player, int _i, int _j) {
    identifier = _identifier;
    unitClass = _class;
    race = _player.raceID;
    vision = -1;
    parent = -1;
    spawnedFrom = -1;
    switch (unitClass) {
    case UNIT_SOLDIER: base_health = 3; moves = 3; damage = 2;  break;
    case UNIT_RUNNER: base_health = 1; moves = 5; damage = 1; break;
    case UNIT_HEAVY: base_health = 4; moves = 2; damage = 3; break;
    case UNIT_SNIPER: base_health = 1; moves = 1; damage = 3; vision = 3; break;
    case UNIT_MEDIC: base_health = 1; moves = 3; break;
    case UNIT_SCRAMBLER: base_health = 1; moves = 3; break;
    case UNIT_MOBI: base_health = 2; moves = 3; break;
    case UNIT_BOMBSHELL: base_health = 1; moves = 3; damage = 3; base_altHealth = 2; break;
    case UNIT_BRAMBLE: base_health = 2; moves = 4; break;
    case UNIT_THORN: base_health = 3; moves = 0; vision = 2; damage = 1; break;
    default:
      handleError("Error: Unhandled unit class " + unitClass);
    }
    if (vision == -1)
      vision = moves;
    health = base_health;
    altHealth = base_altHealth;
    owner = _player.playerID;
    teamID = _player.teamID;
    i = _i;
    j = _j;
  }
}

String FileToString(String filename) {
  if (filename.charAt(0) == '/')
    filename = sketchPath(filename.substring(1, filename.length()));
  else if (filename.substring(0,25).equals("outwitters://viewgame?id=")) {
    String gameid = filename.substring(25,filename.length());
    String tmpfilename = sketchPath("data/replays/viewreplay_" + gameid + ".json");
    File file = new File(tmpfilename);
    if (file.exists())
      filename = tmpfilename;
    else {
      filename = "http://osn.codepenguin.com/api/getReplay/" + gameid;
      String[] data = loadStrings(filename);
      saveStrings(tmpfilename, data);
      return join(data, "");
    }
  }
  return join(loadStrings(filename), ""); 
}

void handleError(String msg) {
  println(msg);
  println(0/0); 
}

float[] lengthenLine(float[] coords, float pixelCount) {
  float srcX = coords[0], srcY = coords[1], destX=coords[2], destY = coords[3];
  float dx = destX - srcX;
  float dy = destY - srcY;
  if (dx == 0) {
    pixelCount *= 0.56;
    if (destY < srcY) {
      destY -= pixelCount;
      srcY += pixelCount;
    } 
    else {
      destY += pixelCount;
      srcY -= pixelCount;
    }
  } 
  else if (dy == 0) {
    pixelCount *= 0.6;
    if (destX < srcX) {
      destX -= pixelCount;
      srcX += pixelCount;
    } 
    else {
      destX += pixelCount;
      srcX -= pixelCount;
    }
  }  
  else {
    float len = sqrt(dx * dx + dy * dy);
    float scale = (len + pixelCount) / len;
    dx *= scale;
    dy *= scale;
    destX = srcX + dx;
    destY = srcY + dy;
  }  
  float[] result = {
    srcX, srcY, destX, destY
  };
  return result;
}

final int DIR_N = 1;
final int DIR_NE = 2;
final int DIR_SE = 3;
final int DIR_S = 4;
final int DIR_SW = 5;
final int DIR_NW = 6;

int getCost(int role) {
  switch (role) {
  case UNIT_SOLDIER: return 2;
  case UNIT_RUNNER: return 1;
  case UNIT_HEAVY: return 4; 
  case UNIT_SNIPER: return 3;
  case UNIT_MEDIC: return 2;
  case UNIT_THORN: return 0;
  default: return 7;
  }
}

String getRaceName(int race) {
  switch (race) {
    case RACE_SCALLYWAGS: return "Scallywags";
    case RACE_ADORABLES: return "Adorables";
    case RACE_FEEDBACK: return "Feedback";
    case RACE_VEGGIENAUTS: return "Veggienauts";
    default: return "";
  }
}

String getRoleName(int role) {
  switch (role) {
  case UNIT_SOLDIER: return "Soldier";
  case UNIT_RUNNER: return "Runner";
  case UNIT_HEAVY: return "Heavy"; 
  case UNIT_SNIPER: return "Sniper";
  case UNIT_MEDIC: return "Medic";
  case UNIT_SCRAMBLER: return "Scrambler";
  case UNIT_MOBI: return "Mobi";
  case UNIT_BOMBSHELL: return "Bombshell";
  case UNIT_BRAMBLE: return "Bramble";
  case UNIT_THORN: return "Thorn";
  default: return "";
  }
}

interface ReplayControllerDelegate {
  void processActiveHealAction(Unit target);
  void processEatAction(Unit target);
  void processEndTurnAction();
  void processGameOver(JSONObject gameOverData);
  void processLoadMap(String filename);
  void processLoadReplay(String filename);
  void processMoveUnitAction(int desti, int destj, boolean cancelled);
  void processBombshellRangeAttackAction(int desti, int destj);
  void processRangeAttackAction(int desti, int destj, Object target, int damage);
  void processResetMap();
  void processRetractThornAction();
  void processRootBrambleAction();
  void processScramblerSpellAction(Unit target);
  void processSelectSpawnTileAction(int tilei, int tilej);
  void processRemoveSpawnedUnit(Unit target);
  void processSpawnThornAction(int desti, int destj);
  void processSpawnUnitAction(int role);
  void processSpitAction(int desti, int destj, Unit target);
  void processStartTurnAction();
  void processState(JSONObject frameData);
  void processToggleBombShellModeAction();
  void processWriteDebug(String message);
}

class ReplayController implements ReplayControllerDelegate {

  Tile[][] grid;
  Base[] _bases = new Base[4];
  HashMap _units = new HashMap();
  ArrayList _turns = new ArrayList();
  HashMap _frames = new HashMap();
  ArrayList _players = new ArrayList();
  ArrayList _keyFrames = new ArrayList();
  ArrayList _witPoints = new ArrayList();
  Unit selectedUnit = null;
  Tile selectedTile = null;
  Turn current_turn;
  int columns, rows, maptheme, current_frame, current_key_frame, current_pawnid, current_race, current_team, current_action_points, frame_action_points;
  ReplayControllerDelegate delegate;
  Player current_player;
  boolean mapLoaded = false;
  boolean replayLoaded = false;
  int runtimeVersion = VER_16;

  ReplayController () {
    delegate = this;
  }
 
  int[] getNeighbor(int i, int j, int direction) {
    if (i % 2 == 0)
      switch (direction) {
        case DIR_N: j -= 1; break;
        case DIR_NE: i += 1; j -= 1; break;
        case DIR_SE: i += 1; break;
        case DIR_S: j += 1; break;
        case DIR_SW: i -= 1; break;
        case DIR_NW: i -= 1; j -= 1; break;
      }
    else 
      switch (direction) {
        case DIR_N: j -= 1; break;
        case DIR_NE: i += 1; break;
        case DIR_SE: i += 1; j += 1; break;
        case DIR_S: j += 1; break;
        case DIR_SW: i -= 1; j += 1; break;
        case DIR_NW: i -= 1; break;
      }
    if (i < 0 || i >= columns || j < 0 || j >= rows)
      return null;
    int[] result = {
      i, j
    };
    return result;
  }

  Object getTargetFromCoord(int tilei, int tilej) {
    Object target = getUnitFromCoord(tilei, tilej);   
    if (target != null && ((Unit)target).teamID == current_player.teamID)
      return null;
    else if (target == null && grid[tilei][tilej].tileType == TILE_BASE && ((Player)_players.get(grid[tilei][tilej].owner - 1)).teamID != current_player.teamID)
      target = grid[tilei][tilej];
    return target;
  }

  Unit getUnit(int identifier) {
    return (Unit)_units.get(identifier);
  }

  Unit getUnitFromCoord(int tilei, int tilej) {
    Iterator i = _units.entrySet().iterator();
    while (i.hasNext ()) {
      Map.Entry me = (Map.Entry)i.next();
      Unit unit = (Unit)me.getValue();
      if (unit.i == tilei && unit.j == tilej)
        return unit;
    }
    return null;
  }

  int keyFrameCount() {
    return _keyFrames.size();
  }

  void loadKeyFrame(int index) {
    current_key_frame = index;
    Frame keyFrame = (Frame)_keyFrames.get(index);
    int startFrame;
    if (current_turn == null || keyFrame.turnID != current_turn.turnID || keyFrame.frameID <= current_frame) {
      current_turn = (Turn)_turns.get(keyFrame.turnID - 1);
      startFrame = current_turn.startFrame;
    } 
    else if (current_frame == -1) {
      startFrame = current_turn.startFrame;
    } 
    else {
      startFrame = current_frame + 1;
    }    
    ReplayControllerDelegate temp = delegate;
    delegate = this;
    for (int i = startFrame; i < keyFrame.frameID; i++)
      processFrame(i);
    delegate = temp;
    processFrame(keyFrame.frameID);
  }

  void nextKeyFrame() {
    if (current_key_frame + 1 < _keyFrames.size())
      loadKeyFrame(current_key_frame + 1);
  }

  void prevKeyFrame() {
    if (current_key_frame - 1 >= 0)
      loadKeyFrame(current_key_frame - 1);
  }

  void processFrame(int frameID) {
    try {
      writeDebug("Processing Turn " + current_turn.turnID + " Frame " + frameID + " Key Frame " + current_key_frame);
      current_frame = frameID;
      Frame frame = (Frame)_frames.get(frameID);
      JSONObject frameData = frame.frameData;
      frame_action_points = current_action_points;
      if (frame.frameType == FRAME_ACTIVEHEAL) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        Unit target = getUnitFromCoord(desti, destj);
        current_action_points -= 1;
        delegate.processActiveHealAction(target);
      } 
      else if (frame.frameType == FRAME_EAT) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        Unit target = getUnitFromCoord(desti, destj);
        delegate.processEatAction(target);
      } 
      else if (frame.frameType == FRAME_ENDTURN) {
        delegate.processEndTurnAction();
      } 
      else if (frame.frameType == FRAME_MOVEUNIT) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        boolean cancelled = action.getBoolean("cancelled");
        if (!cancelled)
          current_action_points -= 1;
        delegate.processMoveUnitAction(desti, destj, cancelled);
      } 
      else if (frame.frameType == FRAME_RANGEATTACK) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        Object target = getTargetFromCoord(desti, destj);
        current_action_points -= 1;
        if (selectedUnit.unitClass != UNIT_BOMBSHELL)
          delegate.processRangeAttackAction(desti, destj, target, selectedUnit.damage);
        else
          delegate.processBombshellRangeAttackAction(desti, destj);
      }
      else if (frame.frameType == FRAME_RETRACTTHORN) {
        JSONObject action = frameData.getJSONObject("action");
        delegate.processRetractThornAction();
      }
      else if (frame.frameType == FRAME_ROOTBRAMBLE) {
        JSONObject action = frameData.getJSONObject("action");
        delegate.processRootBrambleAction();
      }
      else if (frame.frameType == FRAME_SCRAMBLERSPELL) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        Unit target = getUnitFromCoord(desti, destj);
        current_action_points -= 1;
        if (runtimeVersion >= VER_12 && (target.unitClass != UNIT_THORN || runtimeVersion >= VER_15))
          current_action_points += 1;
        delegate.processScramblerSpellAction(target);
      } 
      else if (frame.frameType == FRAME_SELECTSPAWNTILE) {
        JSONObject action = frameData.getJSONObject("action");
        int tilei = action.getInt("ix"), tilej = action.getInt("iy");
        delegate.processSelectSpawnTileAction(tilei, tilej);
      } 
      else if (frame.frameType == FRAME_SELECTUNIT) {
        selectedUnit = getUnit(frameData.getJSONObject("action").getInt("pawnID"));
      }
      else if (frame.frameType == FRAME_SPAWNTHORN) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        current_action_points -= 1;
        delegate.processSpawnThornAction(desti, destj);
      }
      else if (frame.frameType == FRAME_SPAWNUNIT) {
        int role = frameData.getJSONObject("action").getInt("role");
        current_action_points -= getCost(role);
        delegate.processSpawnUnitAction(role);
      }
      else if (frame.frameType == FRAME_SPIT) {
        JSONObject action = frameData.getJSONObject("action");
        int desti = action.getInt("desti"), destj = action.getInt("destj");
        Unit target = (Unit)selectedUnit.specialData;
        current_action_points -= 1;
        delegate.processSpitAction(desti, destj, target);
      } 
      else if (frame.frameType == FRAME_STARTTURN) {
        delegate.processStartTurnAction();
      } 
      else if (frame.frameType == FRAME_STATE) {
        writeDebug("Loading Turn " + current_turn.turnID + " Frames " + current_turn.startFrame + " -> " + current_turn.endFrame);
        delegate.processState(frameData);
      }
      else if (frame.frameType == FRAME_TOGGLEBOMBSHELLMODE) {
        current_action_points -= 1;
        delegate.processToggleBombShellModeAction();
      } 
      else {
        handleError("Error: Unhandled frame type: " + frame.frameType);
      }
    } 
    catch (Exception e) {
      handleError("There was an error parsing the JSONObject (processFrame): " + e);
    };
  }

  void processActiveHealAction(Unit target) {
    target.health = target.base_health + 1;
    target.altHealth = target.base_altHealth;
  }

  void processEatAction(Unit target) {
    selectedUnit.specialData = target;
    selectedUnit.isAlt = 1;
  }

  void processEndTurnAction() {
  }

  void processGameOver(JSONObject gameOverData) {

  }

  void processMoveUnitAction(int desti, int destj, boolean cancelled) {
    if (cancelled)
      return;
    selectedUnit.i = desti;
    selectedUnit.j = destj;
    Tile tile = grid[desti][destj];
    if (tile.tileType == TILE_WIT)
      tile.owner = (tile.owner > 0 && tile.owner != current_player.playerID ? 0 : current_player.playerID);
  }

  void processBombshellRangeAttackAction(int desti, int destj) {
    int hitBase = -1;
    delegate.processRangeAttackAction(desti, destj, getTargetFromCoord(desti, destj), 3);
    Tile tile = grid[desti][destj];
    if (tile != null && tile.tileType == TILE_BASE)
      hitBase = tile.owner;
    for (int dir = DIR_N; dir <= DIR_NW; dir++) {
      int[] coord= getNeighbor(desti, destj, dir);
      if (coord != null) {
        tile = grid[coord[0]][ coord[1]];
        if (tile != null && tile.tileType == TILE_BASE) {
          if (hitBase == tile.owner)
            continue;
          hitBase = tile.owner;
        }
        delegate.processRangeAttackAction(coord[0], coord[1], getTargetFromCoord(coord[0], coord[1]), 1);
      }
    }
  }

  void processRangeAttackAction(int desti, int destj, Object target, int damage) {
    if (target != null) {
      if (target instanceof Unit) {
        Unit targetUnit = (Unit)target;
        if (targetUnit.isAlt == 1) {
          targetUnit.altHealth = targetUnit.altHealth - damage;
          if (targetUnit.altHealth < 0) {
            targetUnit.health = max(0, targetUnit.health + targetUnit.altHealth);
            targetUnit.altHealth = max(0, targetUnit.altHealth);
          }
        } 
        else {
          targetUnit.health = max(0, targetUnit.health - damage);
        }
        if (targetUnit.health <= 0) {
          _units.remove(targetUnit.identifier);
          if (targetUnit.unitClass == UNIT_BRAMBLE || targetUnit.unitClass == UNIT_THORN)
            removeSpawnedFrom(targetUnit);
          if (runtimeVersion >= VER_12 && (targetUnit.unitClass != UNIT_THORN || runtimeVersion >= VER_15))
            current_action_points += 1;
          targetUnit = null;
        }
      } 
      else {
        Tile tile = (Tile)target;
        Base base = _bases[tile.owner - 1];
        base.health = max(0, base.health - damage);
      }
    }
  }
  
  void processRemoveSpawnedUnit(Unit target) {
    // 
  }
  
  void processRetractThornAction() {
    removeSpawnedFrom(selectedUnit);
    _units.remove(selectedUnit.identifier);
  }
  
  void processRootBrambleAction() {
    if (selectedUnit.isAlt == 0) {
      selectedUnit.isAlt = 1;
      selectedUnit.vision = 2;  
    } else {
      selectedUnit.isAlt = 0;
      selectedUnit.vision = selectedUnit.moves;
      removeSpawnedFrom(selectedUnit);
    }
  }

  void processScramblerSpellAction(Unit target) {
    if (target.unitClass == UNIT_BRAMBLE) {
      target.isAlt = 0;
      target.vision = selectedUnit.moves;
      removeSpawnedFrom(target);
    } else if (target.unitClass == UNIT_THORN) {
      Iterator iter = _units.entrySet().iterator();
      while (iter.hasNext ()) {
        Map.Entry me = (Map.Entry)iter.next();
        Unit unit = (Unit)me.getValue();
        if (unit.spawnedFrom == target.identifier || unit.parent == target.identifier) {
          unit.health = 1;
          unit.altHealth = 0;
          unit.owner = current_player.playerID;
          unit.teamID = current_team;
        }
      }
    }
    target.health = 1;
    target.altHealth = 0;
    target.owner = current_player.playerID;
    target.teamID = current_team;
    Tile tile = grid[target.i][target.j];
    if (tile.tileType == TILE_WIT)
      tile.owner = (tile.owner > 0 && tile.owner != current_player.playerID ? 0 : current_player.playerID);
  }

  void processSelectSpawnTileAction(int tilei, int tilej) {
    selectedTile = grid[tilei][tilej];
  }

  void processSelectUnitAction(int pawnID) {
    selectedUnit = getUnit(pawnID);
  }
  
  void processSpawnThornAction(int desti, int destj) {
    Unit parent = selectedUnit;
    selectedUnit = new Unit(current_pawnid, UNIT_THORN, current_player, desti, destj);
    if (runtimeVersion != VER_15) {
      selectedUnit.base_health = 2;
      selectedUnit.health = 2;
    }
    selectedUnit.race = RACE_VEGGIENAUTS;
    selectedUnit.parent = parent.parent;
    selectedUnit.spawnedFrom = parent.identifier;
    _units.put(selectedUnit.identifier, selectedUnit);
    Tile tile = grid[desti][destj];
    if (tile.tileType == TILE_WIT)
      tile.owner = (tile.owner > 0 && tile.owner != current_player.playerID ? 0 : current_player.playerID);
    current_pawnid += 1;
  }
  
  void processSpawnUnitAction(int role) {
    selectedTile.used = true;
    selectedUnit = new Unit(current_pawnid, role, current_player, selectedTile.i, selectedTile.j);
    _units.put(selectedUnit.identifier, selectedUnit);
    current_pawnid += 1;
  }

  void processSpitAction(int desti, int destj, Unit target) {
    selectedUnit.isAlt = 0;
    target.i = desti;
    target.j = destj;
    Tile tile = grid[desti][destj];
    if (tile.tileType == TILE_WIT)
      tile.owner = (tile.owner > 0 && tile.owner != current_player.playerID ? 0 : current_player.playerID);
  }

  void processStartTurnAction() {
    if (runtimeVersion >= VER_12 && current_turn.turnID == 2 && _players.size() == 2)
      current_action_points = 8;
    else
      current_action_points += 5;
    for (int i = 0; i < _witPoints.size(); i++) 
      if (((Tile)_witPoints.get(i)).owner == current_player.playerID)
        current_action_points += 1;
    frame_action_points = current_action_points;
  }

  void processState(JSONObject frameData) {
    try {
      resetMap();                        
      JSONObject gameState = frameData.getJSONObject("gameState");
      JSONArray settings = gameState.getJSONArray("settings");
      current_player = (Player)_players.get(gameState.getInt("currentPlayer"));
      JSONObject playerSettings = settings.getJSONObject(current_player.playerID - 1);
      current_team = current_player.teamID;
      current_action_points = playerSettings.getInt("actionPoints");
      for (int i = 0; i < settings.size(); i++)
        _bases[i].health = gameState.getInt("hp_base" + i);
      current_pawnid = gameState.getInt("currentPawnID");

      JSONArray usedSpawns = gameState.getJSONArray("usedSpawns");
      for (int i = 0; i < usedSpawns.size(); i++) {
        JSONObject spawn = usedSpawns.getJSONObject(i);
        grid[spawn.getInt("ix")][spawn.getInt("iy")].used = true;
      }

      JSONArray units = gameState.getJSONArray("units");
      for (int i = 0; i < units.size(); i++) {
        JSONObject unit = units.getJSONObject(i);
        Unit myUnit = new Unit(unit.getInt("identifier"), unit.getInt("class"), (Player)_players.get(unit.getInt("owner") - 1), unit.getInt("positionI"), unit.getInt("positionJ"));
        myUnit.altHealth = unit.getInt("altHealth");
        myUnit.hasAttacked = unit.getBoolean("hasAttacked");
        myUnit.hasMoved = unit.getBoolean("hasMoved");
        myUnit.health = unit.getInt("health");
        myUnit.isAlt = unit.getInt("isAlt");
        myUnit.race = unit.getInt("race");
        myUnit.unitColor = unit.getInt("color");
        myUnit.parent = unit.getInt("parent", -1);
        myUnit.spawnedFrom = unit.getInt("spawnedFrom", -1);

        _units.put(myUnit.identifier, myUnit);
      }

      JSONArray capTiles = gameState.getJSONArray("captureTileStates");
      for (int i = 0; i < capTiles.size(); i++) {
        JSONObject tile = capTiles.getJSONObject(i);
        int tileI = tile.getInt("tileI");
        int tileJ = tile.getInt("tileJ");
        grid[tileI][tileJ].owner = tile.getInt("tileType") - 3;
        Unit unit = controller.getUnitFromCoord(tileI, tileJ);
        if (unit != null && unit.owner != grid[tileI][tileJ].owner && unit.owner == current_player.playerID)
          grid[tileI][tileJ].owner = unit.owner;
      }

      if (gameState.hasKey("gameOverData")) {
        delegate.processGameOver(gameState.getJSONObject("gameOverData"));
      }
    }    
    catch (Exception e) {
      handleError("There was an error parsing the JSONObject (processState): " + e);
    }
  }

  void processToggleBombShellModeAction() {
    selectedUnit.isAlt = (selectedUnit.isAlt == 0 ? 1 : 0);
  }

  void loadTurn(int turnID) {
    current_turn = (Turn)_turns.get(turnID - 1);
    current_frame = -1;
    loadKeyFrame(current_turn.keyFrame);
  }

  void nextTurn() {
    if (current_turn.turnID + 1 < _turns.size())
      loadTurn(current_turn.turnID + 1);
    else
      loadKeyFrame(_keyFrames.size() - 1);
  }

  void prevTurn() {
    if (current_turn.turnID - 1 > 0)
      loadTurn(current_turn.turnID - 1);
    else
      loadTurn(1);
  }

  void loadMap(String filename) {
    delegate.processLoadMap(filename);
  }

  void processLoadMap(String filename) {
    try {
      writeDebug("Reading map file " + filename + "...");

      JSONObject data = JSONObject.parse(FileToString(filename));

      columns = data.getInt("columns");
      rows = data.getInt("rows");
      maptheme = data.getInt("theme", 1);
      
      int defT = 1;
      int defO = 1;
      if (data.hasKey("defaults")) {
        JSONObject defaults = data.getJSONObject("defaults");
        defT = defaults.getInt("t", defT);
        defO = defaults.getInt("o", defO);
      }

      grid = new Tile[columns][rows];
      for (int i = 0; i < columns; i++)
        for (int j = 0; j < rows; j++) {
          grid[i][j] = new Tile(i, j);
          grid[i][j].subType = defT - 1;
        }

      // Load background tiles
      JSONArray tiles = data.getJSONArray("background");
      for (int i = 0; i < tiles.size(); i++) {
        JSONObject tile = tiles.getJSONObject(i);
        int tileI = tile.getInt("i"), tileJ = tile.getInt("j"), tileType = tile.getInt("type");
        grid[tileI][tileJ].tileType = tileType;
        grid[tileI][tileJ].owner = tile.getInt("owner", 0);
        if (tileType == TILE_BASE) {
          _bases[tile.getInt("owner") - 1] = new Base(tileI, tileJ, 5);
          for (int dir = DIR_N; dir <= DIR_NW; dir++) {
            int[] coord= getNeighbor(tileI, tileJ, dir);
            grid[coord[0]][coord[1]].tileType = tileType;
            grid[coord[0]][coord[1]].owner = grid[tileI][tileJ].owner;
          }
        } else if (tileType == TILE_FLOOR)
          grid[tileI][tileJ].subType = tile.getInt("sub", defT) - 1;
        else if (tileType == TILE_OBSTACLE)
          grid[tileI][tileJ].subType = tile.getInt("sub", defO) - 1;
        else if (tileType == TILE_WIT)
          _witPoints.add(grid[tileI][tileJ]);
      }
      mapLoaded = true;
    } catch (Exception e) {
      handleError("There was an error parsing the JSONObject (processLoadMap): " + e);
    };
  }

  void loadReplay(String filename) {
    delegate.processLoadReplay(filename);
  }
  
  void processLoadReplay(String filename) {
    writeDebug("Loading replay file \"" + filename + "\"...");
    try {
      JSONObject data = JSONObject.parse(FileToString(filename));
      if (!data.hasKey("viewResponse"))
        handleError("There was an error parsing the replay data (processLoadReplay): Server returned error " + data.getInt("status"));
      data = data.getJSONObject("viewResponse");   
      map_name = data.getString("mapName") + ".json";
      loadMap("/data/maps/" + map_name);
      JSONObject gameState = JSONObject.parse(data.getString("gameState")).getJSONObject("gameState");
      JSONArray settings = gameState.getJSONArray("settings");
      for (int i = 0; i < settings.size(); i++) {
        JSONObject playerData = settings.getJSONObject(i);
        _players.add(new Player(i + 1, playerData.getString("name"), playerData.getInt("color"), playerData.getInt("race"), playerData.getInt("team")));
      }
      
      JSONArray replay = gameState.getJSONArray("replay");
      int start_frame = 0;
      int end_frame = 0;
      int i = 0;
      int turnCount = 0;
      while (i < replay.size()) {
        JSONObject frameObj = replay.getJSONObject(i);     
        if (frameObj.getString("frameName").equals("State")) {
          start_frame = i;
          end_frame = i+1;
          turnCount++;
          current_key_frame = _keyFrames.size();
          _frames.put(start_frame, new Frame(turnCount, i, frameObj));
          while (end_frame < replay.size()) {
            JSONObject nextFrame = replay.getJSONObject(end_frame);
            String nextFrameName = nextFrame.getString("frameName");
            Frame frame = new Frame(turnCount, end_frame, nextFrame);
            _frames.put(end_frame, frame);
            if (!nextFrameName.equals("EndTurnAction") && !nextFrameName.equals("SelectUnitAction") && !nextFrameName.equals("SelectSpawnTileAction") && !nextFrameName.equals("State")) {
              if (!nextFrameName.equals("MoveUnitAction") || !(JSONObject.parse(nextFrame.getString("frameData"))).getJSONObject("action").getBoolean("cancelled")) {
                frame.isKeyFrame = true;
                _keyFrames.add(frame);
              }
            } 
            else if (nextFrameName.equals("EndTurnAction")) {
              frame.isKeyFrame = true;
              _keyFrames.add(frame);
              end_frame++;
              break;
            } 
            else if (nextFrameName.equals("State")) {
              _keyFrames.add(frame);
              frame.isKeyFrame = true;
              break;
            }
            end_frame++;
          }
          i = end_frame;
          end_frame = min(end_frame, replay.size() - 1);
          _turns.add(new Turn(turnCount, start_frame, end_frame, current_key_frame));
        } else {
          i++;
        }
      }
      replayLoaded = true;
    } catch (Exception e) {
      handleError("There was an error parsing the JSONObject (processLoadReplay): " + e);
    };
  }
  
  void removeSpawnedFrom(Unit parent) {
    ArrayList trash = new ArrayList<Unit>();
    Iterator iter = _units.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry)iter.next();
      Unit unit = (Unit)me.getValue();
      if ((parent.owner == unit.owner) && (unit.spawnedFrom == parent.identifier || unit.parent == parent.identifier)) {
        delegate.processRemoveSpawnedUnit(unit);
        iter.remove();
        trash.add(unit);
        unit = null;
      }
    }
    for (int i = 0; i < trash.size(); i++)
      removeSpawnedFrom((Unit)trash.get(i));
  }

  void resetMap() {
    delegate.processResetMap();
  }
  
  void processResetMap() {
    for (int i = 0; i < columns; i++)
      for (int j = 0; j < rows; j++) {
        if (grid[i][j].tileType == TILE_WIT)
          grid[i][j].owner = 0;
        grid[i][j].used = false;
      }

    for (int i = 0; i < _bases.length; i++)
      if (_bases[i] != null)
        _bases[i].health = 5;

    _units.clear();
  }
  
  void writeDebug(String message) {
    delegate.processWriteDebug(message);
  }
  
  void processWriteDebug(String message) {
    
  }
}

class ReplayRenderer implements ReplayControllerDelegate {

  final color COLOR_ARROW_ATTACK = color(237, 28, 36, 200);
  final color COLOR_ARROW_HEAL = color(47, 153, 189, 200);
  final color COLOR_ARROW_MOVE = color(255, 153, 0, 200);
  final color COLOR_BASE_TEXT = color(255);
  final color COLOR_DAMAGE = color(237, 28, 36);
  final color COLOR_FOG = color(0, 150);
  final color COLOR_FLOOR = color(253, 239, 202);
  final color COLOR_KILLED = color(237, 28, 36, 180);
  final color COLOR_OBSTACLE = color(92,64,51);
  final color COLOR_SPAWN_USED = color(0, 80);
  final color COLOR_TILE_BORDER = color(233, 207, 174);
  final color COLOR_TILE_TEXT = color(0);
  final color COLOR_WITBONUS = color(90,215,107);
  final color COLOR_WITSPACE = color(181, 181, 181);
  final color[] PlayerColors = {color(125, 214, 255), color(255, 159, 153), color(205, 253, 150), color(255, 213, 103)};
  final color[] PlayerColorsDark = {color(0, 85, 153), color(185, 4, 0), color(58, 107, 0), color(153, 85, 0)};
  
  int HEX_SIZE = 12, XOFFSET, YOFFSET;
  final float Y_MULTI = sqrt(3);
  boolean[][] fog_grid;
  Unit[][] unit_grid;

  ReplayController controller;

  ReplayRenderer (ReplayController _controller) {
    controller = _controller;
    controller.delegate = this;

    if (controller._frames.size() > 0)
      setWindowSize();
  }

  void calcFog(boolean[][] grid, int teamID, int i, int j, int distance) {
    if (distance > 0)
      for (int dir = DIR_N; dir <= DIR_NW; dir++) {
        int[] coord= controller.getNeighbor(i, j, dir);
        if (coord != null) {
          int newI = coord[0], newJ = coord[1];
          Tile tile = controller.grid[newI][newJ];
          Unit unit = controller.getUnitFromCoord(newI, newJ);
          grid[newI][newJ] = true;
          if (tile.tileType != TILE_OBSTACLE && tile.tileType != TILE_BASE && (unit == null || unit.teamID == teamID))
            calcFog(grid, teamID, newI, newJ, distance-1);
        }
      }
  }
  
  void calcFog(boolean[][] grid, int teamID) {
    Iterator iter = controller._units.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry)iter.next();
      Unit unit = (Unit)me.getValue();
      unit_grid[unit.i][unit.j] = unit;
      if (unit.teamID == teamID)
        calcFog(grid, teamID, unit.i, unit.j, unit.vision);
    }
  } 

  void drawArrow(int srci, int srcj, int desti, int destj) {
    pushStyle();
    float srcX = getX(srci), srcY = getY(srci, srcj); 
    float destX = getX(desti), destY = getY(desti, destj); 
    float[] coords = {
      destX, destY, srcX, srcY
    };
    coords = lengthenLine(coords, -(1.3 * HEX_SIZE));
    float[] coords2 = {
      coords[2], coords[3], coords[0], coords[1]
    };
    coords = lengthenLine(coords2, -(1 * HEX_SIZE));
    srcX = coords[0]; 
    srcY = coords[1]; 
    destX = coords[2]; 
    destY = coords[3];

    strokeCap(SQUARE);
    strokeWeight(0.3 * HEX_SIZE);
    line(srcX, srcY, destX, destY);
    strokeCap(ROUND);
    pushMatrix();
    translate(destX, destY);
    float a = atan2(srcX - destX, destY - srcY);
    rotate(a);
    line(0, 0, -6, -6);
    line(0, 0, 6, -6);
    popMatrix();
    popStyle();
  }

  void drawHex(float x, float y) {
    pushStyle();
    beginShape();
    float yoffset = Y_MULTI * HEX_SIZE;
    vertex(x - HEX_SIZE, y - yoffset);
    vertex(x + HEX_SIZE, y - yoffset);
    vertex(x + 2 * HEX_SIZE, y);
    vertex(x + HEX_SIZE, y + yoffset);
    vertex(x - HEX_SIZE, y + yoffset);
    vertex(x - 2 * HEX_SIZE, y);
    endShape(CLOSE);
    popStyle();
  }

  void drawX(int i, int j) {
    pushStyle();
    final float OFFSET = 1.3 * HEX_SIZE;
    float x = getX(i), y = getY(i, j);
    strokeWeight(3);
    stroke(COLOR_KILLED);
    line(x - OFFSET, y - OFFSET, x + OFFSET, y + OFFSET);
    line(x - OFFSET, y + OFFSET, x + OFFSET, y - OFFSET);
    popStyle();
  }

  void drawText(String msg, float x, float y) {
    text(msg, x, y - (0.4 * HEX_SIZE) + TEXT_YOFFSET);
  }
  
  void drawBase(int id) {
    pushStyle();
    Base base = controller._bases[id];
    fill(COLOR_BASE_TEXT); 
    drawText(str(base.health), getX(base.i), getY(base.i, base.j));
    popStyle();
  }
  
  void drawFrame() {
    pushStyle();
    background(0);
    textFont(f, 2 * HEX_SIZE);
    textAlign(CENTER, CENTER);

    for (int i = 0; i < controller.columns; i++)
      for (int j = 0; j < controller.rows; j++)
        unit_grid[i][j] = null;

    resetFog(fog_grid);
    calcFog(fog_grid, controller.current_team);

    for (int j = 0; j < controller.rows; j++) {
      for (int i = 0; i < controller.columns; i+=2)
        drawTile(i, j);
      for (int i = 1; i < controller.columns; i+=2)
        drawTile(i, j);
    }
    
    for (int id = 0; id < controller._bases.length; id++)
      if (controller._bases[id] != null)
        drawBase(id);

    textAlign(CENTER, TOP);
    textFont(f, 1.5 * HEX_SIZE);
    fill(getPlayerColor(controller.current_player.playerID));
    text("Turn " + controller.current_turn.turnID + ": " + controller.current_player.name, width/2 - (0.1 * HEX_SIZE), 0.1 * HEX_SIZE - (0.1 * HEX_SIZE));
    fill(getPlayerColorDark(controller.current_player.playerID));
    text("Turn " + controller.current_turn.turnID + ": " + controller.current_player.name, width/2, 0.1 * HEX_SIZE);

    textAlign(LEFT, BOTTOM);
    textFont(f, 1.5 * HEX_SIZE);
    fill(255);
    text("?x" + controller.frame_action_points, 0.5 * HEX_SIZE, height);
    popStyle();
  }
  
  void drawTile(int i, int j) {
    pushStyle();
    float x = getX(i);
    float y = getY(i, j);
    Tile tile = controller.grid[i][j];
    stroke(COLOR_TILE_BORDER);
    switch (tile.tileType) {
    case TILE_FLOOR:
      fill(COLOR_FLOOR);
      drawHex(x, y);
      break;        
    case TILE_OBSTACLE:
      fill(COLOR_OBSTACLE);
      drawHex(x, y);
      break;
    case TILE_BASE:
      fill(getPlayerColorDark(tile.owner));
      drawHex(x, y);
      break;  
    case TILE_WIT:
      if (tile.owner > 0)
        fill(getPlayerColor(tile.owner));
      else
        fill(COLOR_WITSPACE);
      drawHex(x, y);
      fill(COLOR_TILE_TEXT);
      drawText("?+", x, y);
      break;    
    case TILE_SPAWN:
      fill(getPlayerColor(tile.owner));
      drawHex(x, y);
      if (tile.used) {
        fill(COLOR_SPAWN_USED);
        drawHex(x, y);
      }
      fill(COLOR_TILE_TEXT);
      drawText("SP", x, y); 
      break;
    }
    if (tile.tileType > 0 && tile.tileType != TILE_BASE && tile.tileType != TILE_OBSTACLE) {
      if (!fog_grid[i][j]) {
        fill(COLOR_FOG);
        drawHex(x, y);
      }
      if (unit_grid[i][j] != null)
        drawUnit(i,j);
    }
    popStyle();
  }

  void drawUnit(int i, int j) {
    pushStyle();
    Unit unit = unit_grid[i][j];
    float x = getX(unit.i), y = getY(unit.i, unit.j);
    float width = 2.2 * HEX_SIZE;
    float healthX = x - width/2;
    float healthY =  y - width/2;
    
    noStroke();
    fill(getPlayerColorDark(unit.owner));
    ellipse(x,y,35,35);
    
    textAlign(CENTER, CENTER);
    fill(0);
    textFont(f, 1.5 * HEX_SIZE);
    String t = "";
    switch (unit.unitClass) {
    case UNIT_SOLDIER: t = "S"; break;
    case UNIT_RUNNER: t = "R"; break;
    case UNIT_HEAVY: t = "H"; break;
    case UNIT_SNIPER: t = "P"; break;
    case UNIT_MEDIC: t = "M"; break;
    case UNIT_SCRAMBLER: t = "S+"; break;
    case UNIT_MOBI: t = "M+"; break;
    case UNIT_BOMBSHELL: t = (unit.isAlt==0 ? "B" : "B+"); break;
    case UNIT_BRAMBLE: t = (unit.isAlt==0 ? "V+" : "V+"); break;
    case UNIT_THORN: t = "T"; break;
    default:
      handleError("Error: Unhandled unit class " + unit.unitClass);
    }
    drawText(t, x, y);
    
    stroke(255);
    fill(216,0,0);
    ellipse(healthX, healthY, 15, 15);
    fill(255);
    textFont(f, 1 * HEX_SIZE);
    drawText(str((unit.isAlt == 0 ? unit.health : unit.health + unit.altHealth)), healthX, healthY + (0.15 * HEX_SIZE));
    popStyle();
  }
  
  void drawWitBonus(int i, int j) {
    pushStyle();
    fill(COLOR_WITBONUS);
    textAlign(CENTER, CENTER);
    textFont(f, 1 * HEX_SIZE);
    drawText("?+1", getX(i), getY(i, j));
    popStyle(); 
  }

  color getPlayerColor(int player) {
    return PlayerColors[player-1];
  }

  color getPlayerColorDark(int player) {
    return PlayerColorsDark[player-1];
  }
  
  float getX(int col) {
    return HEX_SIZE * (3 * col + 1)  + XOFFSET;
  }
  
  float getY(int col, int row) {
    return HEX_SIZE * Y_MULTI * (col % 2 + 2 * row) + YOFFSET;
  }

  void processLoadMap(String filename) {
    controller.processLoadMap(filename);
    setWindowSize();    
  }
  
  void processLoadReplay(String filename) {
    controller.processLoadReplay(filename); 
  }

  void processActiveHealAction(Unit target) {
    controller.processActiveHealAction(target);
    pushStyle();
    drawFrame();
    stroke(COLOR_ARROW_HEAL);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, target.i, target.j);
    popStyle();
  }

  void processEatAction(Unit target) {
    controller.processEatAction(target);
    pushStyle();
    drawFrame();
    stroke(COLOR_ARROW_HEAL);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, target.i, target.j);
    popStyle();
  }

  void processEndTurnAction() {
    controller.processEndTurnAction();
    drawFrame();
  }

  void processGameOver(JSONObject gameOverData) {
    controller.processGameOver(gameOverData);
    pushStyle();
    try {
      JSONArray winners = gameOverData.getJSONArray("winners");
      String[] winNames = new String[winners.size()];
      for (int i = 0; i < winners.size(); i++) {
        winNames[i] = winners.getJSONObject(i).getString("name");
      }

      String winnerNames = join(winNames, " and ");

      if (winners.size() == 1)
        winnerNames += " wins!";
      else
        winnerNames += " win!";
      
      fill(255);
      textAlign(CENTER, CENTER);
      textFont(f, 2 * HEX_SIZE);
      drawText(winnerNames, width/2, height/2);
      fill(0);
      drawText(winnerNames, (width/2) + 0.2 * HEX_SIZE, (height/2) + 0.2 * HEX_SIZE);

      JSONArray losers = gameOverData.getJSONArray("losers");
    }
    catch (Exception e) {
      handleError("There was an error parsing the JSONObject (processGameOver): " + e);
    };
    popStyle();
  }

  void processMoveUnitAction(int desti, int destj, boolean cancelled) {
    if (cancelled)
      return;
    pushStyle();
    drawFrame();
    stroke(COLOR_ARROW_MOVE);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, desti, destj);
    popStyle();
    controller.processMoveUnitAction(desti, destj, cancelled);
  }

  void processBombshellRangeAttackAction(int desti, int destj) {
    drawFrame();
    pushStyle();
    stroke(COLOR_ARROW_ATTACK);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, desti, destj);
    popStyle();
    controller.processBombshellRangeAttackAction(desti, destj);
  }

  void processRangeAttackAction(int desti, int destj, Object target, int damage) {
    pushStyle();
    if (controller.selectedUnit.unitClass != UNIT_BOMBSHELL) {
      drawFrame();
      stroke(COLOR_ARROW_ATTACK);
      drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, desti, destj);
    }

    if (target instanceof Unit && ((Unit)target).health - damage <= 0) {
      drawX(desti, destj);
      if (controller.runtimeVersion >= VER_12 && ((Unit)target).unitClass != UNIT_THORN || controller.runtimeVersion >= VER_15)
        drawWitBonus(desti, destj);
    }
    else if ((target instanceof Unit && ((Unit)target).owner != controller.current_player.playerID) || (target instanceof Tile && ((Tile)target).owner != controller.current_player.playerID)) {
      fill(COLOR_DAMAGE);
      textAlign(CENTER, CENTER);
      textFont(f, 1 * HEX_SIZE);
      drawText("-" + str(damage), getX(desti), getY(desti, destj));
    }
    popStyle();
    controller.processRangeAttackAction(desti, destj, target, damage);
  }
  
  void processRemoveSpawnedUnit(Unit target) {
    drawX(target.i, target.j);
  }
  
  void processResetMap() {
    controller.processResetMap(); 
  }
  
  
  void processRetractThornAction() {
    drawFrame();
    drawX(controller.selectedUnit.i, controller.selectedUnit.j);
    controller.processRetractThornAction();
  }
  
  void processRootBrambleAction() {
    drawFrame();
    controller.processRootBrambleAction();
    drawUnit(controller.selectedUnit.i, controller.selectedUnit.j);
  }

  void processScramblerSpellAction(Unit target) {
    pushStyle();
    drawFrame();
    stroke(COLOR_ARROW_ATTACK);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, target.i, target.j);
    if (controller.runtimeVersion >= VER_12 && (target.unitClass != UNIT_THORN || controller.runtimeVersion == VER_15))
      drawWitBonus(target.i, target.j);
    popStyle();
    controller.processScramblerSpellAction(target);
  }

  void processSelectSpawnTileAction(int desti, int destj) {
    controller.processSelectSpawnTileAction(desti, destj);
  }
  
  void processSpawnThornAction(int desti, int destj) {
    pushStyle();
    drawFrame();
    stroke(COLOR_ARROW_HEAL);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, desti, destj);
    popStyle();
    controller.processSpawnThornAction(desti, destj);
  }
  
  void processSpawnUnitAction(int role) {
    controller.processSpawnUnitAction(role);
    drawFrame();
  }

  void processSpitAction(int desti, int destj, Unit target) {
    controller.processSpitAction(desti, destj, target);
    pushStyle();
    drawFrame();
    stroke(COLOR_ARROW_HEAL);
    drawArrow(controller.selectedUnit.i, controller.selectedUnit.j, desti, destj);
    popStyle();
  }

  void processStartTurnAction() {
    controller.processStartTurnAction();
    drawFrame();
  }

  void processState(JSONObject frameData) {
    controller.processState(frameData);
  }

  void processToggleBombShellModeAction() {
    controller.processToggleBombShellModeAction();
    drawFrame();
  }
  
  void resetFog(boolean[][] grid) {
    for (int i = 0; i < controller.columns; i++)
      for (int j = 0; j < controller.rows; j++)
        grid[i][j] = false; 
  }

  void processWriteDebug(String message) {
    
  }

  void setWindowSize() {
    XOFFSET = HEX_SIZE * 2;
    YOFFSET = HEX_SIZE;
    size(HEX_SIZE * (3 * 13 - 1) + (2 * XOFFSET), int(HEX_SIZE * Y_MULTI * (2 * 14 - 1)) + (2 * YOFFSET));
    XOFFSET = (2 + (13 - controller.columns)) * HEX_SIZE;
    YOFFSET = (2 + (14 - controller.rows)) * HEX_SIZE;
    unit_grid = new Unit[controller.columns][controller.rows];
    fog_grid = new boolean[controller.columns][controller.rows];
  }
  
}


