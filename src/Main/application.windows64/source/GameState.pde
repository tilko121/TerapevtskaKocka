class GameState extends AbstractState {

    final int NUM_TASKS = 10;
    final int HOLD_TIME_MS = 1000;
    final int FLASHING_DELAY_MS = 200;
    final int SOLVE_TIME = 15000;
    final int COUNTDOWN_TIME = 3000;

    boolean click_counter=false;
    float[] axis = new float[4];
    int cc=0;
    
    int timer = 1000;
    int holdTimer = millis();
    int currentTask = 0;    
    int flashingDelayTimer = millis();
    boolean flash = false;
    Side sideToComplete = Side.UP;
    
    Textlabel timersLabel;
    Textlabel taskLabel;
    
    int[] times = new int[NUM_TASKS];
    int currentTaskTime = millis();
    int countDownTimer = COUNTDOWN_TIME + millis();

    int timeOnHold = 0;
   
    public void setup(PGraphics pg) { 
        
        gui.setFont(new ControlFont(timesNewRomanPFont, 22));

        numSolvedTasks = 0;
        totalTime = 0;

        taskLabel = gui.addTextlabel("taskLabel")
        .setText("Task 1: Turn Cube to "+ getSideName(sideToComplete) + " Side.")
        .setPosition(screenSizeX/2 - 100, 20);

        timersLabel = gui.addTextlabel("startIn")
        .setText("Start in ... ")
        .setValue(10)
        .setPosition(20, 20);
        
        gui.addButton("Main Menu")
            .setValue(10)
            .setPosition(20, screenSizeY - 30 - 20)
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
        
        
        countDownTimer = COUNTDOWN_TIME + millis();
    }

    public void handleInput() {
    }


    public void update(PApplet p) {
        
        
        if(countDownTimer - millis() < COUNTDOWN_TIME){
            timersLabel.setText("Time Elapsed: " + currentTaskTime/60);
            taskLabel.setText("Task "+ (currentTask+1) +": Turn Cube to "+ getSideName(sideToComplete) + " Side.");
        }else{
            timersLabel.setText("Starts in ... " + (int)((countDownTimer - millis()) / 1000.0));
            return;
        }
        
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
                    currentTaskTime = 0;
                }else{
                    currentTaskTime--;
                }
            } else {
                
                holdTimer = millis();
            }
        } else {
            holdTimer = millis();
        }

        currentTaskTime++;

        if (currentTaskTime/60*1000 >= SOLVE_TIME) {
            currentTaskTime = 0;
            taskFailed();
        }

        //COMMAND HANDLING ------------------------------------------------------
        if (cube.handleCommand(Command.QUATERNION)) {
            //CALIBRATION around YAW according to world axis
            cube.quat = Quaternion.createFromAxisAngle(new Vec3D(0,0,1.0f), (offsetYaw)).multiply(cube.quat);
            //
            axis = cube.quat.toAxisAngle(); 
            if(Float.isNaN(axis[0])){
                 axis[0] = 2*PI;
                 axis[1] = 0.1;
                 axis[2] = 0.1;
                 axis[3] = 0.1;
            }
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


        if (click_counter) StateManager.changeState(State.MainMenu);
        
    }


    public void draw(PGraphics p) {
       
        if (millis() >= flashingDelayTimer + FLASHING_DELAY_MS) {
            flashingDelayTimer = millis() + FLASHING_DELAY_MS;
            flash = !flash;
        }
        
        p.text("axis[0] = " + axis[0] +"axis[1] = " + axis[1] +"axis[2] = " + axis[2] +"axis[3] = " + axis[3], 20, 100); 
        
        p.pushMatrix();
        p.translate(screenSizeX / 2, screenSizeY / 2);
        p.rotate(axis[0], -axis[1], axis[3], axis[2]);  
        
         p.hint(ENABLE_DEPTH_SORT);       
        p.beginShape(QUADS);

        p.fill(getSideColor(Side.RIGHT));
        if (sideToComplete == Side.RIGHT) p.fill(flash ? getSideColor(Side.RIGHT) : getSideColorBright(Side.RIGHT));
        p.vertex(-50, 50, 50);
        p.vertex( 50, 50, 50);
        p.vertex( 50, -50, 50);
        p.vertex(-50, -50, 50);

        p.fill(getSideColor(Side.FRONT));
        if (sideToComplete == Side.FRONT) p.fill(flash ? getSideColor(Side.FRONT) : getSideColorBright(Side.FRONT));
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
        
         p.hint(DISABLE_DEPTH_SORT);       

        p.fill(color(24, 222, 107));
        int rectLen = (int)(((millis() - holdTimer)/((float)HOLD_TIME_MS)) * (screenSizeX / 1.5f));
        if (rectLen >= 30) {
            p.rect(screenSizeX/2 - (rectLen/2.0), 500, rectLen, 30);
        }

        p.fill(flash ? getSideColor(sideToComplete) : getSideColorBright(sideToComplete));
        p.rect(screenSizeX - 100, 20, 50, 50);
    }

    public void destroy() {
        gui.setFont(new ControlFont(arielPFont, 14));
       
    }
    
    
    
     public void taskCompleted() {
        if (currentTask++ >= NUM_TASKS-1) {
            StateManager.changeState(State.ResultState);
        }

        Side prevSide = sideToComplete;

        do {
            int randomSide = (int)random(6);
            sideToComplete = getSideByValue(randomSide);
        } while (sideToComplete == prevSide);
        
        totalTime += (currentTaskTime / 60) * 1000;
        numSolvedTasks++;
        
        println("niqa we made it :D\ntotal time now = " + totalTime);
        println("num solved tasks now = " + numSolvedTasks);
        
        countDownTimer = COUNTDOWN_TIME + millis();
    }

    public void taskFailed() {
        if (currentTask++ >= NUM_TASKS-1) {
            StateManager.changeState(State.ResultState);
        }

        Side prevSide = sideToComplete;

        do {
            int randomSide = (int)random(6);
            sideToComplete = getSideByValue(randomSide);
        } while (sideToComplete == prevSide);
        
        totalTime += SOLVE_TIME;
        
        println("didnt make it :( \ntotal time now = " + totalTime);
        println("num solved tasks now = " + numSolvedTasks);
        
        countDownTimer = COUNTDOWN_TIME + millis();
    }
    
    
}