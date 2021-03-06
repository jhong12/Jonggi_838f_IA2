# Jonggi_838f_IA2
## Individual Assignment 2

###IA2_graph.pde
A processing file to show graph of analog/digital inputs. The 6 graphs including A1~4, D1~2 labels shows the raw inputs. The cell beside the D1 is filter cell. Filter cell shows the low-pass filtered data. If a user drag and drop a cell on the filter cell, it shows the filtered data. The right bottom cell shows multiple data together if a user drags and drops multiple cells into it. The serial port receives data with format described in IA2_arduino.ino.

![alt tag](http://cmsc838f-s15.wikispaces.com/file/view/a2_graph.png/539795236/347x218/a2_graph.png)

###IA2_abstract.pde
A processing file to show abstract representation of analog/digital inputs. The balls are analog inputs and the boxes are digital inputs. As the analog value is bigger, the velocity of the ball is faster and the size of the ball is bigger. The boxes are transparent and balls can go through it if the digital input is 0. The boxes are not transparent and the balls collide to the box if the digital value is 1. The serial port receives data with format described in IA2_arduino.ino.

![alt tag](http://cmsc838f-s15.wikispaces.com/file/view/a2_abstract.png/539795274/350x218/a2_abstract.png)

###IA2_arduino.ino
This code is a simple sensor reading code. The format of serial output from the arduino is 

*analog0,analog1,analog2,analog3,digital0,digital1*

where analogX is analog input range from 0 to 1024 and digitalX is digital output having either 0 or 1.
