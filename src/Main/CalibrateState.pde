class CalibrateState extends AbstractState{
   
  //spremenljivke
  
  //
  
  public void setup(PGraphics p){
     println("constructed mainmenu"); 
  }
    
   
   public void update(PApplet p){
     //update stuff with mouse control possibilities and everything
     //if(millis() > 2000) StateManager.changeState(State.GameState);
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