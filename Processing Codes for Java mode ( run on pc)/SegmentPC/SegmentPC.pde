/*
Interactive Region Growing Segmentation
click on any area to segment it using region growing algorithm
author: karan daei-mojdehi , Fall 2015 , computer vision mini project
email: karan7dm@gmail.com
*/
PImage img , segmented;
int H,W,clickx,clicky,loc;
int TH; // threshold for min distance between pixels for assigning them to a segment
IntList to_visit;
String filename;
int dH; //display Height
void settings()
{
  size(1080 , int(displayHeight*.8));
  dH = int(displayHeight*.8);
}
void setup(){  
  filename = "data\\test4.jpg";
  img = loadImage(filename);
  H = img.height;
  W = img.width;  
  TH = 16;
  imageMode(CORNER);
  background(0,0,0);
  image(img,1080/2 - W/2,0 , 1080 , dH );
  //print(displayWidth);
  //print(displayHeight);
}


void draw() {}

void mousePressed(){
    boolean[] visited = new boolean[W*H]; // will store false for unvisited pixels and true for location of visited pixels
    to_visit = new IntList();  // initialize the list which will include candidate pixels for current segmentation
    // get the clicked position of pixel to grow
    clickx = mouseX - 1080/2 + W/2;
    clicky = int(mouseY*1920/dH);
    //print("recieved click:",clickx,clicky,"\n");
    img.loadPixels();
    segmented = loadImage(filename);
    segmented.loadPixels();
    int current_loc = clickx + W*clicky;
    visited[current_loc] = true;
    colorNeighbs(current_loc , visited );
    while ( to_visit.size() > 0 ){
      current_loc = to_visit.get(0);
      to_visit.remove(0);
      if (visited[current_loc] ) {continue;}
      colorNeighbs(current_loc , visited );
    }
    
    print("Done Segmenting!\n");
    segmented.updatePixels();
    imageMode(CORNER);
    image(segmented,1080/2 - W/2,0 , 1080 , dH);
  }





// Function that will be recursively used to change the color of pixels in neighbours:
void colorNeighbs( int cur_loc ,boolean[] visited ){
  visited[cur_loc] = true;
  segmented.pixels[cur_loc] = color(255,0,0); // make segmented pixel RED
  int[] nLocs = neighbLoc( cur_loc); // init with neighbour of current pixel
  int chk_loc;
  for (int index=0;index<nLocs.length;index++){
    chk_loc = nLocs[index]; // go through cur_loc neigbours one by one
    if (visited[chk_loc]) { continue; } // this pixel has already been visited, proceed to next neigbour in list
    else {
      if (rgbDist(cur_loc , chk_loc) < TH ){
        to_visit.append(chk_loc);
      } else {visited[chk_loc] = true;} // we are not interested in this pixel
    }
  }
  return;
}


float rgbDist(int loc1,int loc2){ // returns the eculidean distance between rgb channels of image for loc1 and loc2
  color c1,c2;
  c1 = img.pixels[loc1];
  c2 = img.pixels[loc2];
  return dist(red(c1),green(c1),blue(c1),red(c2),green(c2),blue(c2));
}

//Function that will return array of location of 8-neighbor pixels(uses height and width of image as global var H , W):
int[] neighbLoc( int loc ){
  int row,column;
  row = loc/W;
  column = loc%W;
  IntList nLocs= new IntList();
  for (int j=-1;j<2 ; j++){ // j loops for rows
    if (row+j==H || row+j<0) {continue;}
    for (int i=-1;i<2;i++){ // i loops for columns
      if (column+i==W || column+i<0 || (i==0 && j==0) ) {continue;}
      nLocs.append(loc+ i + W*j);
    }
  }
  return nLocs.array();
}