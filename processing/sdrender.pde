/* @pjs preload="/images/tiles_sd.png"; */

class SDReplayRenderer extends ReplayRenderer {
  
  HashMap[] img_units;
  
  SDReplayRenderer(ReplayController _controller) {
    super(_controller);
    loadSprites();
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
    try {
      JSONObject tiles = (JSONObject.parse(FileToString("/images/tiles_sd.json"))).getJSONObject("frames");
      PImage img = loadImage(IMAGE_PATH + "tiles_sd.png");
      
      img_units = new HashMap[4];

      img_units[RACE_FEEDBACK - 1] = new HashMap();
      img_units[RACE_FEEDBACK - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "fb_soldier"));
      img_units[RACE_FEEDBACK - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "fb_runner"));
      img_units[RACE_FEEDBACK - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "fb_heavy"));
      img_units[RACE_FEEDBACK - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "fb_sniper"));
      img_units[RACE_FEEDBACK - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "fb_medic"));
      img_units[RACE_FEEDBACK - 1].put(UNIT_SCRAMBLER, loadSprite(tiles, img, "fb_scrambler"));
  
      img_units[RACE_ADORABLES - 1] = new HashMap();
      img_units[RACE_ADORABLES - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "ad_soldier"));
      img_units[RACE_ADORABLES - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "ad_runner"));
      img_units[RACE_ADORABLES - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "ad_heavy"));
      img_units[RACE_ADORABLES - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "ad_sniper"));
      img_units[RACE_ADORABLES - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "ad_medic"));
      img_units[RACE_ADORABLES - 1].put(UNIT_MOBI, loadSprite(tiles, img, "ad_mobi"));
      
      img_units[RACE_SCALLYWAGS - 1] = new HashMap();
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "sw_soldier"));
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "sw_runner"));
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "sw_heavy"));
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "sw_sniper"));
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "sw_medic"));
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_BOMBSHELL, loadSprite(tiles, img, "sw_bombshell"));
      img_units[RACE_SCALLYWAGS - 1].put(UNIT_BOMBSHELL + ALT_OFFSET, loadSprite(tiles, img, "sw_bombshell2"));
      
      img_units[RACE_VEGGIENAUTS - 1] = new HashMap();
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_SOLDIER, loadSprite(tiles, img, "vn_soldier"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_RUNNER, loadSprite(tiles, img, "vn_runner"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_HEAVY, loadSprite(tiles, img, "vn_heavy"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_SNIPER, loadSprite(tiles, img, "vn_sniper"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_MEDIC, loadSprite(tiles, img, "vn_medic"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_BRAMBLE, loadSprite(tiles, img, "vn_bramble"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_BRAMBLE + ALT_OFFSET, loadSprite(tiles, img, "vn_bramble2"));
      img_units[RACE_VEGGIENAUTS - 1].put(UNIT_THORN, loadSprite(tiles, img, "vn_thorn"));
      
    } catch (Exception e) {
      handleError("There was an error parsing the JSONObject (loadSprites): " + e);
    };
  }
  
  void drawUnit(int i, int j) {
    pushStyle();
    Unit unit = unit_grid[i][j];
    float x = getX(unit.i), y = getY(unit.i, unit.j);
    float width = 2.2 * HEX_SIZE;
    float healthX = x - width/2;
    float healthY =  y - width/2;
    
    imageMode(CENTER);
    PImage unitImage;
    if (unit.unitClass == UNIT_BOMBSHELL && unit.isAlt == 1)
      unitImage = (PImage)img_units[unit.race-1].get(UNIT_BOMBSHELL + ALT_OFFSET);
    else if (unit.unitClass == UNIT_BRAMBLE && unit.isAlt == 1)
      unitImage = (PImage)img_units[unit.race-1].get(UNIT_BRAMBLE + ALT_OFFSET);
    else
      unitImage = (PImage)img_units[unit.race-1].get(unit.unitClass);
    image(unitImage, x, y, 35, 35);
    
    noStroke();
    fill(getPlayerColorDark(unit.owner), 120);
    ellipse(x,y,35,35);
    
    stroke(255);
    fill(216,0,0);
    ellipse(healthX, healthY, 15, 15);
    fill(255);
    textFont(f, 1 * HEX_SIZE);
    drawText(str((unit.isAlt == 0 ? unit.health : unit.health + unit.altHealth)), healthX, healthY + (0.15 * HEX_SIZE));

    popStyle();
  }
  
}
