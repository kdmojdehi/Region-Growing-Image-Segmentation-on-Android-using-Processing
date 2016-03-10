/*
Interactive Region Growing Segmentation
click on any area to segment it using region growing algorithm
extra features: flick horizontally to change images,  flick vertically to change sensitivity , click and hold to change segmentation color
author: karan daei-mojdehi , Fall 2015 , Computer Vision mini project 1 
email: karan7dm@gmail.com
*/

import android.view.MotionEvent;
import ketai.ui.*;

PImage img , segmented;
boolean[] in_segment; 
int H,W,clickx,clicky,loc,CLICK_LOC;
float TH,THABS; // TH is threshold for relative min distance between pixels  and neighbors for assigning them to a segment , THABS is
IntList to_visit;                                                                                // for distance to clicked location
String[] filenames = {"test1.jpg","test5.jpg","test2.jpg","test6.jpg","test4.jpg"};
int IM = 0;
color COLOR = color(255,0,0);
ArrayList<FadeText> fades = new ArrayList<FadeText>();
KetaiGesture gesture;
void setup(){
  gesture = new KetaiGesture(this);
  img = loadImage(filenames[IM]);
  H = img.height;
  W = img.width;
  size(displayWidth , displayHeight);
  TH = 19;
  THABS = 53;
  imageMode(CORNER);
  background(0,0,0);
  image(img,displayWidth/2 - W/2,0);
  textSize(42);
  textAlign(CENTER);
  //print(displayWidth);
  //print(displayHeight);
  img.loadPixels();
  segmented = loadImage(filenames[IM]);
  fades.add(new FadeText("Touch an area to segment it " , displayWidth/2 , displayHeight-100 , true) );
}


void draw() {
  image(segmented,displayWidth/2 - W/2,0);
  // draw fading texts if they are available in our ArrayList:
  if (fades.size()>0)
  {
    // iterate through the list in reverse and delete ones that have completely faded
    for (int txt_ind = fades.size()-1;txt_ind >= 0; txt_ind-- )
    {
      FadeText txt = fades.get(txt_ind);
      if (txt.isFaded())
        fades.remove(txt);
      else
        txt.draw(); //else draw it
    }
  }
}

void onTap(float x , float y){
    FadeText patience = new FadeText("Performing Segmentation, wait..." , displayWidth/2 , displayHeight-30, true);
    fades.add( patience );
    boolean[] visited = new boolean[W*H]; // will store false for unvisited pixels and true for location of visited pixels , 
                                          // array is used instead of list for fast lookup during segmentation
    in_segment = new boolean[W*H];  // at the end, will hold true for location of pixels that are believed to be in the segmentation
    to_visit = new IntList();  // initialize the list which will include candidate pixels for current segmentation
    // get the clicked position of pixel to grow:
    clickx = mouseX - displayWidth/2 + W/2;
    clicky = mouseY;
    //print("recieved loc:");
    //print(x);
    //print(y);
    //print('\n');
    CLICK_LOC = clickx + W*clicky;
    int current_loc;
    visited[CLICK_LOC] = true;
    print ("Starting Segmentation...");
    colorNeighbs(CLICK_LOC , visited );
    while ( to_visit.size() > 0 ){
      current_loc = to_visit.get(0);
      to_visit.remove(0);
      if (visited[current_loc] ) {continue;}
      colorNeighbs(current_loc , visited );
    }
    print("Done Segmenting!\n");
    segmented = loadImage(filenames[IM]); // NECESSARY?
    segmented.loadPixels();
    for (int f=0 ; f< in_segment.length ; f++) {
      if (in_segment[f]) { segmented.pixels[f] = COLOR; }
    }
    segmented.updatePixels();
    imageMode(CORNER);
    image(segmented,displayWidth/2 - W/2,0);
    fades.remove(patience);
  }


// function that will be called to change the color of pixels in neighbours:
void colorNeighbs( int cur_loc ,boolean[] visited ){
  visited[cur_loc] = true;
  in_segment[cur_loc] = true;
  int[] nLocs = neighbLoc( cur_loc); // init with neighbour of current pixel
  int chk_loc;
  for (int index=0;index<nLocs.length;index++){
    chk_loc = nLocs[index]; // go through cur_loc neigbours one by one
    if (visited[chk_loc]) { continue; } // this pixel has already been visited, proceed to next neigbour in list
    else {
      if (rgbDist(cur_loc , chk_loc) < TH && rgbDist(CLICK_LOC , chk_loc) < THABS ){
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

// function that will return array of location of 8-neighbor pixels(uses height and width of image as global var H , W):
int[] neighbLoc( int loc ){
  int row,column;
  row = loc/W;
  column = loc%W;
  IntList nLocs= new IntList();
  for (int j=-1;j<2 ; j++){ // j loops for rows
    if (row+j==H || row+j<0) {continue;}
    for (int i=-1;i<2;i++){ // i loops for columns
      if (column+i==W || column+i<0 || (i==0 && j==0) ) {continue;} // in order to avoid going out of image boundaries ,
      nLocs.append(loc+ i + W*j);                                   // also avoids returning current pixel as its own neighbor
    }
  }
  return nLocs.array();
}


// change picture on flicks:
void onFlick( float x, float y, float px, float py, float v)
{
  if (abs(x-px) > abs(y-py) ) // change pictures for horizontal flicks
  {
    if (x-px>150) IM++;
    else if (x-px < -150) IM--;
    if (IM<0) IM += filenames.length;
    if (IM == filenames.length) IM = 0;
    img = loadImage(filenames[IM]);
    segmented = loadImage(filenames[IM]);
    image(img,displayWidth/2 - W/2,0);
    img.loadPixels();
  } else // change TH for vertical flicks
  {
    TH += map(py-y , -H ,H , -20 , 20);
    String temp_s = String.format("Segmentation Threshold\nChanged to %2.2f\n",TH);
    fades.add(new FadeText(temp_s ,px , py) );
  }
  
  
}



// change segmentation color on doubletap
void onLongPress(float x, float y)
{
  color red = color(255,0,0);
  color green = color(0,255,0);
  color blue = color(0,0,255);
  switch (COLOR)
  {
     case (0xffff0000): // hex code for red color
     {
       COLOR = green;
       fades.add(new FadeText("Segmentation Color \nChanged to Green" ,x ,y) );
       break;
     }
     case (0xff00ff00): // color code for green
     {
       COLOR = blue;
       fades.add(new FadeText("Segmentation Color \nChanged to Blue" ,x ,y) );
       break;
     }
     case (0xff0000ff): // color code for blue
     {
       COLOR = red;
       fades.add(new FadeText("Segmentation Color \nChanged to Red" ,x ,y) );
       break;
     }
     
  }

}

public boolean surfaceTouchEvent(MotionEvent event) {

  //call to keep mouseX, mouseY, etc updated
  super.surfaceTouchEvent(event);

  //forward event to class for processing
  return gesture.surfaceTouchEvent(event);
}