OSN Replay Viewer
================================

What is it?
--------------------------------
The [Outwitters Sports Network](http://osn.codepenguin.com) (known as OSN) is a fan created website dedicated to the iOS hit strategy game [Outwitters](http://onemanleft.com/games/outwitters/).  The OSN Replay Viewer is the engine that enables the web-based viewing of Outwitters replays.

#####What technology is  used?
* [Processing](http://www.processing.org) for viewing locally.
* [Processing.js](http://www.processingjs.org) and [jQuery](http://www.jquery.com) for viewing in a web browser.

How to use it
--------------------------------

####View a replay locally
Grab the source release of the OSN Replay Viewer and extract it into a folder.
Download the latest copy of [Processing](http://www.processing.org) and open the `processing/processing.pde` from the source.  This should automatically open all the other available processing source files for you.  At this point you can just press the "Run" button and you should see a replay being rendered in Processing.  

######Keyboard Shortcuts
* `j` Previous Frame
* `k` Next Frame
* `n` Previous Turn
* `m` Next Turn

You can view your own replays by just putting in your own replay link in the code:

    controller.loadReplay("outwitters://viewgame?id=ag5vdXR3aXR0ZXJzZ2FtZXIRCxIIR2FtZVJvb20Y6dmkAQw");

The replay viewer has three different render engines that can be used or subclassed to add new functionality.  You can use them by using any of the following lines:

    renderer = new ReplayRenderer(controller); //No images
    renderer = new SDReplayRenderer(controller); //Simple Images
    renderer = new HDReplayRenderer(controller); //High Quality Images

####View a replay in a web browser
You must have [Python 2.7](http://www.python.org) installed so we can start a local webserver.  Grab the source release of the OSN Replay Viewer and extract it into a folder.   From a command prompt change into the `processing` folder from the source.  Execute the following command line:

    python webserver.py

Now open a web browser and navigate to the following URL:

[http://localhost:8080/index.html?id=ag5vdXR3aXR0ZXJzZ2FtZXIRCxIIR2FtZVJvb20Y6dmkAQw](http://localhost:8080/index.html?id=ag5vdXR3aXR0ZXJzZ2FtZXIRCxIIR2FtZVJvb20Y6dmkAQw)

######Keyboard Shortcuts
* `j` Previous Frame
* `k` Next Frame
* `n` Previous Turn
* `m` Next Turn

You can view your own replays by just changing the id parameter in the URL to the id from your own link:

http://localhost:8080/index.html?id=**ag5vdXR3aXR0ZXJzZ2FtZXIRCxIIR2FtZVJvb20Y6dmkAQw**



License
--------------------------------
OSN Replay Viewer is licensed under [MIT](http://opensource.org/licenses/MIT). Refer to license.txt for more information.