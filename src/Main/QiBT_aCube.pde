
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
/*
  CUBE SIDES
 */



class QiBT_aCube {
  
  public Serial port;
  float[] q = new float[4];
  Quaternion quat = new Quaternion(1, 0, 0, 0);
  byte[] DMPpacket = new byte[20];
  PVector accel = new PVector(0, 0, 0);
  PVector realAccel = new PVector(0, 0, 0);
  PVector worldAccel = new PVector(0, 0, 0);
  float[] ypr = new float[3];
  float[] gravity = new float[3];

  Side curSide = Side.UNDEFINED;

  Queue<Byte> serialBuffer = new LinkedList<Byte>();

  public QiBT_aCube() {
  }

  void serialEvent(Serial p) {
    while (p.available() > 0) serialBuffer.add((byte)p.readChar());
  }


  void dmpGetQuaternion(byte[] packet) {
    q[0] = ((((int)packet[0]) << 8) | packet[1]) / 16384.0f;
    q[1] = ((((int)packet[2]) << 8) | packet[3]) / 16384.0f;
    q[2] = ((((int)packet[4]) << 8) | packet[5]) / 16384.0f;
    q[3] = ((((int)packet[6]) << 8) | packet[7]) / 16384.0f;
    for (int i = 0; i < 4; i++) if (q[i] >= 2.0) q[i] = -4 + q[i];
    quat.set(q[0], q[1], q[2], q[3]);
  }

  void dmpGetGravity() {
    gravity[0] = 2 * (quat.x * quat.z - quat.w* quat.y);
    gravity[1] = 2 * (quat.w * quat.x + quat.y * quat.z);
    gravity[2] = quat.w * quat.w - quat.x * quat.x - quat.y * quat.y + quat.z * quat.z;
  }

  void dmpGetAccel(byte[] packet) {
    accel.x = ((((int)packet[8]) << 8) | packet[9]);
    accel.y = ((((int)packet[10]) << 8) | packet[11]);
    accel.z = ((((int)packet[12]) << 8) | packet[13]);
  }

  void dmpGetLinearAccel() {
    // get rid of the gravity component (+1g = +8192 in standard DMP FIFO packet, sensitivity is 2g)
    realAccel.x = accel.x - gravity[0] * 8192;
    realAccel.y = accel.y - gravity[1] * 8192;
    realAccel.z = accel.z - gravity[2] * 8192;
  }

  void dmpGetLinearAccelInWorld() {
    worldAccel = realAccel;
    worldAccel = rotateVector(worldAccel, quat);
  }


  void dmpGetYawPitchRoll(Quaternion q) {
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


  boolean getCubePickedUp() {

    if (worldAccel.z > 300) {
      float posOffset = worldAccel.z / 3.0;
      if (worldAccel.x < posOffset && worldAccel.x > -posOffset) {
        if (worldAccel.y < posOffset && worldAccel.y > -posOffset) {
          return true;
        }
      }
    }
    return false;
  }


  public Quaternion mult (Quaternion a, Quaternion q) {
    float w = a.w*q.w - (a.x*q.x + a.y*q.y + a.z*q.z);
    float x = a.w*q.x + q.w*a.x + a.y*q.z - a.z*q.y;
    float y = a.w*q.y + q.w*a.y + a.z*q.x - a.x*q.z;
    float z = a.w*q.z + q.w*a.z + a.x*q.y - a.y*q.x;

    Quaternion tmp = new Quaternion(w, x, y, z);
    return tmp;
  }


  PVector rotateVector(PVector v, Quaternion q) {
    Quaternion p = new Quaternion(0, v.x, v.y, v.z);
    p = mult(q, p);
    p = mult(p, q.getConjugate());

    return new PVector(p.x, p.y, p.z);
  }


  void sendCommand(Command cmd) {
    byte b = (byte)cmd.value;
    port.write(b);
  }

  boolean handleCommand(Command command) {

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

    return true;
  }


  final float OFFSET = 0.20533;

  public void calculateCurrentSide() {
    curSide = Side.UNDEFINED;

    if ((ypr[1] >= 0 && ypr[1] <= OFFSET) || (ypr[1] <= 0 && ypr[1] >= -OFFSET)) {

      if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
        curSide = Side.DOWN;
      } else if ((ypr[2] >= 1.5708 && ypr[2] <= 1.5708 + OFFSET) || (ypr[2] <= 1.5708 && ypr[2] >= 1.5708 - OFFSET)) {
        curSide = Side.RIGHT;
      } else if ((ypr[2] >= -1.5708 && ypr[2] <= -1.5708 + OFFSET) || (ypr[2] <= -1.5708 && ypr[2] >= -1.5708 - OFFSET)) {
        curSide = Side.LEFT;
      } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
        curSide = Side.UP;
      }
    } else if ((ypr[1] >= 1.5708 && ypr[1] <= 1.5708 + OFFSET) || (ypr[1] <= 1.5708 && ypr[1] >= 1.5708-OFFSET)) {

      if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
        curSide = Side.BACK;
      } else if ((ypr[2] >= 1.5708 && ypr[2] <= 1.5708 + OFFSET) || (ypr[2] <= 1.5708 && ypr[2] >= 1.5708 - OFFSET)) {
        curSide = Side.RIGHT;
      } else if ((ypr[2] >= -1.5708 && ypr[2] <= -1.5708 + OFFSET) || (ypr[2] <= -1.5708 && ypr[2] >= -1.5708 - OFFSET)) {
        curSide = Side.LEFT;
      } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
        curSide = Side.FRONT;
      }
    } else if ((ypr[1] >= -1.5708 && ypr[1] <= -1.5708+OFFSET) || (ypr[1] <= -1.5708 && ypr[1] >= -1.5708-OFFSET)) {

      if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
        curSide = Side.FRONT;
      } else if ((ypr[2] >= 1.5708 && ypr[2] <= 1.5708 + OFFSET) || (ypr[2] <= 1.5708 && ypr[2] >= 1.5708 - OFFSET)) {
        curSide = Side.RIGHT;
      } else if ((ypr[2] >= -1.5708 && ypr[2] <= -1.5708 + OFFSET) || (ypr[2] <= -1.5708 && ypr[2] >= -1.5708 - OFFSET)) {
        curSide = Side.LEFT;
      } else if ((ypr[2] >= PI && ypr[2] <= PI + OFFSET) || (ypr[2] <= PI && ypr[2] >= PI - OFFSET)) {
        curSide = Side.BACK;
      }
    } else if ((ypr[1] >= PI && ypr[1] <= PI+OFFSET) || (ypr[1] <= PI && ypr[1] >= PI-OFFSET)) {

      if ((ypr[2] >= 0 && ypr[2] <= OFFSET) || (ypr[2] <= 0 && ypr[2] >= -OFFSET)) {
        curSide = Side.UP;
      } else if ((ypr[2] >= 1.5708 && ypr[2] <= 1.5708 + OFFSET) || (ypr[2] <= 1.5708 && ypr[2] >= 1.5708 - OFFSET)) {
        curSide = Side.RIGHT;
      } else if ((ypr[2] >= -1.5708 && ypr[2] <= -1.5708 + OFFSET) || (ypr[2] <= -1.5708 && ypr[2] >= -1.5708 - OFFSET)) {
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


  float get4bytesFloat(byte[] data, int offset) { 
    String hexint=hex(data[offset+3])+hex(data[offset+2])+hex(data[offset+1])+hex(data[offset]); 
    return Float.intBitsToFloat(unhex(hexint));
  } 

  float bytesToFloat(byte b0, byte b1, byte b2, byte b3) 
  { 
    byte[] d = {b0, b1, b2, b3};
    return get4bytesFloat(d, 0);
  }
}