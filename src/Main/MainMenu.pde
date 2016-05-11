
public class MainMenu extends AbstractState {

  //spremenljivke

  DropdownList ddm;
  Button connect, start, exit;
  Textlabel connectionStatus;
  boolean connected = false;
  boolean toStart = false;
  int select=-1;


  //

  public void setup(PGraphics p) {
    println("constructed mainmenu"); 

    connect = gui.addButton("Connect"); 

    println(connect.getColor());

    connectionStatus = gui.addTextlabel("connectionStatus")
      .setText("Not connected")
      .setPosition(screenSizeX / 2 - 140, screenSizeY / 2 - 45);

    exit = gui.addButton("Exit")
      .setValue(10)
      .setPosition (screenSizeX / 2 - 32, screenSizeY / 2 + 50)
      .setSize(64, 32);
    exit.addListener(new ControlListener () {
      public void controlEvent(ControlEvent event) {
      }
    }
    );

    start = gui.addButton("Start")
      .setValue(10)
      .setPosition(screenSizeX / 2  + 60, screenSizeY / 2  - 60)
      .setSize(100, 64)
      .addListener(new ControlListener () {
      public void controlEvent(ControlEvent event) {
        toStart = true;
      }
    }
    );

    ddm = gui.addDropdownList("COM Port")
      .setPosition(screenSizeX / 2 - 132, screenSizeY / 2 - 25)
      .setSize(64, 100)
      .setItemHeight(20)
      .setBarHeight(15)
      .setOpen(false);

    println(Serial.list());

    for (int x=0; x<Serial.list().length; x++) {
      ddm.addItem(Serial.list()[x], x).setId(x);
    }

    ddm.addListener(new ControlListener() {
      public void controlEvent(ControlEvent event) {
        select = (int)event.getValue();
      }
    }
    );

    connect
      .setPosition(screenSizeX / 2 - 32, screenSizeY / 2 - 60)
      .setSize(64, 64)
      .addListener(new ControlListener() {
      public void controlEvent(ControlEvent event) {
        try {
          if (cube.port != null) {
            cube.port.stop();
          }
          cube.port = new Serial(main, ddm.getItem(select).get("name").toString(), 38400 );
          if(cube.port == null) println("null");
          connected = true;
          connectionStatus.setText("Connected! Port: " + ddm.getItem(select).get("name"));
        }
        catch(Exception ex) {
          connected = false;
          connectionStatus.setText(ex.getMessage());
        };
      }
    }
    );
  }



  public void update(PApplet p) {
    //update stuff with mouse control possibilities and everything
    // if(millis() > 2000) StateManager.changeState(State.Game);
    if (toStart) {
      StateManager.changeState(State.CalibrateState);
    }

    if (connected) {
      start.setLock(false);
      start.setColorBackground(color(0, 45, 90));
    } else {
      start.setLock(true);
      start.setColorBackground(color(100, 100));
    }
  }

  public void draw(PGraphics g) {
    //rendering on display with draw support (use g prefix,  g.fill() etc, etc)
  }

  public void destroy() {


    println("ended life of mainmenu");
  }
}