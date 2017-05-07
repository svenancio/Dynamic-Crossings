/*
===================
DYNAMIC CROSSINGS 
Version 1.0
by Grupo Realidades 
===================
*/

import processing.video.*;

//é necessário incluir esta biblioteca indo em Sketch > Import Library > Add Library. 
//Daí procure pela biblioteca BlobDetection 
import blobDetection.*;


int screenW = 1024;
int screenH = 768;
Capture cam;
BlobDetection theBlobDetection;
PImage img;
int timenow;
int maxtimenow = 86400;//24 horas convertidas em segundos
int tone;
int zStep = 500;//define o intervalo em pixels entre uma iteração e outra de profundidade do desenho
int animaCount;

void setup()
{
  // Tamanho da projeção em pixels
  size(1024, 768, P3D);//16:9
  //fullscreen();
  //descomente o código a seguir pra que o Console produza uma lista 
  //de câmeras e seja identificado o nome de uma para preencher depois
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
  
  //inicia a captura da música
  cam = new Capture(this, 800, 600);//, "Logitech HD Pro Webcam C920");
  cam.start();
  animaCount = 0;
  // Detecção dos blobs
  // usamos uma imagem reduzida para minimizar as informações dos blobs
  img = new PImage(screenW/10,screenH/10); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  //altere true ou false para detectar áreas claras (true) ou áreas escuras (false)
  theBlobDetection.setPosDiscrimination(true);
  //altere o parâmetro para alterar a percepção dos blobs
  theBlobDetection.setThreshold(0.3f);
}

void draw() 
{ 
  //calculo do horário somando todos os segundos do dia
  timenow = hour()*3600 + minute()*60 + second();
  timenow = animaCount;maxtimenow = 7200;
  animaCount++;
  if (animaCount >= maxtimenow) animaCount = 0;
  //translate para centralizar o referencial de desenho
  translate(screenW/2,screenH/2,zStep);

  //pinta o fundo conforme o tempo passa: 
  //até 6 da manhã (21600 segundos) - escuro
  //ao meio dia - totalmente claro
  //após 6 da tarde (64800 segundos) - escuro
  if(timenow > maxtimenow/4 && timenow <= maxtimenow/2) {
    tone = 255*(timenow-maxtimenow/4)/(maxtimenow/4);
  }else if(timenow > maxtimenow/2 && timenow < 3*maxtimenow/4) {
    tone = 255 - 255*(timenow-maxtimenow/2)/(maxtimenow/4);
  }else{
    tone = 0;
  }
  background(tone);
  
  //Detecção dos blobs 
  img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);//reduz a fonte da câmera para a imagem a ponto de "resumir" a informação e facilitar a detecção de blobs
  fastblur(img, 2);//blur necessário para eliminar ruídos da câmera que gerariam blobs indesejáveis 
  theBlobDetection.computeBlobs(img.pixels);//detecta os blobs e armazena numa lista
  
  pushMatrix();
  drawBlobTowers();
  popMatrix();
}

//função que desenha uma torre para cada blob detectado pela câmera,
//com ponto de fuga definido conforme horário do dia

void drawBlobTowers()
{
  Blob b, c;
  int blobCount = theBlobDetection.getBlobNb();//contagem de blobs
  strokeWeight(6);
  
  rotateY((timenow*PI/maxtimenow)-(PI/2));
  
  //loop externo: repete desenho ao longo da profundidade z
  for(int i=0;i<10;i++) {
    //muda a cor do desenho conforme ele se aprofunda
    stroke(18*i+10,18*i+10,18*i+10);
    
    //loop interno: desenha caixas e interliga os centros com linhas
    for(int j=0; j<blobCount; j++)
    {
      b=theBlobDetection.getBlob(j);//obtém o blob da vez
      
      pushMatrix();
      translate(b.x*screenW - screenW/2,b.y*screenH - screenH/2,0);//translada a posição conforme a posição do blob
      herveoBox(500,'z');//desenha o box
      line(0,0,0,0,0,-zStep);//desenha uma linha que liga à próxima caixa ao longo do eixo z
      popMatrix();
    }
    
    noFill();
    //inicia o desenho interligando o centro de cada caixa criada
    beginShape();
    for(int j=0; j<blobCount; j++)
    {
      b=theBlobDetection.getBlob(j);//para cada blob...
      //desenha um vértice, interligando ao anterior
      vertex(b.x*screenW - screenW/2,b.y*screenH - screenH/2,0);
      
      //caso chegue ao final, conecta o último ao primeiro vértice
      if(j==blobCount-1){
        c = theBlobDetection.getBlob(0);
        vertex(c.x*screenW - screenW/2,c.y*screenH - screenH/2,0);
      }
    }
    endShape();
    
    //translada a profundidade para repetir o processo
    translate(0,0,-zStep);
  }
}

//cria um box com estruturas diagonais semelhantes a estrutura da Herveo Tower
void herveoBox(int size, char type)
{
  box(size);//cria uma caixa

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