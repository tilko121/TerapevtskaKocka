class CalibrateState extends AbstractState{
   
  
  //spremenljivke
  Button ok_b;
  Textlabel tl;
  boolean click_counter = false;
  
  
  public void setup(PGraphics p){
     println("constructed mainmenu");
     
      tl = gui.addTextlabel("napis")
       .setText("Postavite tako, da je rdeča stran obrnjena proti vam")
       .setPosition(screenSizeX/3.15, screenSizeY/1.5);


    ok_b = gui.addButton("tipka")
      .setValue(10)
      .setPosition(screenSizeX/3 ,screenSizeY/1.2)
      .setSize(200, 30)
      .addListener(new ControlListener () {
      public void controlEvent(ControlEvent event) {
        click_counter = true;
      }
    });
  }
    
   
   public void update(PApplet p){
     //update stuff with mouse control possibilities and everything
     //if(millis() > 2000) StateManager.changeState(State.GameState);
     if(click_counter)
     {StateManager.changeState(State.GameState);}
     
     
   }
   
   public void draw(PGraphics g){
     //rendering on display with draw support (use g prefix,  g.fill() etc, etc)
     
    g.background(0);
    g.fill(255,0, 0);
    g.rect(screenSizeX/3, screenSizeY/5, 200, 200);
    g.textSize(20);
    g.fill(255,255,255);
    
 
  }
   
   
  public void destroy(){
     println("ended life of mainmenu"); 
  }
       
    
  
  
}