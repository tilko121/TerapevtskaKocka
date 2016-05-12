import java.util.*;

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