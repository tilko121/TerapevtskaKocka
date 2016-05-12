public abstract class AbstractState extends Canvas {
  
  abstract public void setup(PGraphics pg);
  abstract public void update(PApplet p);
  abstract public void draw(PGraphics p);
  abstract public void destroy();
    
}