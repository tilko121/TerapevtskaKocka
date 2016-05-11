class GameState extends AbstractState {

    boolean click_counter=false;

    float[] axis = new float[4];

    int cc=0;

    int timer = 1000;

    final int HOLD_TIME_MS = 2000;

    int holdTimer = 0;

    int currentTask = 0;


    Side sideToComplete;


    public void nextTask() {
        currentTask++;

        Side prevSide = sideToComplete;

        do {

            int randomSide = (int)random(6);
            sideToComplete = getSideByValue(randomSide);
        } while (sideToComplete == prevSide);
        
    }


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

        //COMMAND SENDING ------------------------------------------------------
        if (millis() >= timer + 50) {
            timer = millis();
            cube.sendCommand(Command.QUATERNION);
            cube.sendCommand(Command.RAWACCEL);
            cube.sendCommand(Command.YAWPITCHROLL);
        }
        //COMMAND SENDING ------------------------------------------------------


        if (cube.getCurrentSide() == sideToComplete) {
            if (!cube.isMoving()) {
                if (millis() >= timer + HOLD_TIME_MS) {
                    //task done
                    timer = millis();
                    currentTask++;
                }
            } else {
                timer = millis();
            }
        }




        //COMMAND HANDLING ------------------------------------------------------
        if (cube.handleCommand(Command.QUATERNION)) {
            axis = cube.quat.toAxisAngle(); 
            cube.dmpGetGravity();
        }

        if (cube.handleCommand(Command.RAWACCEL)) {
            cube.dmpGetLinearAccel();
            cube.dmpGetLinearAccelInWorld();
        }

        if (cube.handleCommand(Command.YAWPITCHROLL)) {
            cube.calculateCurrentSide();
        }
        //COMMAND HANDLING ------------------------------------------------------


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

        p.pushMatrix();
        p.translate(screenSizeX / 2, screenSizeY / 2);

        p.rotate(axis[0], -axis[1], axis[3], axis[2]);   

        p.beginShape(QUADS);

        p.fill(1, 1, 1); 
        p.vertex(-50, 50, 50);
        p.fill(1, 1, 1); 
        p.vertex( 50, 50, 50);
        p.fill(1, 1, 1); 
        p.vertex( 50, -50, 50);
        p.fill(1, 1, 1); 
        p.vertex(-50, -50, 50);

        p.fill(1, 0, 0); 
        p.vertex( 50, 50, 50);
        p.fill(1, 0, 0); 
        p.vertex( 50, 50, -50);
        p.fill(1, 0, 0); 
        p.vertex( 50, -50, -50);
        p.fill(1, 0, 0); 
        p.vertex( 50, -50, 50);

        p.fill(0, 1, 0); 
        p.vertex( 50, 50, -50);
        p.fill(0, 1, 0); 
        p.vertex(-50, 50, -50);
        p.fill(0, 1, 0); 
        p.vertex(-50, -50, -50);
        p.fill(0, 1, 0); 
        p.vertex( 50, -50, -50);

        p.fill(0, 0, 1); 
        p.vertex(-50, 50, -50);
        p.fill(0, 0, 1); 
        p.vertex(-50, 50, 50);
        p.fill(0, 0, 1); 
        p.vertex(-50, -50, 50);
        p.fill(0, 0, 1); 
        p.vertex(-50, -50, -50);

        p.fill(0, 1, 1); 
        p.vertex(-50, 50, -50);
        p.fill(0, 1, 1); 
        p.vertex( 50, 50, -50);
        p.fill(0, 1, 1); 
        p.vertex( 50, 50, 50);
        p.fill(0, 1, 1); 
        p.vertex(-50, 50, 50);

        p.fill(0.5, 0.5, 0.5); 
        p.vertex(-50, -50, -50);
        p.fill(0.5, 0.5, 0.5); 
        p.vertex( 50, -50, -50);
        p.fill(0.5, 0.5, 0.5); 
        p.vertex( 50, -50, 50);
        p.fill(0.5, 0.5, 0.5); 
        p.vertex(-50, -50, 50);

        p.endShape();

        p.popMatrix();

        p.text("click counter: " + cc, 100, 200);
    }

    public void destroy() {
    }

    public void controlEvent(ControlEvent theEvent) {
        //Test controlEvent responding to events from ControlP5 on screen elements 


        // println(theEvent.getController().getName());
    }
}