//SUDOKU

//i'm actually amazed at how simple the solver is
//it can do any puzzle in seconds
int[][] grid;
boolean[][] modifiable;
//PFont font;
PVector lastClick;
boolean selection = false;
int iterationsPerFrame = 1;
int totalIterations = 0;
boolean puzzleSolved = false;

String sudoku1 = "1....7.9..3..2...8..96..5....53..9...1..8...26....4...3......1..4......7..7...3..";//65-400 iterations
String sudoku2 = ".................................................................................";//<100 iterations
String sudoku3 = "8...94.75.72..39.8..987263..9....7..1.746..2....7..1..4.5...387...1584.2.....7.16";//Easy //5 iterations
String sudoku4 = "....2........1..82182546....3746.......1.74..4.6...7.5..3...2...542....192..748..";//Medium //<150 iterations
String sudoku5 = "..62....5...4..3..2....3.1..2.3.....7.3....49.1.9.27.8.3.64......25...9.5.9...1..";//Hard //<150 iterations
String sudoku6 = "....9.86.....6..3....174....9.4......8.....256....5...1.7.....6......1....4..97..";//Expert //100-400 iterations
String sudoku7 = "86......4....1...6..35..81.........83...4.72...5..9..........6..2.4.....7...2.13.";//evil //50-500 iterations
String sudoku8 = "..8....4..6...3...2...5.1.8........98...1.7.5..28.........4..2...3..54.77......9.";//evil //100-2000 iterations
String sudoku9 = "21....4......28.........1.6...5.76.883......7....16..3.423......53....7...79.....";//13 iterations
String sudoku10 =".1..38.6......1.4559..........39.1..65..........16..2....614.....7............8.9";//26 iterations
String sudoku11 ="8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..";//1516 iterations
String sudoku12 ="1....7.9..3..2...8..96..5....53..9...1..8...26....4...3......1..4......7..7...3..";
String sudoku13 ="..53.....8......2..7..1.5..4....53...1..7...6..32...8..6.5....9..4....3......97..";//https://www.mirror.co.uk/news/weird-news/worlds-hardest-sudoku-can-you-242294 solved in 44 iterations
String sudoku14 ="..............3.85..1.2.......5.7.....4...1...9.......5......73..2.1........4...9";//"hard for brute force" solved in minimum 138

void setup() {
  lastClick = new PVector(-1, -1);
  //font = createFont("data/GROBOLD.ttf", 50);

  size(900, 900);
  setupGrid();
  loadStringSudoku(sudoku14);
}

void draw() {
  background(240);
  drawGrid();
  drawSelection();
  drawNumbers();
  
  if(!puzzleSolved) {
    for (int iteration = 0; iteration < iterationsPerFrame; iteration++) {
      solverIteration();
    }
  }
  else {
    frameRate(0);
    println("puzzle solved in " + totalIterations  + " iterations");
  }
  
  //speed up
  if(frameCount % 60 == 0) {
    iterationsPerFrame++;
    println(iterationsPerFrame + " iterations per frame");
  }
}

void solverIteration() {
  boolean freebie = false;
  boolean solved = true;
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      IntList candidates = possibleValues(i, j);
      //generally using while loops is a very bad idea
      while (candidates.size() == 0 && grid[i][j] == 0) {
        int guessX = floor(random(9));
        int guessY = floor(random(9));
        if (modifiable[guessX][guessY]) {
          grid[guessX][guessY] = 0;
        }
        candidates = possibleValues(i, j);
      }
      if (modifiable[i][j]) {
        if (grid[i][j] == 0) {
          solved = false;
        }
        if (candidates.size() == 1 && grid[i][j] == 0) {
          grid[i][j] = candidates.get(0);
          freebie = true;
        }
      }
    }
  }
  if (!freebie && !solved) {
    int guessX = floor(random(9));
    int guessY = floor(random(9));
    IntList candidates = possibleValues(guessX, guessY);
    if (modifiable[guessX][guessY] && grid[guessX][guessY] == 0 && candidates.size() != 0) {
      grid[guessX][guessY] = candidates.get(floor(random(candidates.size())));
    }
  }
  
  if(solved) {
    puzzleSolved = true;
  }
  else {
    totalIterations++;
  }
}

void mouseClicked() {
  int cx = floor(mouseX / 100);
  int cy = floor(mouseY / 100);
  if (cx == lastClick.x && cy == lastClick.y || cx < 0 || cx > 8 || cy < 0 || cy > 8 || !modifiable[cx][cy]) {
    selection = false;
  } else {
    selection = true;
    lastClick = new PVector(cx, cy);
  }
}

void keyPressed() {
  if (selection && keyCode >= 48 && keyCode <= 57 && possibleValues((int)lastClick.x, (int)lastClick.y).hasValue(keyCode - 48)) {
    grid[(int)lastClick.x][(int)lastClick.y] = keyCode - 48;
  }
}

void loadStringSudoku(String sudoku) {
  for (int c = 0; c < 81; c++) {
    int i = c % 9;
    int j = floor(c / 9);
    char value = sudoku.charAt(c);

    if (value == '.') {
      modifiable[j][i] = true;
    } else {
      grid[j][i] = value - 48;
      modifiable[j][i] = false;
    }
  }
}

IntList removeAll(IntList original, int value) {
  IntList newList = new IntList();

  for (int i = 0; i < original.size(); i++) {
    if (original.get(i) != value) {
      newList.append(original.get(i));
    }
  }

  return newList;
}

IntList possibleValues(int column, int row) {
  IntList values = new IntList();

  for (int n = 1; n <= 9; n++) {
    values.append(n);
  }

  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (i == column || j == row || (floor(i / 3) == floor(column / 3) && floor(j / 3) == floor(row / 3))) {
        values = removeAll(values, grid[i][j]);
      }
    }
  }

  return values;
}

String intListAsString(IntList list) {
  String ret = "";

  for (int i = 0; i < list.size(); i++) {
    ret += list.get(i);
  }

  return ret;
}

void drawSelection() {
  if (selection) {
    stroke(255, 0, 0, 100);
    fill(255, 0, 0, 20);
    rect(lastClick.x * 100, lastClick.y * 100, 100, 100);
  }
}

void drawNumbers() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      push();
      //textFont(font);
      textSize(13);
      stroke(10);
      fill(70, 180);
      if (modifiable[i][j]) {
        text(intListAsString(possibleValues(i, j)), i * 100 + 10, j * 100 + 20);
      }
      textSize(50);
      textAlign(CENTER, CENTER);
      if (!modifiable[i][j]) fill(30);
      if (grid[i][j] != 0) text(grid[i][j], (j + 0.5) * 100, (i + 0.5) * 100);
      pop();
    }
  }
}

void setupGrid() {
  modifiable = new boolean[9][9];
  grid = new int[9][9];
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      grid[i][j] = 0;
    }
  }
}

void drawGrid() {
  for (int i = 0; i < 10; i++) {
    stroke(100, i % 3 == 0 ? 150 : 100);
    strokeWeight(i % 3 == 0 ? 10 : 6);
    line(i * 100, 0, i * 100, width);
    line(0, i * 100, height, i * 100);
  }
}
