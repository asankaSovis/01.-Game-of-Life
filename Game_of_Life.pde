/* CONWAY's GAME OF LIFE---------------------------------------------------------

Game of Life is a cellular automaton proposed by John Horton Conway. It is known as a
zero player game. This means that the current state of the system depend on the previous
state of the system, not on any other type of input.
The Game of Life is a representation of how a simple set of rules can create an
unpredictable behaiour in a virtual simulation.
Find out more in the Wikipedia Article: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Algorithms
Check out my blog post: https://asanka-sovis.blogspot.com/2021/11/01-conways-game-of-life-coding-life.html
Coded by Asanka Akash Sovis

________________
|    |    |    |    For each cell, the neighbouring 8 cells are compared. Thus it is
|    |    |    |    important that we have a way to check corner cells as well, which
________________    have less than 8 neighbouring cells. We can do this in the rule
|    |    |    |    code, but this can get quite complicated. Instead, we will create
|    | XX |    |    an extra perimeter of cells around the actual cell grid so that
________________    we have 8 neighbouring cells for every cell we consider.
|    |    |    |    This does not affect the code.
|    |    |    |
________________
--------------------------------------------------------------------------------- */

// Global Variables
int cellCount = 800; // Number of cells to be implemented (Make sure that it's a perfect square)
int textSize = 15; // Size of text elements

int cellsinRow = int(sqrt(cellCount)); // Getting how many rows for the cells
boolean cells[][] = new boolean[cellsinRow + 2][cellsinRow + 2]; // Creating a 2D array of cells
// Note: Adds 2 extra rows and columns to create an extra perimeter
int cellSize = 0; // Size of a cell (Calculated after canvas is created)
boolean work = false; // Pause/Play the simulation
int generation = 0; // Current generation

color colourPallette[] = {#FFFFFF, #61DB68}; // Colour pallette of cells
// White - Dead, Green - Alive

void setup() {
  size(700, 760); // Size of the canvas
  // Change this to any size you prefer
  // Note: Make sure Length < Breadth
  frameRate(5); // Frame rate of the simulation
  // Change this to speed/slow the simulation
  cellSize = (width - 1) / cellsinRow; // Calculating the cell size
  stroke(#000000); // Setting a black border for each cell
  refreshScreen();
}

void draw() {
  // We check if we're allowed to run the simulation and if so, run it.
  if (work) {
    refreshScreen();
    generation++;
    //saveFrame("Output\\GOL-" + frameCount + ".png"); // Saves the current frame. Comment if you don't need
  }
}

void refreshScreen() {
  // This function will refresh the simulation and perform the rules on the cells
  // Accepts nothing and return nothing
  textSize(textSize);
  background(#FFFFFF);
  
  // We create a temporary cell grid to store the new cell structure after applying
  // the rules. This is because if we do modifications on a cell in the original cell grid
  // we can end up disrupting the rules for the next cell.
  boolean newCells[][] = new boolean[cellsinRow + 2][cellsinRow + 2];
  for (int i = 1; i <= cellsinRow; i++) {
      for (int j = 1; j <= cellsinRow; j++) {
        // Each cell is checked using the nested loops for row and column
        fill(colourPallette[int(cells[i][j])]); // Set the fill colour according to the state of the cell
        rect((cellsinRow / 2) + ((i - 1) * cellSize), (cellsinRow / 2) + ((j - 1) * cellSize), cellSize, cellSize, 3);
        // Drawing the rectangle for the cell
        
        // If we're set to simulate, we also do the rule checking
        if (work) {
          // We use ruleCheck function to check what we must do to this cell according to the rules
          // 0 - Do nothing, 1 - Kill, 2 - Revive
          // Then we do what needs to be done to the new cell grid
          int returnVal = ruleCheck(i, j);
          if (returnVal > 0) {
            newCells[i][j] = boolean(returnVal - 1);
          } else {
            newCells[i][j] = cells[i][j];
          }
        }
      }
  }
  
  // Adding certain text elements to the simulation
  fill(#000000);
  textAlign(LEFT);
  if (work) {
    cells = newCells; // Setting the new cell grid to the original if we're supposed to simulate
    text("Status: Running", 20, width + 40);
  } else {
    text("Status: Paused", 20,  width + 40);
  }
  text("Generation: " + generation, 20,  width + 20);
  textAlign(CENTER);
  textSize(textSize * 2);
  fill(colourPallette[1]);
  text("~ GAME OF LIFE ~", width / 2,  width + 20);
  textSize(textSize);
  fill(#000000);
  text("by Asanka Sovis", width / 2,  width + 40);
}

void mouseClicked() {
  // Checking if the mouse is clicked. We will allow us to kill or revive a cell by clicking on certain cells.
  // This is helpful to set certain patterns without needing to stop the simulation
  if (mouseY < width) {
    cells[(mouseX * cellsinRow / width) + 1][(mouseY * cellsinRow / width) + 1] = !cells[(mouseX * cellsinRow / width) + 1][(mouseY * cellsinRow / width)  + 1];
  } else {
    // We also reset the simulation if we click on the text area
    cells = new boolean[cellsinRow + 2][cellsinRow + 2];
    generation = 0;
  }
  refreshScreen(); // Do a refresh
}

void keyPressed() {
  // Check if a key is pressed. We will use this to play/pause the simulation.
  // If space bar is pressed, we switch state
  // For 'Z', we reset the simulation
  if (key == ' ') {
    work = !work;
  } else if (key == 'z') {
    cells = new boolean[cellsinRow + 2][cellsinRow + 2];
    generation = 0;
  }
  refreshScreen(); // Do a refresh
}

int ruleCheck(int x, int y) {
  // THE MOST IMPORTANT PART OF THE CODE. CHECKING THE RULES CONWAY PROPOSED.
  // Conway proposed the following 4 rules:
  //   01. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
  //   02. Any live cell with two or three live neighbours lives on to the next generation.
  //   03. Any live cell with more than three live neighbours dies, as if by overpopulation.
  //   04. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
  // This function checks these rules for the given cell and return what must be done to it.
  // Accepts the row and column of the cell as x(int) and y(int)
  // Return what needs to be done as int
  // 0 - Do nothing, 1 - Kill, 2 - Revive
  
  int liveNeighbours = 0; // This variable will keep track of the live neighbours of the cell
  int returnVal = 0; // State to be returned
  
  // Here we check all the surrounding cells. We do this by using a nested loop
  // The nested loop checks 3x3 grid with the current cell as center
  // Note: Notice how the loop go between x - 1 to x + 1 and y - 1 to y + 1
  //       Also we discard the current cell because it doesn't count for the
  //       rules. Notice where we check if the cell is not x and y
  // This will count the number of live neighbours of the cell.
  for(int i = x - 1; i <= x + 1; i++) {
    for(int j = y - 1; j <= y + 1; j++) {
      if (!((i == x) && (j == y)) && cells[i][j]) {
        liveNeighbours++;
      }
    }
  }
  
  // This is where we apply the rules according to the live neighbours we have.
  // The 1st 3 rules are for an alive cell. So we apply it if our cell is alive
  // Notice that if neighbours > 3 or < 2, we kill the cell. Otherwise we let it
  // live further. So we check if this condition is set, if so we set the command
  // to kill that cell. If not, we need not do anything because the cell is already alive
  // and is left to live on. 
  //
  // Last rule is for a dead cell. In that case, if neighbours = 3, we must
  // revive this cell, if not, we do nothing to the cell.
  if (cells[x][y]) {
    if (!((2 <= liveNeighbours) && (liveNeighbours <= 3))) {
      returnVal = 1;
    }
  } else {
    if (liveNeighbours == 3) {
      returnVal = 2;
    }
  }
  
  // Here we also print the number of live neighbours of each cell. You can comment it if
  // you do not need to see this
  fill(#000000);
  text(liveNeighbours, (textSize / 2) + (cellsinRow / 2) + ((x - 1) * cellSize), textSize + (cellsinRow / 2) + ((y - 1) * cellSize));
  
  return returnVal; // Returns the command
}
