class ResultState extends AbstractState{
   
  //spremenljivke
  
  Textlabel title, timer, score; 
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
     
   title = gui.addTextlabel("TitleLable")
          .setPosition(screenSizeX / 2 - 26, screenSizeY / 2 - 200)
          .setText("FINISHED")
          ;
      
   timer = gui.addTextlabel("TimerLable")
          .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 - 150)
          .setText("Your total time: " + random(30) + " seconds")
          .setSize(50,30)
          ;
     
   score = gui.addTextlabel("ScoreLable")
          .setPosition(screenSizeX / 2 - 100, screenSizeY / 2 - 100)
          .setText("You finished: " + (int)random(10) + " out of 10" )
          .setSize(50,30)
          ;
     
     
     
     
  }
    
   
   public void update(PApplet p){
     //update stuff with mouse control possibilities and everything
     //if(millis() > 2000) StateManager.changeState(State.GameState);
      //title.setPosition(screenSizeX / 2 - ,screenSizeY / 2 - title.getSize());
      
      
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
     
     
     
   }
   
  public void destroy(){
     println("ended life of mainmenu"); 
  }
       
    
  
}