import processing.serial.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.opengl.*;
import javax.media.opengl.GL;

int[][] sigIndex = {
  {
    0, -1, -1, -1, -1, -1, -1, -1
  }
  , {
    1, -1, -1, -1, -1, -1, -1, -1
  }
  , {
    2, -1, -1, -1, -1, -1, -1, -1
  }
  , {
    3, -1, -1, -1, -1, -1, -1, -1
  }
  , 
  {
    4, -1, -1, -1, -1, -1, -1, -1
  }
  , {
    5, -1, -1, -1, -1, -1, -1, -1
  }
  , {
    6, -1, -1, -1, -1, -1, -1, -1
  }
  , {
    -1, -1, -1, -1, -1, -1, -1, -1
  }
};
String[] gNames = {
  "A1", "A2", "A3", "A4", "D1", "D2", "Filter", "D4"
};

int[][] sigColor = {
  {
    255, 0, 0
  }
  , {
    0, 255, 0
  }
  , {
    100, 100, 255
  }
  , {
    0, 255, 255
  }
  , {
    255, 0, 255
  }
  , {
    255, 255, 0
  }
  , {
    200, 200, 200
  }
};
float[][] signals;
int sigPointer = 0;

PFont font;
int mX, mY;
int prevWidth=-1, prevHeight=-1;
float lowPassAlpha = 0.2;
int filterSigIndex = 0;

Serial myPort;        // The serial port

void setup () {
  //size(displayWidth, displayHeight);
  size(800, 500);
  frame.setResizable(true);
  font = createFont("Arial", 16, true);


  println(Serial.list());
  myPort = new Serial(this, Serial.list()[7], 115200);
  myPort.bufferUntil('\n');
  background(20);
}


void draw() {
  if (prevWidth!=width || prevHeight!=height) {
    signals = new float[8][width/4];
    sigPointer=0;
  }
  prevWidth = width;
  prevHeight = height;

  background(20);

  for (int i=0; i<8; i++) {
    drawGraph(i, (i%4)*width/4, (i/4)*height/2);
  }
  stroke(200);
  line(width/4, 0, width/4, height);
  line(width/2, 0, width/2, height);
  line(width*3/4, 0, width*3/4, height);
  line(0, height/2, width, height/2);

  if (selectedSection!=-1) drawGraph(selectedSection, ssX, ssY);
}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n');

  if (prevWidth!=width) {
    signals = new float[8][width/4];
    sigPointer=0;
  }
  prevWidth = width;
  prevHeight = height;

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    println(inString);

    String[] words = split(inString, ',');
    if (words.length <6) return;
    if (words[0]=="" || words[1]=="" || words[2]=="") return;
    // convert to an int and map to the screen height:
    int tsValue = int(inString);
    signals[0][sigPointer]=float(words[0]); 
    signals[1][sigPointer]=float(words[1]); 
    signals[2][sigPointer]=float(words[2]); 
    signals[3][sigPointer]=float(words[3]);
    signals[4][sigPointer]=float(words[4]);
    signals[5][sigPointer]=float(words[5]);
    int prevPointer = sigPointer-1;
    if (prevPointer<0) prevPointer = signals[6].length - 1;
    if (sigIndex[6][0]!=-1) signals[6][sigPointer]= (1-lowPassAlpha)*signals[6][prevPointer] + lowPassAlpha*signals[filterSigIndex][sigPointer];

    sigPointer = (sigPointer+1)%signals[0].length;
  }
}


void drawGraph(int index, int topX, int topY) {  
  textFont(font, 20);
  if (index==6) {
    fill(40);
    rect(topX, topY, topX+width/4, topY+height/2);
  }
  if (index==7) {
    fill(20, 0, 0);
    rect(topX, topY, topX+width/4, topY+height/2);
  }
  
  float highCount = 0;
  for (int i=0; i<sigIndex[index].length; i++) {
    int cSig = sigIndex[index][i];
    if (cSig==-1) break;
    if (cSig < 6 || cSig==6) {
      stroke(sigColor[cSig][0], sigColor[cSig][1], sigColor[cSig][2], 100);
      for (int j=0; j<signals[cSig].length; j++) {
        int tempPointer = (sigPointer+j+1)%signals[cSig].length;
        int lineHeight = (int)map(signals[cSig][tempPointer], 0, 1024, 0, (int)height/4);
        line(topX + j, topY+height/4-lineHeight, topX + j, topY+height/4+lineHeight);
        
        if (signals[cSig][tempPointer] > 256) highCount = highCount + 1;
      }

      fill(sigColor[cSig][0], sigColor[cSig][1], sigColor[cSig][2]);
    } else {
      for (int j=0; j<signals[cSig].length; j++) {
        int tempPointer = (sigPointer+j+1)%signals[cSig].length;
        if (signals[cSig][tempPointer] > 1) signals[cSig][tempPointer] = 1;

        stroke(sigColor[cSig][0], sigColor[cSig][1], sigColor[cSig][2], 100);
        line(topX + j, topY + height/4 -5 - signals[cSig][tempPointer]*(height/4-5), topX + j, topY+ + height/4 + 5 + signals[cSig][tempPointer]*(height/4-5));
      }

      fill(sigColor[cSig][0], sigColor[cSig][1], sigColor[cSig][2]);
    }

    int showTime = sigPointer-1;
    if (showTime<0) showTime = signals[cSig].length - 1;
    text(gNames[cSig]+"\n"+signals[cSig][showTime], (index%4)*width/4+50*(i+1)-20, (index/4)*height/2 + 30);
    text(highCount / signals[cSig].length, (index%4)*width/4+50*(i+1)+10, (index/4)*height/2 + 30);
  }
}



int selectedSection = -1;
int ssX = -1, ssY = -1;
void mousePressed() {
  // when the mouse is pressed 
  selectedSection = mouseX/(width/4) + 4*(mouseY/(height/2));
  if (selectedSection>6) selectedSection=-1;
  ssX = mouseX-width/8;
  ssY = mouseY-height/4;
  mX = 1;
}

void mouseClicked() {
}

void mouseReleased() {
  // when the mouse is released
  if (selectedSection!=-1) {
    int moveSection = mouseX/(width/4) + 4*(mouseY/(height/2));
    if (moveSection==7) {
      int movePosition = 0;
      for (movePosition=0; movePosition<sigIndex[moveSection].length; movePosition++) {
        if (sigIndex[moveSection][movePosition] == -1) break;
      }
      for (int i=0; i<sigIndex[selectedSection].length; i++) {
        if (sigIndex[selectedSection][i] == -1) break;
        if (movePosition >= sigIndex[moveSection].length) break;
        sigIndex[moveSection][movePosition] = sigIndex[selectedSection][i];
        movePosition++;
      }
    } else if (moveSection==6 && selectedSection < 4) {
      filterSigIndex = selectedSection;
      float prev = 0;
      for (int i=0; i<signals[selectedSection].length; i++) {
        int tempPointer = (sigPointer+i+1)%signals[selectedSection].length;
        if (i==0) {
          signals[6][tempPointer] = signals[selectedSection][tempPointer];
          prev = signals[selectedSection][tempPointer];
        } else {
          signals[6][tempPointer] =  (1-lowPassAlpha)*prev + lowPassAlpha*signals[selectedSection][tempPointer];
        }
      }
    }
    selectedSection = -1;
  } else {
    int section = mouseX/(width/4) + 4*(mouseY/(height/2));
    if (section==7) {
      mX = section;
      if (mouseY <= height/2+50 && mouseY >= height/2 + 10) {
        for (int i=0; i<sigIndex[7].length; i++) {
          if (mouseX <= 3*(width/4)+10+(i+1)*55 && mouseX >= 3*(width/4)+10+i*55) {
            sigIndex[7][i] = -1;
            for (int j=i; j<sigIndex[7].length-1; j++) {
              sigIndex[7][j] = sigIndex[7][j+1];
            }
          }
        }
      }
    }
  }
}

void mouseMoved() {
  // when the mouse is moved without a button pressed
}


void mouseDragged() {
  // when the mouse is moved while a button is pressed
  ssX = mouseX-width/8;
  ssY = mouseY-height/4;
}

