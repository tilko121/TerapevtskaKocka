import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import processing.opengl.*; 
import toxi.geom.*; 
import toxi.processing.*; 
import java.util.*; 
import java.io.IOException; 
import java.util.Vector; 
import javax.swing.SwingUtilities; 
import controlP5.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Main extends PApplet {














ToxiclibsSupport gfx;
static ControlP5 gui;
Main main = this;
final static int screenSizeX = 800, screenSizeY = 600;


static PFont arielPFont;
static PFont timesNewRomanPFont;
static PFont calibriPFont;

static int numSolvedTasks = 0;
static int totalTime = 0;

static float offsetYaw = 0.0f;


QiBT_aCube cube = new QiBT_aCube();


static Serial serialPort;
static Queue<Byte> serialBuffer = new LinkedList<Byte>();
public void serialEvent(Serial p) {
    while (p.available() > 0) serialBuffer.add((byte)p.readChar());
}


public void stop() {
    gui.dispose();
    if (serialPort != null) serialPort.stop();
    System.exit(0);
} 


public void setup() {
    arielPFont = createFont("Ariel", 64);
    timesNewRomanPFont = createFont("Times New Roman", 22);
    calibriPFont = createFont("Calibri", 14);
        
    
    noStroke();
    gui = new ControlP5(this);
    
    lights();
    
    colorMode(RGB, 1);

    StateManager.pushState(State.MainMenu);
}

public void draw() {


    background(0);

    //StateManager.cycle();


    /*
  if (stage==1) {
     image(startscreen, 0, 0, screenSizeX, screenSizeY);
     textAlign(CENTER);
     text("CUBE", 100, 150);
     text("Press any key to start game", 100, 170);
     if (keyPressed==true) {
     stage=2;
     }
     }
     
     if (stage==2) {
     
     
     if (millis() - interval > 20) {
     sendCommand(Command.QUATERNION, port);
     sendCommand(Command.YAWPITCHROLL, port);
     //sendCommand(Command.RAWACCEL, port);
     //sendCommand(Command.BATVOLTAGE, port);
     
     interval = millis();
     }
     
     if (counter-- <= 0) {
     pickedUp = false;
     counter = 0;
     }
     
     
     
     // black background
     background(0);
     
     // translate everything to the middle of the viewport
     
     // time = millis();
     // textSize(32);
     // text((time/1000)-8-15, 30, 120);//calibrating
     
     if (rand==1)
     {
     fill(1, 1, 1);
     rect(30, 20, 55, 55);
     } else if (rand==2)
     {
     fill(1, 0, 0);
     rect(30, 20, 55, 55);
     } else if (rand==3)
     {
     fill(0, 1, 0);
     rect(30, 20, 55, 55);
     } else if (rand==4)
     {
     fill(0, 0, 1);
     rect(30, 20, 55, 55);
     }
     //else if(rand==5)
     //{fill(0,1,1);rect(30,20,55,55);} else
     {
     fill(0.5, 0.5, 0.5);
     rect(30, 20, 55, 55);
     }
     
     stroke(1, 1, 1);
     fill(0, 0, 0);
     rect(width/2, height/4, 150, 50);
     textSize(32);
     fill(1, 1, 1);
     text("Start", width/2+36, height/4+33);
     
     
     if (pickedUp) {
     text("PICKEDUP!", 1500, 200);
     }
     text("aX = " + (short)accel.x + " aY = " + (short)accel.y + " aZ = " + (short)accel.z, 300, 50);
     text("wX = " + (short)worldAccel.x + " wY = " +(short)worldAccel.y + " wZ = " + (short)worldAccel.z, 300, 100);
     text("rX = " + realAccel.x + " rY = " + realAccel.y + " rZ = " + realAccel.z, 300, 200);
     text("zPos = " + zPos, 1700, 300);
     text("KOCKA", 1600, zPos);
     text("zSpeed = " + (int)(speedCur+8000), 1700, 400);
     text("BATTERY VOLTAGE = " + batVoltage, 1700, 800);
     text("yaw pitch = " + ypr[1] + " | " + ypr[2], 800, 400);
     switch(curSide) {
     case FRONT:
     text("FRONT", 200,800);
     break;
     
     case BACK:
     text("BACK", 200,800);
     break;
     
     case LEFT:
     text("LEFT", 200,800);
     break;
     
     case RIGHT:
     text("RIGHT", 200,800);
     break;
     
     case UP:
     text("UP", 200,800);
     break;
     
     case DOWN:
     text("DOWN", 200,800);
     break;
     
     }  
     
     if (mousePressed) {
     if (mouseX>x && mouseX <x+w && mouseY>y && mouseY <y+h) {
     println("Ganc");
     
     //do stuff
     }
     }
     
     pushMatrix();
     translate(width / 2, height / 2);
     
     // 3-step rotation from yaw/pitch/roll angles (gimbal lock!)
     // ...and other weirdness I haven't figured out yet
     //rotateY(-ypr[0]);
     //rotateZ(-ypr[1]);
     //rotateX(-ypr[2]);
     
     // toxiclibs direct angle/axis rotation from quaternion (NO gimbal lock!)
     // (axis order [1, 3, 2] and inversion [-1, +1, +1] is a consequence of
     // different coordinate system orientation assumptions between Processing
     // and InvenSense DMP)
     
     
     rotate(axis[0], -axis[1], axis[3], axis[2]);   
     
     beginShape(QUADS);
     
     fill(1, 1, 1); 
     vertex(-50, 50, 50);
     fill(1, 1, 1); 
     vertex( 50, 50, 50);
     fill(1, 1, 1); 
     vertex( 50, -50, 50);
     fill(1, 1, 1); 
     vertex(-50, -50, 50);
     
     fill(1, 0, 0); 
     vertex( 50, 50, 50);
     fill(1, 0, 0); 
     vertex( 50, 50, -50);
     fill(1, 0, 0); 
     vertex( 50, -50, -50);
     fill(1, 0, 0); 
     vertex( 50, -50, 50);
     
     fill(0, 1, 0); 
     vertex( 50, 50, -50);
     fill(0, 1, 0); 
     vertex(-50, 50, -50);
     fill(0, 1, 0); 
     vertex(-50, -50, -50);
     fill(0, 1, 0); 
     vertex( 50, -50, -50);
     
     fill(0, 0, 1); 
     vertex(-50, 50, -50);
     fill(0, 0, 1); 
     vertex(-50, 50, 50);
     fill(0, 0, 1); 
     vertex(-50, -50, 50);
     fill(0, 0, 1); 
     vertex(-50, -50, -50);
     
     fill(0, 1, 1); 
     vertex(-50, 50, -50);
     fill(0, 1, 1); 
     vertex( 50, 50, -50);
     fill(0, 1, 1); 
     vertex( 50, 50, 50);
     fill(0, 1, 1); 
     vertex(-50, 50, 50);
     
     fill(0.5, 0.5, 0.5); 
     vertex(-50, -50, -50);
     fill(0.5, 0.5, 0.5); 
     vertex( 50, -50, -50);
     fill(0.5, 0.5, 0.5); 
     vertex( 50, -50, 50);
     fill(0.5, 0.5, 0.5); 
     vertex(-50, -50, 50);
     
     endShape();
     
     popMatrix();
     
     
     //COMMAND HANDLING ------------------------------------------------------
     if (handleCommand(Command.QUATERNION)) {
     axis = cube.quat.toAxisAngle(); 
     cube.dmpGetGravity();
     // dmpGetYawPitchRoll(quat);
     
     }
     
     if(handleCommand(Command.YAWPITCHROLL)){
     cube.calculateCurrentSide();
     }
     
     //handleCommand(Command.BATVOLTAGE, port);
     
     //COMMAND HANDLING ------------------------------------------------------
     }
     
     */
}
public abstract class AbstractState extends Canvas {
  
  abstract public void setup(PGraphics pg);
  abstract public void update(PApplet p);
  abstract public void draw(PGraphics p);
  abstract public void destroy();
    
}
class CalibrateState extends AbstractState {


    //spremenljivke
    Button ok_b;
    Textlabel tl;
    boolean click_counter = false;


    public void setup(PGraphics p) {
        println("constructed mainmenu");

        gui.setFont(new ControlFont(calibriPFont, 16));
    
        tl = gui.addTextlabel("napis")
            .setText("To Calibrate The Cube, Place It On A Flat Surface With White Side Facing You, Then Click Button: 'Calibrate'")
            .setPosition(screenSizeX/12, screenSizeY/1.5f);



        ok_b = gui.addButton("Calibrate")
            .setValue(10)
            .setPosition(screenSizeX/3, screenSizeY/1.2f)
            .setSize(200, 30)
            .addListener(new ControlListener () {
            public void controlEvent(ControlEvent event) {
                click_counter = true;
            }
        }
        );
        
        
        
    }

int quick = millis();

    public void update(PApplet p) {
        //update stuff with mouse control possibilities and everything
        //if(millis() > 2000) StateManager.changeState(State.GameState);
        
        if(millis() > quick + 50){
            cube.sendCommand(Command.YAWPITCHROLL);  
        }
        
        if(cube.handleCommand(Command.YAWPITCHROLL)){
            println("yaw = " + cube.ypr[0] + " pitch = " + cube.ypr[1] + " roll = " + cube.ypr[2]);
        }
        
        if (click_counter)
        {
            //calibration part
            cube.sendCommand(Command.YAWPITCHROLL);
            while(!cube.handleCommand(Command.YAWPITCHROLL));
            offsetYaw = cube.ypr[0];
            //
            
            StateManager.changeState(State.GameState);
        }
    }

    public void draw(PGraphics g) {
        //rendering on display with draw support (use g prefix,  g.fill() etc, etc)

        g.background(0);
        g.fill(255, 255, 255);
        g.rect(screenSizeX/3, screenSizeY/5, 200, 200);
        g.textSize(20);
        g.fill(255, 255, 255);
    }


    public void destroy() {
        println("ended life of mainmenu");
    }
}
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
            timersLabel.setText("Starts in ... " + (int)((countDownTimer - millis()) / 1000.0f));
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
                 axis[1] = 0.1f;
                 axis[2] = 0.1f;
                 axis[3] = 0.1f;
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
            p.rect(screenSizeX/2 - (rectLen/2.0f), 500, rectLen, 30);
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
        
        gui.setFont(new ControlFont(calibriPFont, 14));

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
        
        
        gui.addTextlabel("logo")
        .setText("Therapeutic Cube")
        .setValue(1)
        .setFont(new ControlFont(arielPFont, 64))
        .setPosition(screenSizeX/2 - 250, 45);

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
            .setItemHeight(25)
            .setBarHeight(25)
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
                        cube.sendCommand(Command.HELLO);
                        
                        /* LITTLE PROBLEMS HERE
                        while (!cube.handleCommand(Command.HELLO)) {
                            if (millis() >= time+1000) {
                                throw new NotCubeException("Not a cube");
                            }
                        }*/
                        
                        connected = true;
                        connectionStatus.setText("Connected!");
                        start.setCaptionLabel(" START \n "+ddm.getItem(select).get("name").toString() + "  ");
                       
                    }
                    /*
                    catch(NotCubeException ex) {
                        serialPort.stop();
                         serialPort = null;
                        connectionStatus.setText(ex.getMessage());
                    }*/
                    catch(Exception x) {
                        serialPort = null;
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

/*
  CUBE COMMANDS
 */
public enum Command { 
    NOP (0), 
        HELLO(1), 
        BATPERCENT(32), 
        BATVOLTAGE (33), 
        QUATERNION (64), 
        EULER (65), 
        YAWPITCHROLL (66), 
        REALACCEL (67), 
        WORLDACCEL (68), 
        TEAPOTPACKET (69), 
        DMPPACKET (70), 
        RAWACCEL (71), 
        TURNOFF (128);

    private int value; 
    private Command(int value) { 
        this.value = value;
    }
}
/*
  CUBE COMMANDS
 */


/*
  CUBE SIDES
 */
public enum Side {
    UP, DOWN, LEFT, RIGHT, BACK, FRONT, UNDEFINED;
}

public Side getSideByValue(int value) {
    switch(value) {
    case 0: 
        return Side.UP;
    case 1: 
        return Side.DOWN;
    case 2: 
        return Side.LEFT;
    case 3: 
        return Side.RIGHT;
    case 4: 
        return Side.BACK;
    case 5: 
        return Side.FRONT;
    case 6: 
        return Side.UNDEFINED;
    }
    return Side.UNDEFINED;
}

public int getSideColor(Side s) {
    switch(s) {
    case UP: 
        return color(255, 88, 0, 120);
    case DOWN: 
        return color(254, 212, 3, 120);
    case LEFT: 
        return color(0, 155, 72, 120);
    case RIGHT: 
        return color(255, 255, 255, 120);
    case BACK: 
        return color(1, 70, 173, 120);
    case FRONT: 
        return color(183, 18, 52, 120);
    case UNDEFINED: 
        return color(128, 128, 128, 120);
    }  
    return color(128, 128, 128, 255);
}

public int getSideColorBright(Side s) {
    switch(s) {
    case UP: 
        return color(255, 118, 0);
    case DOWN: 
        return color(255, 242, 33);
    case LEFT: 
        return color(30, 185, 102);
    case RIGHT: 
        return color(225, 225, 225);
    case BACK: 
        return color(31, 100, 203);
    case FRONT: 
        return color(213, 48, 82);
    case UNDEFINED: 
        return color(128, 128, 128);
    }  
    return color(128, 128, 128);
}

public String getSideName(Side s) {
    switch(s) {
    case UP: 
        return "ORANGE";
    case DOWN: 
        return "YELLOW";
    case LEFT: 
        return "GREEN";
    case RIGHT: 
        return "WHITE";
    case BACK: 
        return "BLUE";
    case FRONT: 
        return "RED";
    case UNDEFINED: 
        return "UNDEFINED";
    }
    return "UNDEFINED";
}

/*
  CUBE SIDES
 */



class QiBT_aCube {

    float[] q = new float[4];
    Quaternion quat = new Quaternion(1, 0, 0, 0);
    byte[] DMPpacket = new byte[20];
    PVector accel = new PVector(0, 0, 0);
    PVector realAccel = new PVector(0, 0, 0);
    PVector worldAccel = new PVector(0, 0, 0);
    float[] ypr = new float[3];
    float[] gravity = new float[3];

    private Side curSide = Side.UNDEFINED;

    public QiBT_aCube() {
    }

    public void dmpGetQuaternion(byte[] packet) {
        q[0] = ((((int)packet[0]) << 8) | packet[1]) / 16384.0f;
        q[1] = ((((int)packet[2]) << 8) | packet[3]) / 16384.0f;
        q[2] = ((((int)packet[4]) << 8) | packet[5]) / 16384.0f;
        q[3] = ((((int)packet[6]) << 8) | packet[7]) / 16384.0f;
        for (int i = 0; i < 4; i++) if (q[i] >= 2.0f) q[i] = -4 + q[i];
        quat.set(q[0], q[1], q[2], q[3]);
    }

    public void dmpGetGravity() {
        gravity[0] = 2 * (quat.x * quat.z - quat.w* quat.y);
        gravity[1] = 2 * (quat.w * quat.x + quat.y * quat.z);
        gravity[2] = quat.w * quat.w - quat.x * quat.x - quat.y * quat.y + quat.z * quat.z;
    }

    public void dmpGetAccel(byte[] packet) {
        accel.x = ((((int)packet[8]) << 8) | packet[9]);
        accel.y = ((((int)packet[10]) << 8) | packet[11]);
        accel.z = ((((int)packet[12]) << 8) | packet[13]);
    }

    public void dmpGetLinearAccel() {
        // get rid of the gravity component (+1g = +8192 in standard DMP FIFO packet, sensitivity is 2g)
        realAccel.x = accel.x - gravity[0] * 8192;
        realAccel.y = accel.y - gravity[1] * 8192;
        realAccel.z = accel.z - gravity[2] * 8192;
    }

    public void dmpGetLinearAccelInWorld() {
        worldAccel = realAccel;
        worldAccel = rotateVector(worldAccel, quat);
    }


    public void dmpGetYawPitchRoll(Quaternion q) {
        // yaw: (about Z axis)
        ypr[0] = atan2(2*q.x*q.y - 2*q.w*q.z, 2*q.w*q.w + 2*q.x*q.x - 1);

        // pitch: (nose up/down, about Y axis)
        ypr[1] = atan2(gravity[0], sqrt(gravity[1] * gravity[1] + gravity[2] * gravity[2]));

        // roll: (tilt left/right, about X axis)
        ypr[2] = atan2(gravity[1], gravity[2]);
        if (gravity[2] < 0) {
            if (ypr[1] > 0) {
                ypr[1] = PI - ypr[1];
            } else { 
                ypr[1] = -PI - ypr[1];
            }
        }
    }


    public boolean getCubePickedUp() {

        if (worldAccel.z > 300) {
            float posOffset = worldAccel.z / 3.0f;
            if (worldAccel.x < posOffset && worldAccel.x > -posOffset) {
                if (worldAccel.y < posOffset && worldAccel.y > -posOffset) {
                    return true;
                }
            }
        }
        return false;
    }

    public Side getCurrentSide() {
        return curSide;
    }

    public boolean isMoving() {
        if (abs(worldAccel.x) < 150 && abs(worldAccel.y) < 150 && abs(worldAccel.z) < 500) return false;
        return true;
    }

    public Quaternion mult (Quaternion a, Quaternion q) {
        float w = a.w*q.w - (a.x*q.x + a.y*q.y + a.z*q.z);
        float x = a.w*q.x + q.w*a.x + a.y*q.z - a.z*q.y;
        float y = a.w*q.y + q.w*a.y + a.z*q.x - a.x*q.z;
        float z = a.w*q.z + q.w*a.z + a.x*q.y - a.y*q.x;

        Quaternion tmp = new Quaternion(w, x, y, z);
        return tmp;
    }


    public PVector rotateVector(PVector v, Quaternion q) {
        Quaternion p = new Quaternion(0, v.x, v.y, v.z);
        p = mult(q, p);
        p = mult(p, q.getConjugate());

        return new PVector(p.x, p.y, p.z);
    }


    public void sendCommand(Command cmd) {
        byte b = (byte)cmd.value;
        serialPort.write(b);
    }

    public boolean handleCommand(Command command) {

        try {

            Command cmd;

            byte[] tmp = new byte[4];

            if (serialBuffer.size() <= 0) return false;

            int c = 0;

            try {
                c = serialBuffer.element();
            }
            catch(NoSuchElementException ex) {
                return false;
            }


            int i = 0;
            for (i = 0; i<Command.values().length; i++) {
                if (c == Command.values()[i].value) {
                    break;
                }
            }

            try {
                cmd = Command.values()[i];
            }
            catch(Exception ex) {
                println("SKIPPING EXCEPTION, serialBuffer size = " + serialBuffer.size() + " clearing buffer now");
                serialBuffer.clear();
                return false;
            }

            if (cmd != command) return false;

            boolean feedback = false;
            switch(cmd) {
            case NOP:
                feedback = false;
                break;

            case HELLO:
            case BATVOLTAGE:
                if (serialBuffer.size() > 4) feedback = true;
                break;

            case EULER:
            case YAWPITCHROLL:
                if (serialBuffer.size() > 12) feedback = true;
                break;

            case REALACCEL:
            case WORLDACCEL:
                if (serialBuffer.size() > 6) feedback = true;
                break;

            case BATPERCENT:
                if (serialBuffer.size() > 1) feedback = true;
                break;

            case QUATERNION:
                if (serialBuffer.size() > 16) feedback = true;
                break;

            case TEAPOTPACKET:
                if (serialBuffer.size() > 14) feedback = true;
                break;

            case DMPPACKET:
                if (serialBuffer.size() > 20) feedback = true;
                break;

            case RAWACCEL:
                if (serialBuffer.size() > 6) feedback = true;
                break;

            case TURNOFF:
                break;
            }

            if (!feedback) return feedback;
            if (cmd == command) serialBuffer.poll();

            switch(cmd) {
            case NOP:
                break;
            case HELLO:

                while (serialBuffer.size() > 0) {
                    byte ch = (byte)(serialBuffer.poll());
                    print((char)ch); //naj bi na konzolo izpisalo Hi!
                }
                break;

            case BATPERCENT:
                int batteryPercent = serialBuffer.poll(); //saves the battery percentage into a variable
                print("Battery percent = ");
                println(batteryPercent);
                break;

            case BATVOLTAGE:
                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                float batteryVoltage = get4bytesFloat(tmp, 0); 
                print("Battery voltage = ");
                println(batteryVoltage);
                break;

            case QUATERNION:

                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                float w = get4bytesFloat(tmp, 0);

                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                float x = get4bytesFloat(tmp, 0);
                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                float y = get4bytesFloat(tmp, 0);
                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                float z = get4bytesFloat(tmp, 0);
                quat.set(w, x, y, z);

                break;


                /*
      case EULER:
                 float e0 = bytesToFloat(Serial.read(), Serial.read(), Serial.read(), Serial.read());
                 float e1 = bytesToFloat(Serial.read(), Serial.read(), Serial.read(), Serial.read());
                 float e2 = bytesToFloat(Serial.read(), Serial.read(), Serial.read(), Serial.read());
                 break;
                 
                 */

            case YAWPITCHROLL:
                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                ypr[0] = get4bytesFloat(tmp, 0);
                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                ypr[1] = get4bytesFloat(tmp, 0);
                for (int ii = 0; ii<4; ii++) {
                    tmp[ii] = (byte)((int) serialBuffer.poll());
                }
                ypr[2] = get4bytesFloat(tmp, 0);
                break;


            case REALACCEL:
                int raccel;
                raccel = serialBuffer.poll() & 0xFF;
                raccel |= ((int)serialBuffer.poll()) << 8;
                realAccel.x = raccel;

                raccel = serialBuffer.poll() & 0xFF;
                raccel |= ((int)serialBuffer.poll()) << 8;
                realAccel.y = raccel;

                raccel = serialBuffer.poll() & 0xFF;
                raccel |= ((int)serialBuffer.poll()) << 8;
                realAccel.z = raccel;
                break;


            case WORLDACCEL:
                int waccel;
                waccel = serialBuffer.poll() & 0xFF;
                waccel |= ((int)serialBuffer.poll()) << 8;
                worldAccel.x = waccel;

                waccel = serialBuffer.poll() & 0xFF;
                waccel |= ((int)serialBuffer.poll()) << 8;
                worldAccel.y = waccel;

                waccel = serialBuffer.poll() & 0xFF;
                waccel |= ((int)serialBuffer.poll()) << 8;
                worldAccel.z = waccel;
                break;

            case DMPPACKET:
                for (int ii = 0; ii<20; ii++) {
                    DMPpacket[ii] = serialBuffer.poll();
                }    
                break;

            case RAWACCEL:  
                int rawaccel;
                rawaccel = serialBuffer.poll() & 0xFF;
                rawaccel |= ((int)serialBuffer.poll()) << 8;
                accel.x = rawaccel;

                rawaccel = serialBuffer.poll() & 0xFF;
                rawaccel |= ((int)serialBuffer.poll()) << 8;
                accel.y = rawaccel;

                rawaccel = serialBuffer.poll() & 0xFF;
                rawaccel |= ((int)serialBuffer.poll()) << 8;
                accel.z = rawaccel;
                break;

            default:
                break;
            }
        }
        catch(Exception ex) {
            println("SKIPPING EXCEPTION, serialBuffer size = " + serialBuffer.size() + " clearing buffer now");
            serialBuffer.clear();
        }

        return true;
    }


    final float OFFSET = 0.20533f;

    public void calculateCurrentSide() {
        curSide = Side.UNDEFINED;

        if ((ypr[1] >= 0 && ypr[1] <= OFFSET) || (ypr[1] <= 0 && ypr[1] >= -OFFSET)) {

            if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
                curSide = Side.DOWN;
            } else if ((ypr[2] >= 1.5708f && ypr[2] <= 1.5708f + OFFSET) || (ypr[2] <= 1.5708f && ypr[2] >= 1.5708f - OFFSET)) {
                curSide = Side.RIGHT;
            } else if ((ypr[2] >= -1.5708f && ypr[2] <= -1.5708f + OFFSET) || (ypr[2] <= -1.5708f && ypr[2] >= -1.5708f - OFFSET)) {
                curSide = Side.LEFT;
            } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
                curSide = Side.UP;
            }
        } else if ((ypr[1] >= 1.5708f && ypr[1] <= 1.5708f + OFFSET) || (ypr[1] <= 1.5708f && ypr[1] >= 1.5708f-OFFSET)) {

            if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
                curSide = Side.BACK;
            } else if ((ypr[2] >= 1.5708f && ypr[2] <= 1.5708f + OFFSET) || (ypr[2] <= 1.5708f && ypr[2] >= 1.5708f - OFFSET)) {
                curSide = Side.RIGHT;
            } else if ((ypr[2] >= -1.5708f && ypr[2] <= -1.5708f + OFFSET) || (ypr[2] <= -1.5708f && ypr[2] >= -1.5708f - OFFSET)) {
                curSide = Side.LEFT;
            } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
                curSide = Side.FRONT;
            }
        } else if ((ypr[1] >= -1.5708f && ypr[1] <= -1.5708f+OFFSET) || (ypr[1] <= -1.5708f && ypr[1] >= -1.5708f-OFFSET)) {

            if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
                curSide = Side.FRONT;
            } else if ((ypr[2] >= 1.5708f && ypr[2] <= 1.5708f + OFFSET) || (ypr[2] <= 1.5708f && ypr[2] >= 1.5708f - OFFSET)) {
                curSide = Side.RIGHT;
            } else if ((ypr[2] >= -1.5708f && ypr[2] <= -1.5708f + OFFSET) || (ypr[2] <= -1.5708f && ypr[2] >= -1.5708f - OFFSET)) {
                curSide = Side.LEFT;
            } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
                curSide = Side.BACK;
            }
        } else if ((ypr[1] >= PI && ypr[1] <= PI+OFFSET) || (ypr[1] <= PI && ypr[1] >= PI-OFFSET)) {

            if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
                curSide = Side.UP;
            } else if ((ypr[2] >= 1.5708f && ypr[2] <= 1.5708f + OFFSET) || (ypr[2] <= 1.5708f && ypr[2] >= 1.5708f - OFFSET)) {
                curSide = Side.RIGHT;
            } else if ((ypr[2] >= -1.5708f && ypr[2] <= -1.5708f + OFFSET) || (ypr[2] <= -1.5708f && ypr[2] >= -1.5708f - OFFSET)) {
                curSide = Side.LEFT;
            } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
                curSide = Side.DOWN;
            }
        }


        if (curSide == Side.DOWN) {
            if (gravity[2] < 0) {
                curSide = Side.UP;
            }
        }
    }


    public float get4bytesFloat(byte[] data, int offset) { 
        String hexint=hex(data[offset+3])+hex(data[offset+2])+hex(data[offset+1])+hex(data[offset]); 
        return Float.intBitsToFloat(unhex(hexint));
    } 

    public float bytesToFloat(byte b0, byte b1, byte b2, byte b3) 
    { 
        byte[] d = {b0, b1, b2, b3};
        return get4bytesFloat(d, 0);
    }
}
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



public enum State {
    MainMenu(0),
    CalibrateState(1),
    GameState(2),
    ResultState(3);

    private int value; 
    private State(int value) { 
      this.value = value;
    }
   
}

static public class StateManager {
       
  static private Stack<AbstractState> states = new Stack();
      
  static public void pushState(State st){
    AbstractState newState = null;  
    switch(st){
          case MainMenu:
          newState = new Main().new MainMenu();
          break;
          
          case CalibrateState:
          newState = new Main().new CalibrateState();
          break;
          
          case GameState:
          newState = new Main().new GameState();
          break;
          
          case ResultState:
          newState = new Main().new ResultState();
          break;
          
          
    }
    if(newState == null) return;
    gui.addCanvas(newState);
    states.push(newState);  
  }
  
static public void popState(){
     states.peek().destroy();
     for(ControllerInterface tmp : gui.getAll()) tmp.remove();
     gui.removeCanvas(states.peek());
     states.pop(); 
  }
  
 static public void changeState(State st){
    while(!states.empty()) popState();
    pushState(st);
  }
     
  
}
    public void settings() {  size(800, 600, P3D);  smooth(); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "Main" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
