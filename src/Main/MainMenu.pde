public class MainMenu extends AbstractState {

    //spremenljivke

    DropdownList ddm;
    Button connect, start, exit;
    Textlabel connectionStatus;
    boolean connected = false;
    boolean toStart = false;
    boolean toConnect = false;
    boolean connecting = false;
    int select=-1;
    
    //

    public void setup(PGraphics p) {
        
        println("constructed mainmenu"); 

        connect = gui.addButton("Connect"); 

        println(connect.getColor());

        connectionStatus = gui.addTextlabel("connectionStatus")
            .setText("Not connected")
            .setPosition(screenSizeX / 2 - 145, screenSizeY / 2 - 55);

        exit = gui.addButton("Exit")
            .setValue(10)
            .setPosition (screenSizeX / 2 - 32, screenSizeY / 2 + 50)
            .setSize(64, 32);
        exit.addListener(new ControlListener () {
            public void controlEvent(ControlEvent event) {
                stop();
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
            .setPosition(screenSizeX / 2 - 140, screenSizeY / 2 - 25)
            .setSize(80, 100)
            .setItemHeight(20)
            .setBarHeight(20)
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
                toConnect = true;
            }
        }
        );
    }



    public void update(PApplet p) {
        //update stuff with mouse control possibilities and everything
        // if(millis() > 2000) StateManager.changeState(State.Game);
        if (toStart) {
            StateManager.changeState(State.GameState);
        }

        if (toConnect) {
            toConnect = false;
            connectionStatus.setText("Connecting...");

            Runnable r = new Runnable() {
                public void run() {
                    try {
                        ddm.setLock(true);
                        ddm.setColorBackground(color(100, 100));
                        connect.setLock(true);
                        connect.setColorBackground(color(100, 100));

                        if (serialPort != null) serialPort.stop();
                        serialPort = new Serial(main, ddm.getItem(select).get("name").toString(), 38400);
                        cube.sendCommand(Command.HELLO);
                        int time = millis();
                        while (!cube.handleCommand(Command.HELLO)) {
                            if (millis() >= time+1000) {
                                throw new NotCubeException("Not a cube");
                            }
                        }
                        connected = true;
                        connectionStatus.setText("Connected! Port: " + ddm.getItem(select).get("name"));
                    }
                    catch(NotCubeException ex) {
                        connectionStatus.setText(ex.getMessage());
                    }
                    catch(Exception x) {
                        connectionStatus.setText("Port Busy!");
                    }


                    ddm.setLock(false);
                    ddm.setColorBackground(color(0, 45, 90));
                    connect.setLock(false);
                    connect.setColorBackground(color(0, 45, 90));
                }
            };
            new Thread(r).start();
            gui.update();
        }

        if (connected) {
            start.setLock(false);
            start.setColorBackground(color(0, 45, 90));
        } else {
            start.setLock(true);
            start.setColorBackground(color(100, 100));
        }

        if (toStart) {
            StateManager.changeState(State.CalibrateState);
        }
    }

    public void draw(PGraphics g) {
        //rendering on display with draw support (use g prefix,  g.fill() etc, etc)
    }

    public void destroy() {


        println("ended life of mainmenu");
    }
    
    class NotCubeException extends Exception {
        public NotCubeException(String exc)
        {
            super(exc);
        }
        public String getMessage()
        {
            return super.getMessage();
        }
    }
    
    
}