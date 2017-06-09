//Use this sketch to discover the name of your webcam and available resolutions.
//They will appear on the console

import processing.video.*;

void setup() {
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i+": "+cameras[i]);
    }    
  }
}