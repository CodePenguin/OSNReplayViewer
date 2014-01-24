class HeatMapRenderer extends ReplayRenderer {
  int[][] heat_grid;
  boolean suspendDrawing = true;
  
  HeatMapRenderer(ReplayController _controller) {
    super(_controller);
  }
  
  void drawArrow(int srci, int srcj, int desti, int destj) {} 
  void drawFog() {}
  void drawX(int i, int j) {}
  void drawUnit(Unit unit) {}
  
  void drawFrame() {
    if (!suspendDrawing)
     super.drawFrame();
  }
  
  void render() {
    suspendDrawing = true;
    controller.loadKeyFrame(0);
    
    heat_grid = new int[controller.columns][controller.rows];
    for (int i = 0; i < controller.columns; i++)
      for (int j = 0; j < controller.rows; j++)
        heat_grid[i][j] = 0;
    
    Iterator iter = controller._units.entrySet().iterator();
    while (iter.hasNext()) {
      Map.Entry me = (Map.Entry)iter.next();
      Unit unit = (Unit)me.getValue();
      heat_grid[unit.i][unit.j] += 1;
    }
    
    for (int i = 0; i < controller.keyFrameCount(); i++)
      controller.loadKeyFrame(i);
      
    controller.resetMap();
    
    suspendDrawing = false;
    
    drawFrame();
    
    for (int i = 0; i < controller.columns; i++) {
      for (int j = 0; j < controller.rows; j++) {
        switch (controller.grid[i][j].tileType) {
          case TILE_FLOOR: case TILE_WIT: case TILE_SPAWN:
            fill(255,0,0, min(220, heat_grid[i][j] * 30));
            drawHex(getX(i), getY(i,j));
            break;
        }
      }
    }
  }
  
  void processMoveUnitAction(int desti, int destj, boolean cancelled) {
    super.processMoveUnitAction(desti, destj, cancelled);
    heat_grid[desti][destj] += 1;
  }
  
  void processSpawnThornAction(int desti, int destj) {
    super.processSpawnThornAction(desti, destj);
    heat_grid[desti][destj] += 1;
  }
  
  void processSpawnUnitAction(int role) {
    super.processSpawnUnitAction(role);
    heat_grid[controller.selectedTile.i][controller.selectedTile.j] += 1;
  }
  
  void processSpitAction(int desti, int destj, Unit target) {
    super.processSpitAction(desti, destj, target);
    heat_grid[desti][destj] += 1;
  }
  
  void processWriteDebug(String message) {
    
  }
 
}
