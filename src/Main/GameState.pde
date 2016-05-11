class GameState extends AbstractState {

    final int NUM_TASKS = 10;

    boolean click_counter=false;
    float[] axis = new float[4];
    int cc=0;
    int timer = 1000;
    final int HOLD_TIME_MS = 1000;
    int holdTimer = millis();
    int currentTask = 0;    
    int flashingDelayTimer = millis();
    boolean flash = false;
    final int FLASHING_DELAY_MS = 200;
    Side sideToComplete = Side.UP;

    float countDownTimer = millis();
    final int SOLVE_TIME = 10000;

    public void taskCompleted() {
        if (currentTask++ >= NUM_TASKS) {
            numSolvedTasks++;
            StateManager.changeState(State.ResultState);
        }

        Side prevSide = sideToComplete;

        do {
            int randomSide = (int)random(6);
            sideToComplete = getSideByValue(randomSide);
        } while (sideToComplete == prevSide);
    }

    public void taskFailed() {
        if (currentTask++ >= NUM_TASKS) {
            StateManager.changeState(State.ResultState);
        }

        Side prevSide = sideToComplete;

        do {
            int randomSide = (int)random(6);
            sideToComplete = getSideByValue(randomSide);
        } while (sideToComplete == prevSide);
    }

    public void setup(PGraphics pg) { 

        numSolvedTasks = 0;
        totalTime = 0;

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

        Side current = cube.getCurrentSide();
        do {
            int randomSide = (int)random(6);
            sideToComplete = getSideByValue(randomSide);
        } while (sideToComplete == current);
    }

    public void handleInput() {
    }
    boolean init = true;

    public void update(PApplet p) {
        
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
                if (millis() >= holdTimer + HOLD_TIME_MS) {
                    //task done
                    holdTimer = millis();
                    taskCompleted();
                }
            } else {
                holdTimer = millis();
            }
        } else {
            holdTimer = millis();
        }


        if (millis() >= countDownTimer + SOLVE_TIME) {
            taskFailed();
            countDownTimer = millis();
        }


        //COMMAND HANDLING ------------------------------------------------------
        if (cube.handleCommand(Command.QUATERNION)) {
            //CALIBRATION around YAW according to world axis
            cube.quat = Quaternion.createFromAxisAngle(new Vec3D(0,0,1), (offsetYaw+0.001f)).multiply(cube.quat);
            //
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
    }


    public void draw(PGraphics p) {
        p.text("click counter: " + cc, 100, 200);

        p.text("turn to: " + getSideName(sideToComplete), 50, 100);
        p.text("current side: " + getSideName(cube.getCurrentSide()), 50, 125);

        p.pushMatrix();
        p.translate(screenSizeX / 2, screenSizeY / 2);
        p.rotate(axis[0], -axis[1], axis[3], axis[2]);  

        p.beginShape(QUADS);

        if (millis() >= flashingDelayTimer + FLASHING_DELAY_MS) {
            flashingDelayTimer = millis() + FLASHING_DELAY_MS;
            flash = !flash;
        }

        p.fill(getSideColor(Side.RIGHT));
        if (sideToComplete == Side.RIGHT) p.fill(flash ? getSideColor(Side.RIGHT) : getSideColorBright(Side.RIGHT));
        p.vertex(-50, 50, 50);
        p.vertex( 50, 50, 50);
        p.vertex( 50, -50, 50);
        p.vertex(-50, -50, 50);

        p.fill(getSideColor(Side.FRONT));
        //if (sideToComplete == Side.FRONT) p.fill(flash ? getSideColor(Side.FRONT) : getSideColorBright(Side.FRONT));
        p.vertex( 50, 50, 50);
        p.vertex( 50, 50, -50);
        p.vertex( 50, -50, -50);
        p.vertex( 50, -50, 50);

        p.fill(getSideColor(Side.LEFT));
        if (sideToComplete == Side.LEFT) p.fill(flash ? getSideColor(Side.LEFT) : getSideColorBright(Side.LEFT));
        p.vertex( 50, 50, -50);
        p.vertex(-50, 50, -50);
        p.vertex(-50, -50, -50);
        p.vertex( 50, -50, -50);

        p.fill(getSideColor(Side.BACK));
        if (sideToComplete == Side.BACK) p.fill(flash ? getSideColor(Side.BACK) : getSideColorBright(Side.BACK));
        p.vertex(-50, 50, -50);
        p.vertex(-50, 50, 50);
        p.vertex(-50, -50, 50);
        p.vertex(-50, -50, -50);

        p.fill(getSideColor(Side.DOWN));
        if (sideToComplete == Side.DOWN) p.fill(flash ? getSideColor(Side.DOWN) : getSideColorBright(Side.DOWN));
        p.vertex(-50, 50, -50);
        p.vertex( 50, 50, -50);
        p.vertex( 50, 50, 50);
        p.vertex(-50, 50, 50);

        p.fill(getSideColor(Side.UP));
        if (sideToComplete == Side.UP) p.fill(flash ? getSideColor(Side.UP) : getSideColorBright(Side.UP));
        p.vertex(-50, -50, -50);
        p.vertex( 50, -50, -50); 
        p.vertex( 50, -50, 50); 
        p.vertex(-50, -50, 50);

        p.endShape();
        p.popMatrix();


        p.fill(color(24, 222, 107));
        int rectLen = (int)(((millis() - holdTimer)/((float)HOLD_TIME_MS)) * (screenSizeX / 1.5f));
        if (rectLen >= 30) {
            p.rect(screenSizeX/2 - (rectLen/2.0), 500, rectLen, 30);
        }

        p.fill(flash ? getSideColor(sideToComplete) : getSideColorBright(sideToComplete));
        p.rect(screenSizeX - 100, 50, 50, 50);
    }

    public void destroy() {
    }
}