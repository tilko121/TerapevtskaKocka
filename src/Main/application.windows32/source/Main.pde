
import processing.serial.*;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;
import java.util.*;
import java.io.IOException;
import java.util.Vector;
import javax.swing.SwingUtilities;

import controlP5.*;


ToxiclibsSupport gfx;
static ControlP5 gui;
Main main = this;
final static int screenSizeX = 800, screenSizeY = 600;


static PFont arielPFont;
static PFont timesNewRomanPFont;
static PFont calibriPFont;

static int numSolvedTasks = 0;
static int totalTime = 0;

static float offsetYaw = 0.0;


QiBT_aCube cube = new QiBT_aCube();


static Serial serialPort;
static Queue<Byte> serialBuffer = new LinkedList<Byte>();
public void serialEvent(Serial p) {
    while (p.available() > 0) serialBuffer.add((byte)p.readChar());
}


void stop() {
    gui.dispose();
    if (serialPort != null) serialPort.stop();
    System.exit(0);
} 


void setup() {
    arielPFont = createFont("Ariel", 64);
    timesNewRomanPFont = createFont("Times New Roman", 22);
    calibriPFont = createFont("Calibri", 14);
        
    size(800, 600, P3D);
    noStroke();
    gui = new ControlP5(this);
    
    lights();
    smooth();
    colorMode(RGB, 1);

    StateManager.pushState(State.MainMenu);
}

void draw() {


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