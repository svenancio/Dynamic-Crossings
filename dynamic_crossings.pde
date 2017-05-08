/*
===================
DYNAMIC CROSSINGS 
Version 1.0
by Grupo Realidades 
===================
*/

import processing.video.*;

//this next import must be activated first. Go to Sketch > Import Library > Add Library. 
//Then search for "BlobDetection" library and add it to your Processing IDE.
import blobDetection.*;


int screenW = 1366;//1024;
int screenH = 768;
Capture cam;
BlobDetection theBlobDetection;
PImage img;
float timenow;
float maxtimenow = 86400;//24 hours converted in seconds
float tone;
int zStep = 500;//this defines the pixel interval between depth iterations of this sketch 
float animaCount;

void setup()
{
  //Change this to define screen size
  size(1366, 768, P3D);//16:9
  //smooth(4);

  //uncomment the following code to obtain a list of detected cameras in Console 
  //Choose one and copy its name or dimensions to the Capture function 
  //String[] cameras = Capture.list();
  //if (cameras.length == 0) {
  //  println("There are no cameras available for capture.");
  //  exit();
  //} else {
  //  println("Available cameras:");
  //  for (int i = 0; i < cameras.length; i++) {
  //    println(cameras[i]);
  //  }    
  //}
  
  //starts capturing video
  cam = new Capture(this, 800, 600);//, "Logitech HD Pro Webcam C920");
  cam.start();
  animaCount = 0;
  
  //Blob Detection
  //we use a small camera source in order to minimize blob flickering
  img = new PImage(screenW/10,screenH/10); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  //change between true or false to detect bright areas(true) or dark areas (false)
  theBlobDetection.setPosDiscrimination(true);
  //change the parameter to set blob perception sensitiveness
  theBlobDetection.setThreshold(0.3f);
}

void draw() 
{   
  //calculates time by summing every second of the day
  timenow = hour()*3600 + minute()*60 + second();
  //timenow = animaCount;maxtimenow = 7200.0;
  //animaCount++;
  //if (animaCount >= maxtimenow) animaCount = 0;

  //paint the background as time pass by 
  //up to 6 o'clock (21600 seconds) - total dark
  //up to midday - total bright
  //after 18 o'clock (64800 seconds) - total dark
  if(timenow > maxtimenow/4 && timenow <= maxtimenow/2) {
    tone = 255*(timenow-maxtimenow/4)/(maxtimenow/4);
  }else if(timenow > maxtimenow/2 && timenow < 3*maxtimenow/4) {
    tone = 255 - 255*(timenow-maxtimenow/2)/(maxtimenow/4);
  }else{
    tone = 0;
  }
  background(tone);
  
  pushMatrix();
  //translate to center the drawing origin
  translate(screenW/2,screenH/2,zStep);
  
  //Blob detection every draw() iteration 
  img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);//reduz a fonte da câmera para a imagem a ponto de "resumir" a informação e facilitar a detecção de blobs
  fastblur(img, 2);//blur necessário para eliminar ruídos da câmera que gerariam blobs indesejáveis 
  theBlobDetection.computeBlobs(img.pixels);//detecta os blobs e armazena numa lista
  
  //draw towers for each blob detected
  drawBlobTowers();
  popMatrix();
  
  //draw clock
  drawClock();
}

//Drawing function to draw a tower with vanishing point towards 
//an angle defined by the current time
void drawBlobTowers()
{
  Blob b, c;
  int blobCount = theBlobDetection.getBlobNb();//contagem de blobs
  strokeWeight(6);
  
  rotateY((timenow*PI/maxtimenow)-(PI/2));
  
  //external loop: repeats drawing along z depth
  for(int i=0;i<10;i++) {
    //the color of the tower changes as it gets far
    stroke(18*i+10,18*i+10,18*i+10);
    
    //internal loop: draw boxes and connects their centres with lines
    for(int j=0; j<blobCount; j++)
    {
      b=theBlobDetection.getBlob(j);
      
      pushMatrix();
      translate(b.x*screenW - screenW/2,b.y*screenH - screenH/2,0);//set the drawing origin according to blob position
      herveoBox(500,'z');//draws the box
      line(0,0,0,0,0,-zStep);//draws a line towards the next box throughout z axis
      popMatrix();
    }
    
    noFill();
    //draws a polygon connecting each box drawn
    beginShape();
    for(int j=0; j<blobCount; j++)
    {
      b=theBlobDetection.getBlob(j);//for each blob...
      //draws a vertex, connecting it to the previous one
      vertex(b.x*screenW - screenW/2,b.y*screenH - screenH/2,0);
      
      //when it reaches the end, connect the last vertex to the first one
      if(j==blobCount-1){
        c = theBlobDetection.getBlob(0);
        vertex(c.x*screenW - screenW/2,c.y*screenH - screenH/2,0);
      }
    }
    endShape();
    
    //translates towards the z-axis to repeat this whole process
    translate(0,0,-zStep);
  }
}

//creates a box with diagonal structures, ressembling Herveo Tower
void herveoBox(int size, char type)
{
  box(size);//creates a 3D box

  //draws diagonals
  if(type != 'x') {
    line(-size/2, -size/2, -size/2, -size/2, size/2, size/2);
    line(size/2, -size/2, size/2, size/2, size/2, -size/2);
  }
  if(type != 'y') {
    line(-size/2, -size/2, size/2, size/2, -size/2, -size/2);
    line(-size/2, size/2, -size/2, size/2, size/2, size/2);
  }
  if(type != 'z') {
    line(size/2, -size/2, size/2, -size/2, size/2, size/2);
    line(-size/2, -size/2, -size/2, size/2, size/2, -size/2);
  }
}


void drawClock() {
  hint(DISABLE_DEPTH_TEST);//this command puts the interface in front of 3D rendering
  pushMatrix();
  translate(50,screenH-15,0);
  
  //draws the max arc
  beginShape();
  fill(50);
  strokeWeight(1);
  stroke(0);
  arc(0, 0, 70, 70, PI, 2*PI, CHORD);
  endShape();
  
  //draws a partial arc according to current time
  beginShape();
  noStroke();
  fill(200);
  arc(0, 0, 70, 70, 2*PI - PI*(timenow/maxtimenow), 2*PI, PIE);
  println(timenow/maxtimenow);
  endShape();
  
  //creates clock text
  fill(0);
  textSize(18);
  textAlign(CENTER);
  float hours = timenow/(maxtimenow/24);
  float minutes = (timenow % (maxtimenow/24)) / (maxtimenow/1440);
  if(minutes < 10) {
    text((int)hours+":0"+(int)minutes, 0, -5);
  }else{
    text((int)hours+":"+(int)minutes, 0, -5);
  }
  noFill();
  
  popMatrix();
  hint(ENABLE_DEPTH_TEST);//returns to 3D rendering
}


// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img,int radius)
{
 if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}