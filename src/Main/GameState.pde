class GameState extends AbstractState {

    boolean click_counter=false;
    int cc=0;

    int timer = 1000;

    public void setup(PGraphics pg) { 


        gui.addButton("game button")
            .setValue(10)
            .setPosition(20, 20)
            .setSize(200, 30)
            .addListener(new ControlListener () {
            public void controlEvent(ControlEvent event) {
                click_counter= true;
            }
        }
        );
    }

    public void handleInput() {
    }



    public void update(PApplet p) {
        // println("game");
        //if (millis() > 2000) StateManager.changeState(State.ResultState); //To mam samo zato da testiram result screen kot da je oddigrou

        if (millis() > timer + 50) {
            timer = millis();
            cube.sendCommand(Command.HELLO);
        }
        

        if (click_counter)
        {
            println(cc);  
            cc=cc+1;
            click_counter = false;
        }

        if (cc>10)StateManager.changeState(State.ResultState);
        
        cube.handleCommand(Command.HELLO);
        
    }

    public void draw(PGraphics p) {

        p.text("click counter: " + cc, 100, 200);
    }

    public void destroy() {
    }

    public void controlEvent(ControlEvent theEvent) {
        //Test controlEvent responding to events from ControlP5 on screen elements 


        // println(theEvent.getController().getName());
    }
}