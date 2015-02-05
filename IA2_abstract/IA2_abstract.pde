import processing.serial.*;

PFont font;
int mX, mY;
int prevWidth=-1, prevHeight=-1;
int initVelocity = 5;
int traceLength = 10;
int frameIndex = 0;
int traceDuration = 3;
int velMax = 20, velMin = 5;

int[] signals = new int[4];
float[][] bX, bY;
float[] bVx, bVy;
int[][] bColor = {
  {
    255, 0, 0
  }
  , {
    0, 255, 0
  }
  , {
    0, 0, 255
  }
  , {
    255, 255, 0
  }
  , {
    255, 0, 255
  }
  , {
    0, 255, 255
  }
  , {
    255, 255, 255
  }
  , {
    100, 100, 100
  }
};
int posPointer = 0;
float[] prevX, prevY;
int[] bSizes;
float[][] boxX = new float[2][10], boxY = new float[2][10];
int[] boxWidth = new int[2], boxHeight = new int[2];
float[] pprevX = {
  -1, -1, -1, -1, -1, -1, -1, -1
} 
, pprevY = {
  -1, -1, -1, -1, -1, -1, -1, -1
}; 


Serial myPort;        // The serial port

void setup() {
  size(displayWidth, displayHeight);
  frame.setResizable(true);
  font = createFont("Arial", 16, true);

  bX = new float[signals.length][traceLength];
  bY = new float[signals.length][traceLength];
  bVx = new float[signals.length];
  bVy = new float[signals.length];
  prevX = new float[signals.length];
  prevY = new float[signals.length];
  bSizes = new int[signals.length];

  boxWidth[0] = (int)random(width/20, width/10); 
  boxWidth[1] = (int)random(width/20, width/10);
  boxHeight[0] = (int)random(height/20, height/10); 
  boxHeight[1] = (int)random(height/20, height/10);

  for (int i=0; i<boxX[0].length; i++) {
    boxX[0][i] = boxWidth[0] + (boxWidth[0] + 50)*i;
    boxY[0][i] = random((i%2)*height/3, height-((i+1)%2)*height/3);
    boxX[1][i] = boxWidth[1] + (boxWidth[1] + 50)*i;
    boxY[1][i] = random(((i+1)%2)*height/3, height-(i%2)*height/3);
  }

  for (int i=0; i<signals.length; i++) {
    for (int j=0; j<traceLength; j++) {
      bX[i][j] = width/2;
      bY[i][j] = height/2;
      prevX[i] = width/2;
      prevY[i] = height/2;
      bSizes[i] = 10;
    }
    float theta = random(2*3.14);
    bVx[i] = initVelocity*sin(theta);
    bVy[i] = initVelocity*cos(theta);
  }

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[7], 9600);
  myPort.bufferUntil('\n');
}


void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    String[] words = split(inString, ',');
    if (words.length <6) return;
    // convert to an int and map to the screen height:
    int tsValue = int(inString);
    signals[0]=int(words[0]); 
    signals[1]=int(words[1]); 
    signals[2]=int(words[2]); 
    signals[3]=int(words[3]); 
    boxValue[0]=int(words[4]);
    boxValue[1]=int(words[5]);

    for (int i=0; i<signals.length; i++) {
      float v = map(signals[i], 0, 1024, velMin, velMax);
      float cVel = sqrt(bVx[i]*bVx[i] + bVy[i]*bVy[i]);
      bVx[i] = bVx[i]*v/cVel;
      bVy[i] = bVy[i]*v/cVel;
    }
  }
}


void draw() {
  drawFrame();
  if (prevWidth!=width || prevHeight!=height) {
    if(prevWidth!=-1){
      for(int i=0; i<boxX[0].length; i++){
        boxX[0][i] = boxX[0][i]*((float)width/(float)prevWidth);
        boxY[0][i] = boxY[0][i]*((float)width/(float)prevWidth);
        boxX[1][i] = boxX[1][i]*((float)width/(float)prevWidth);
        boxY[1][i] = boxY[1][i]*((float)width/(float)prevWidth);
      }
    }
  }
  prevWidth = width;
  prevHeight = height;

  for (int i=0; i<signals.length; i++) {
    drawBall(i);
  }
  drawBox(0);
  drawBox(1);
}

int[] boxValue = {
  0, 0
};
int[][] boxColor = {
  {
    123, 155, 233
  }
  , {
    200, 121, 138
  }
};
void drawBox(int index) {
  textFont(font, 15);
  for (int i=0; i<boxX[index].length; i++) {
    if (boxValue[index]==1) {
      stroke(200);
      fill(boxColor[index][0], boxColor[index][1], boxColor[index][2]);
    } else {
      noStroke();
      fill(boxColor[index][0], boxColor[index][1], boxColor[index][2], 100);
    } 
    rect(boxX[index][i], boxY[index][i], boxWidth[index], boxHeight[index]);
    fill(255);
    text("D"+index, boxX[index][i]+10, boxY[index][i]+20);
  }
}

void drawFrame() {
  background(0);
  frameIndex=(frameIndex+1)%traceDuration; 
  if (frameIndex==0) {
    posPointer=(posPointer+1)%traceLength;
  }
}

int xx=0;
void drawBall(int id) {
  noStroke();
  float velocity = sqrt(bVx[id]*bVx[id] + bVy[id]*bVy[id]);
  int ballSize = bSizes[id];
  int prevPointer = posPointer-1;
  if (prevPointer<0) prevPointer = traceLength-1;

  //collision with other balls
  for (int i=0; i<signals.length; i++) {
    float dx = prevX[id]-prevX[i];
    float dy = prevY[id]-prevY[i];
    if (sqrt(dx*dx + dy*dy) < (ballSize+bSizes[i])/2) {
      if (dx/10<1) dx*=10;
      if (dy/10<1) dy*=10;
      bVx[id] += dx/10;
      bVy[id] += dy/10;
      float newVel = sqrt(bVx[id]*bVx[id] + bVy[id]*bVy[id]);
      bVx[id] = bVx[id]*velocity/newVel;
      bVy[id] = bVy[id]*velocity/newVel;
    }
  }

  //collision to the wall
  if (prevX[id] > width-ballSize/2) {
    prevX[id] = width-ballSize/2;
    bVx[id] = -bVx[id];
  } else if (prevX[id] < ballSize/2) {
    prevX[id] = ballSize/2;
    bVx[id] = -bVx[id];
  }

  if (prevY[id] > height-ballSize/2) {
    prevY[id] = height-ballSize/2;
    bVy[id] = -bVy[id];
  } else if (prevY[id] < ballSize/2) {
    prevY[id] = ballSize/2;
    bVy[id] = -bVy[id];
  }

  //collision to the boxes
  for (int i=0; i<boxX.length; i++) {
    if (boxValue[i]==1) {
      for (int j=0; j<boxX[i].length; j++) {
        float boxBottom = boxY[i][j]+boxHeight[i]+ballSize/2;
        float boxTop =boxY[i][j] - ballSize/2;
        float boxLeft = boxX[i][j] - ballSize/2;
        float boxRight =  boxX[i][j]+boxWidth[i]+ballSize/2;

        if (prevX[id] < boxRight && prevX[id] > boxLeft
          && prevY[id] < boxBottom && prevY[id] > boxTop) {
          if (pprevY[id] < boxTop) {
            bVy[id] = -bVy[id];
          }
          if (pprevY[id] > boxBottom) {
            bVy[id] = -bVy[id];
          }
          if (pprevX[id] < boxLeft) {
            bVx[id] = -bVx[id];
          }
          if (pprevX[id] > boxRight) {
            bVx[id] = -bVx[id];
          }
        }
      }
    }
  }


  bX[id][posPointer] = (int)(prevX[id] + bVx[id]);
  bY[id][posPointer] = (int)(prevY[id] + bVy[id]);

  for (int i=0; i<traceLength; i++) {
    fill(bColor[id][0], bColor[id][1], bColor[id][2], 255*(i+1)/traceLength);
    prevPointer = posPointer+i+1;
    if (prevPointer>=traceLength) prevPointer = prevPointer-traceLength;
    ellipse(bX[id][prevPointer], bY[id][prevPointer], ballSize, ballSize);
  }
  fill(255);
  text("A"+id, bX[id][posPointer], bY[id][posPointer]);

  pprevX[id] = prevX[id];
  pprevY[id] = prevY[id];
  prevX[id] = bX[id][posPointer];
  prevY[id] = bY[id][posPointer];
  bSizes[id] = (int)map(velocity, velMin, velMax, 20, 100);
}

void mousePressed() {
  // when the mouse is pressed
}

void mouseReleased() {
  // when the mouse is released
}

void mouseMoved() {
  // when the mouse is moved without a button pressed 
  /*
  mX = mouseX; 
   mY = mouseY; 
   float v = map(mY, 0, displayHeight, velMin, velMax);
   float cVel = sqrt(bVx[0]*bVx[0] + bVy[0]*bVy[0]);
   bVx[0] = bVx[0]*v/cVel;
   bVy[0] = bVy[0]*v/cVel;
   v = map(mX, 0, displayWidth, velMin, velMax);
   cVel = sqrt(bVx[1]*bVx[1] + bVy[1]*bVy[1]);
   bVx[1] = bVx[1]*v/cVel;
   bVy[1] = bVy[1]*v/cVel;
   */
}

void mouseDragged() {
  // when the mouse is moved while a button is pressed
}

