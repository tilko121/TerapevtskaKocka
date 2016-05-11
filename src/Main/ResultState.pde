class ResultState extends AbstractState{
   
  //spremenljivke
  boolean retry=false;
  boolean toStart=false;
  //
  
  public void setup(PGraphics p){
     println("constructed mainmenu"); 
     gui.addButton("Retry")
     .setValue(10)
     .setPosition(screenSizeX / 2 - 100 ,screenSizeY / 2 - 30)
     .setSize(200,30)
     .addListener(new ControlListener () {
      public void controlEvent(ControlEvent event) {
        retry = true;
      }
     });
     
    gui.addButton("Main Menu")
    .setValue(10)
    .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 + 30 )
    .setSize(200,30)
    .addListener(new ControlListener () {
      public void controlEvent(ControlEvent event){
        toStart = true;
      }
     });
     
     
     
  }
    
   
   public void update(PApplet p){
     //update stuff with mouse control possibilities and everything
     //if(millis() > 2000) StateManager.changeState(State.GameState);
      if (retry) {
      StateManager.changeState(State.GameState);
    }
    
    if (toStart) {
      StateManager.changeState(State.MainMenu);
      stop();
    }
     
     
   }
   
   public void draw(PGraphics g){
     //rendering on display with draw support (use g prefix,  g.fill() etc, etc)
     
     g.fill(1, 1, 1);
     g.rect(30, 20, 55, 55);
     
   }
   
  public void destroy(){
     println("ended life of mainmenu"); 
  }
       
    
  
}