class ResultState extends AbstractState {

    //spremenljivke

    Textlabel title, timer, score; 
    boolean retry=false;
    boolean toStart=false;
    //

    public void setup(PGraphics p) {
        println("constructed mainmenu"); 

        gui.setFont(new ControlFont(calibriPFont, 14));

        gui.addButton("Retry")
            .setValue(10)
            .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 - 30)
            .setSize(200, 30)
            .addListener(new ControlListener () {
            public void controlEvent(ControlEvent event) {
                retry = true;
            }
        }
        );

        gui.addButton("Main Menu")
            .setValue(10)
            .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 + 30 )
            .setSize(200, 30)
            .addListener(new ControlListener () {
            public void controlEvent(ControlEvent event) {
                toStart = true;
            }
        }
        );

        title = gui.addTextlabel("TitleLable")
            .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 - 200)
            .setText("FINISHED")
            .setFont(new ControlFont(arielPFont, 40))

            ;

        timer = gui.addTextlabel("TimerLable")
            .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 - 150)
            .setText("Your total time: " + (totalTime / 1000) + " seconds")
            .setSize(50, 30)
            ;

        score = gui.addTextlabel("ScoreLable")
            .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 - 100)
            .setText("You finished: " + numSolvedTasks + " out of 10" )
            .setSize(50, 30)
            ;
    }


    public void update(PApplet p) {

        if (retry) {
            StateManager.changeState(State.GameState);
        }

        if (toStart) {
            StateManager.changeState(State.MainMenu);
        }
    }

    public void draw(PGraphics g) {
        //rendering on display with draw support (use g prefix,  g.fill() etc, etc)
    }

    public void destroy() {
        println("ended life of resultstate");
         if(serialPort != null)serialPort.stop();
         serialPort = null;
    }
}