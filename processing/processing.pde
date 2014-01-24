ReplayController controller;
ReplayRenderer renderer;

void setup() {
  smooth();
  controller = new ReplayController();
  renderer = new HDReplayRenderer(controller);
  controller.runtimeVersion = VER_16;
  controller.loadReplay("outwitters://viewgame?id=ag5vdXR3aXR0ZXJzZ2FtZXIRCxIIR2FtZVJvb20Y6dmkAQw");
  controller.loadKeyFrame(0);
}

void keyPressed() {
  switch(key) {
    case 'j': controller.prevKeyFrame(); break;
    case 'k': controller.nextKeyFrame(); break;
    case 'n': controller.prevTurn(); break;
    case 'm': controller.nextTurn(); break;
  } 
}

void draw() {
  
}
