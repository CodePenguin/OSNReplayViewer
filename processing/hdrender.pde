/* @pjs preload="/images/tiles.png"; */

class HDReplayRenderer extends ReplayRenderer {
  
  PImage img_bib, img_wp1, img_fw;
  PImage[] img_t, img_o, img_wit, img_bb, img_b, img_s;
  HashMap[][] img_u;
 
  float TILE_WIDTH, TILE_HEIGHT, BIB_YOFFSET;
  
  HDReplayRenderer(ReplayController _controller) {
    super(_controller);
    if (controller.replayLoaded)
      loadSprites();
  }
  
  String getRaceAbbr(int raceID) {
    String ret = null;
    switch (raceID) {
      case RACE_ADORABLES: ret = "a"; break;
      case RACE_FEEDBACK: ret = "f"; break;
      case RACE_SCALLYWAGS: ret = "s"; break;
      case RACE_VEGGIENAUTS: ret = "v"; break;
      default:
        handleError("Error: Unhandled raceID " + raceID);
    } 
    return ret;
  } 
  PImage loadSprite(JSONObject tileset, PImage img_tileset, String name) {
    PImage img = null;
    try {
      JSONObject frame = tileset.getJSONObject(name + ".png").getJSONObject("frame");
      img = img_tileset.get(frame.getInt("x"), frame.getInt("y"), frame.getInt("w"), frame.getInt("h"));
    } catch (Exception e) {
      handleError("There was an error parsing the JSONObject (loadSprite): " + e);
    };
    return img;
  }
  
  void loadSprites() {
    controller.writeDebug("Loading sprites...");
    try {
      JSONObject tiles = (JSONObject.parse(FileToString("/images/tiles.json"))).getJSONObject("frames");
      PImage img = loadImage(IMAGE_PATH + "tiles.png");
      
      String mr = getRaceAbbr(controller.maptheme);
     
      img_bib = loadSprite(tiles, img, mr + "bib");
      BIB_YOFFSET = (TILE_WIDTH * ((float)img_bib.height / img_bib.width) - TILE_HEIGHT) / 2;
      img_fw = loadSprite(tiles, img, "tfw");
      img_wp1 = loadSprite(tiles, img, "wp1");
      img_t = new PImage[4];
      img_t[0] = loadSprite(tiles, img, mr + "t1");
      img_t[1] = loadSprite(tiles, img, mr + "t2");
      img_t[2] = loadSprite(tiles, img, mr + "t3");
      img_t[3] = loadSprite(tiles, img, mr + "t4");
      img_o = new PImage[3];
      img_o[0] = loadSprite(tiles, img, mr + "o1");
      img_o[1] = loadSprite(tiles, img, mr + "o2");
      img_o[2] = loadSprite(tiles, img, mr + "o3");
      img_wit = new PImage[5];
      img_wit[0] = loadSprite(tiles, img, "tsn");
      img_wit[1] = loadSprite(tiles, img, "tsb");
      img_wit[2] = loadSprite(tiles, img, "tsr");
      img_wit[3] = loadSprite(tiles, img, "tsg");
      img_wit[4] = loadSprite(tiles, img, "tsy");
     
      img_u = new HashMap[4][4];
      for (int c = 0; c < 4; c++) {
        String cr = null;
        switch (c) {
          case 0: cr = "b"; break;
          case 1: cr = "r"; break;
          case 2: cr = "g"; break;
          case 3: cr = "y"; break; 
        }
        img_u[c][RACE_FEEDBACK - 1] = new HashMap();
        img_u[c][RACE_FEEDBACK - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "fu1" + cr));
        img_u[c][RACE_FEEDBACK - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "fu2" + cr));
        img_u[c][RACE_FEEDBACK - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "fu3" + cr));
        img_u[c][RACE_FEEDBACK - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "fu4" + cr));
        img_u[c][RACE_FEEDBACK - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "fu5" + cr));
        img_u[c][RACE_FEEDBACK - 1].put(UNIT_SCRAMBLER, loadSprite(tiles, img, "fu6" + cr));
        
        img_u[c][RACE_ADORABLES - 1] = new HashMap();
        img_u[c][RACE_ADORABLES - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "au1" + cr));
        img_u[c][RACE_ADORABLES - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "au2" + cr));
        img_u[c][RACE_ADORABLES - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "au3" + cr));
        img_u[c][RACE_ADORABLES - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "au4" + cr));
        img_u[c][RACE_ADORABLES - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "au5" + cr));
        img_u[c][RACE_ADORABLES - 1].put(UNIT_MOBI, loadSprite(tiles, img, "au7" + cr));
        img_u[c][RACE_ADORABLES - 1].put(UNIT_MOBI + ALT_OFFSET, loadSprite(tiles, img, "au72" + cr));
        
        img_u[c][RACE_SCALLYWAGS - 1] = new HashMap();
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "su1" + cr));
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "su2" + cr));
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "su3" + cr));
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "su4" + cr));
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "su5" + cr));
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_BOMBSHELL, loadSprite(tiles, img, "su8" + cr));
        img_u[c][RACE_SCALLYWAGS - 1].put(UNIT_BOMBSHELL + ALT_OFFSET, loadSprite(tiles, img, "su82" + cr));
        
        img_u[c][RACE_VEGGIENAUTS - 1] = new HashMap();
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "vu1" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "vu2" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "vu3" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "vu4" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "vu5" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_BRAMBLE, loadSprite(tiles, img, "vu9" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_BRAMBLE + ALT_OFFSET, loadSprite(tiles, img, "vu92" + cr));
        img_u[c][RACE_VEGGIENAUTS - 1].put(UNIT_THORN, loadSprite(tiles, img, "vu10" + cr));
      }
      
      String p1r = getRaceAbbr(((Player)controller._players.get(0)).raceID);
      String p2r = getRaceAbbr(((Player)controller._players.get(1)).raceID);
      
      img_bb = new PImage[4];
      img_bb[0] = loadSprite(tiles, img, "tbb");
      img_bb[1] = loadSprite(tiles, img, "tbr");
      img_b = new PImage[4];
      img_b[0] = loadSprite(tiles, img, p1r + "b1b");
      img_b[1] = loadSprite(tiles, img, p2r + "b1r");
      img_s = new PImage[4];
      img_s[0] = loadSprite(tiles, img, p1r + "sb");
      img_s[1] = loadSprite(tiles, img, p2r + "sr");
      
      if (controller._players.size() > 2) {
        String p3r = getRaceAbbr(((Player)controller._players.get(2)).raceID);
        String p4r = getRaceAbbr(((Player)controller._players.get(3)).raceID);
        img_bb[2] = loadSprite(tiles, img, "tbg");
        img_bb[3] = loadSprite(tiles, img, "tby");
        img_b[2] = loadSprite(tiles, img, p3r + "b1g");
        img_b[3] = loadSprite(tiles, img, p4r + "b1y");
        img_s[2] = loadSprite(tiles, img, p3r + "sg");
        img_s[3] = loadSprite(tiles, img, p4r + "sy");
      }
        
    } catch (Exception e) {
      handleError("There was an error parsing the JSONObject (loadSprites): " + e);
    };
  }
  
  void processLoadReplay(String filename) {
    super.processLoadReplay(filename);
    loadSprites();
  }
  
  void drawBase(int id) {
    pushStyle();
    Base base = controller._bases[id];
    Player player = (Player)controller._players.get(id);
    PImage img = img_b[id];
    float x = getX(base.i);
    float y = getY(base.i, base.j);
    float diff = ((float)img.height / img.width);
    float base_width = TILE_WIDTH * 1.8;
    imageMode(CENTER);
    image(img, x, y - HEX_SIZE, base_width, base_width * diff);
    stroke(255);
    fill(getPlayerColorDark(player.playerID));
    ellipse(x, y + HEX_SIZE * 3.3, 28, 28);
    fill(255);
    fill(COLOR_BASE_TEXT);
    textFont(f, 2 * HEX_SIZE);
    drawText(str(base.health), x, y + HEX_SIZE * 3.3);
    popStyle(); 
  }
  
  void drawTile(int i, int j) {
    pushStyle();
    float x = getX(i);
    float y = getY(i, j);
    Tile tile = controller.grid[i][j];
    
    imageMode(CENTER);
    
    if (tile.tileType > 0)
      image(img_bib, x, y + BIB_YOFFSET, TILE_WIDTH, TILE_HEIGHT * 1.3);
    
    switch (tile.tileType) {
      case TILE_FLOOR:
        image(img_t[tile.subType], x, y, TILE_WIDTH, TILE_HEIGHT);
        break;
      case TILE_BASE:
        image(img_bb[tile.owner - 1], x, y, TILE_WIDTH, TILE_HEIGHT);
        break;  
      case TILE_OBSTACLE:
        PImage ob = img_o[tile.subType];
        float diff = ((float)ob.height / ob.width);
        float yoffset = (TILE_WIDTH * diff - TILE_HEIGHT) / 2;
        image(ob, x, y - yoffset, TILE_WIDTH, TILE_WIDTH * diff);
        break;
      case TILE_WIT:
        image(img_wit[tile.owner], x, y, TILE_WIDTH, TILE_HEIGHT);
        break;    
      case TILE_SPAWN:
        image(img_s[tile.owner - 1], x, y, TILE_WIDTH, TILE_HEIGHT);
        if (tile.used) {
          fill(COLOR_SPAWN_USED);
          stroke(0, 0);
          drawHex(x, y);
        }
        break;
    } 
    
    if (tile.tileType > 0 && tile.tileType != TILE_BASE && tile.tileType != TILE_OBSTACLE) {
      if (!fog_grid[i][j])
        image(img_fw, x, y, TILE_WIDTH, TILE_HEIGHT);
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
    float healthX = x - width/1.4;
    float healthY =  y - width;
    
    imageMode(CENTER);
    PImage img;
    if (unit.unitClass == UNIT_BOMBSHELL && unit.isAlt == 1)
      img = (PImage)img_u[unit.owner - 1][unit.race-1].get(UNIT_BOMBSHELL + ALT_OFFSET);
    else if (unit.unitClass == UNIT_BRAMBLE && unit.isAlt == 1)
      img = (PImage)img_u[unit.owner - 1][unit.race-1].get(UNIT_BRAMBLE + ALT_OFFSET);
    else if (unit.unitClass == UNIT_MOBI && unit.isAlt == 1)
      img = (PImage)img_u[unit.owner - 1][unit.race-1].get(UNIT_MOBI + ALT_OFFSET);
    else
      img = (PImage)img_u[unit.owner - 1][unit.race-1].get(unit.unitClass);
    float r = 0.6;   
    image(img, x, y - HEX_SIZE * r, img.width * r, img.height * r);
    
    stroke(255);
    fill(getPlayerColorDark(unit.owner));
    ellipse(healthX, healthY, 15, 15);
    fill(255);
    textFont(f, 1 * HEX_SIZE);
    drawText(str((unit.isAlt == 0 ? unit.health : unit.health + unit.altHealth)), healthX, healthY + (0.15 * HEX_SIZE));
    popStyle();
  }
  
  void drawWitBonus(int i, int j) {
    float r = 0.4;
    imageMode(CENTER);
    image(img_wp1, getX(i) + HEX_SIZE * 0.7, getY(i, j) + HEX_SIZE * 0.7, img_wp1.width * r, img_wp1.height * r); 
  }
  
  void processSpawnUnitAction(int role) {
      super.processSpawnUnitAction(role);
      pushStyle();
      noStroke();
      Unit unit = controller.selectedUnit;
      strokeWeight(4);
      stroke(getPlayerColor(unit.owner), 255);
      noFill();
      float x = getX(unit.i), y = getY(unit.i, unit.j) - TILE_WIDTH * 0.1, d = TILE_WIDTH * 1.7;
      ellipse(x, y, d, d);
      stroke(getPlayerColorDark(unit.owner));
      strokeWeight(2);
      float r = 1.05;
      ellipse(x, y, d * r, d * r);
      popStyle();
  }  

  void processRootBrambleAction() {
    Unit selectedUnit = controller.selectedUnit;
    if (selectedUnit.isAlt == 0) {
      selectedUnit.isAlt = 1;
      selectedUnit.vision = 2;  
      drawFrame();
    } else {
      selectedUnit.isAlt = 0;
      selectedUnit.vision = selectedUnit.moves;
      drawFrame();
      controller.removeSpawnedFrom(selectedUnit);
    }
  }
  
  
  void setWindowSize() {
    super.setWindowSize();
    TILE_WIDTH = HEX_SIZE * 4;
    TILE_HEIGHT = HEX_SIZE * 3.6;
  }
  
}
