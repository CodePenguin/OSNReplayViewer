class ReplayTurn {
  int playerID;
  int turnID;
  String description;
  ArrayList frames = new ArrayList();
  ReplayTurn (int _turnID, int _playerID, String _description) {
    turnID = _turnID;
    playerID = _playerID;
    description = _description; 
  }
}

class ReplayFrame {
  int turnID;
  int frameID;
  String description;
  ReplayFrame(int _frameID, String _description) {
    frameID = _frameID;
    description = _description; 
  }
}

class ReplayStats implements ReplayControllerDelegate {
 
  ReplayController controller;
  ArrayList turns = new ArrayList();
  ReplayTurn lastTurn;
  
  ReplayStats(ReplayController _controller) {
    controller = _controller;
    controller.delegate = this;
  }
  
  void calculate() {
    for (int i = 0; i < controller.keyFrameCount(); i++) {
      controller.loadKeyFrame(i); 
    }
  }
  
  void processLoadMap(String filename) {
    controller.processLoadMap(filename);
  }
  
  void processLoadReplay(String filename) {
    controller.processLoadReplay(filename);
  }
  
  void processResetMap() {
    controller.processResetMap();
  }
  
  void processActiveHealAction(Unit target) {
    controller.processActiveHealAction(target);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Boosted " + getRoleName(target.unitClass)));
  }
  
  void processEatAction(Unit target) {
    controller.processEatAction(target);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Swallowed " + getRoleName(target.unitClass)));
  }
  
  void processEndTurnAction() {
    controller.processEndTurnAction();
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "End of turn"));
  }
  
  void processGameOver(JSONObject gameOverData) {
    controller.processGameOver(gameOverData);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Game Over!"));
  }
  
  void processMoveUnitAction(int desti, int destj, boolean cancelled) {
    if (cancelled)
      return;
    controller.processMoveUnitAction(desti, destj, cancelled);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Moved " + getRoleName(controller.selectedUnit.unitClass) + " to (" + desti + "," + destj + ")"));
  }
  
  void processBombshellRangeAttackAction(int desti, int destj) {
     lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Fired mortar cannon at (" + desti + "," + destj + ")"));
     controller.processBombshellRangeAttackAction(desti, destj);
  }
  
  void processRangeAttackAction(int desti, int destj, Object target, int damage) {
      controller.processRangeAttackAction(desti, destj, target, damage);
      if (target != null) {
        if (target instanceof Unit)
          lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Attacked " + getRoleName(((Unit)target).unitClass) + " for " + damage + " damage")); 
        else
          lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Attacked " + " Base for " + damage + " damage")); 
      }
  }
  
  void processRemoveSpawnedUnit(Unit target) {
    
  }
  
  
  void processRetractThornAction() {
    controller.processRetractThornAction();
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Retracted Thorn"));
  }
  
  void processRootBrambleAction() {
    controller.processRootBrambleAction();
    if (controller.selectedUnit.isAlt == 1)
      lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Rooted Bramble"));
    else
      lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Uprooted Bramble"));
  }
  
  void processScramblerSpellAction(Unit target) {
    controller.processScramblerSpellAction(target);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Brainwashed " + getRoleName(target.unitClass)));
  }
  
  void processSelectSpawnTileAction(int tilei, int tilej) {
    controller.processSelectSpawnTileAction(tilei, tilej);
  }
  
  void processSpawnThornAction(int desti, int destj) {
    controller.processSpawnThornAction(desti, destj);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Spawned " + getRoleName(UNIT_THORN) + " at (" + desti + "," + destj + ")")); 
  }
  
  void processSpawnUnitAction(int role) {
    controller.processSpawnUnitAction(role);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Spawned " + getRoleName(role)));
  }
  
  void processSpitAction(int desti, int destj, Unit target) {
    controller.processSpitAction(desti, destj, target);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Spit out " + getRoleName(target.unitClass)));
  }
  
  void processStartTurnAction() {
    controller.processStartTurnAction();
    lastTurn = new ReplayTurn(controller.current_turn.turnID, controller.current_player.playerID, "Turn " + controller.current_turn.turnID + ": " + controller.current_player.name);
    lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Start of turn"));
    turns.add(lastTurn);
  }
  
  void processState(JSONObject frameData) {
    controller.processState(frameData);
  }
  
  void processToggleBombShellModeAction() {
    controller.processToggleBombShellModeAction();
    if (controller.selectedUnit.isAlt == 1)
      lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Shelled Bombshell"));
    else
      lastTurn.frames.add(new ReplayFrame(controller.current_key_frame, "Unshelled Bombshell"));
  }
  
  void processWriteDebug(String message) {
    
  }
   
}
