/****************************************************************
Copyright (C) 2012 The Blank Collective
Released under the FreeBSD License (BSD 2-Clause)
See LICENSE.pde for details
***************************************************************/

/***************************************************************
DiffMotion - Frame differencing based pseudo-motion tracking 

Usage (See DiffTest.pde):
  DiffMotion myDiffer;
  PVector avg;

  myDiffer = new DiffMotion(new GSCapture(this,640,480),640,480);
  myDiffer.init();
  avg = myDiffer.processFrame();
  myDiffer.finished();
  
Public Members:
  drawFrame (boolean): Should we draw the current video frame?
  drawDiff (boolean): Should we draw the difference visualization?
  thresh (int): pixels below this value are ignored
    thresh is calculated as max(0,pixel-thresh)
  threshX/Y (float): Amount between pixels required to register
    difference as motion
  dampX/dampY (float): Motion damping between frames
  
***************************************************************/

class DiffMotion
{
  private float avgX;
  private float avgY;
  private color curColor;
  private color prvColor;
  private PImage lastFrame;
  
  boolean drawFrame, drawDiff;  
  int streamWidth, streamHeight, thresh;
  float threshX, threshY, dampX, dampY;
  GSCapture vStream = null;
  
  DiffMotion(GSCapture _vStream, int _streamWidth, int _streamHeight)
  {
    drawFrame = false;
    drawDiff = false;
    vStream = _vStream;
    threshX = threshY = 2;
    dampX = dampY = 0.1;
    thresh = 32;
    streamWidth = _streamWidth;
    streamHeight = _streamHeight;
    lastFrame = createImage(streamWidth, streamHeight, RGB);
  }
  
  void init()
  {
    if(vStream!=null)
      vStream.start();
  }
  
  PVector processFrame()
  {
    int diffSum = 0;
    ArrayList<PVector> diffPixels = new ArrayList();
    
    loadPixels();  
    if(vStream.available())
    {
      vStream.read();
      vStream.loadPixels();
      lastFrame.loadPixels();
      
      for(int x=0;x<streamWidth;x++)
      {
        for (int y=0;y<streamHeight;y++)
        {
          int i = y*streamWidth+x;          
          if(drawFrame)
            pixels[i] = vStream.pixels[i];
          curColor = vStream.pixels[i];
          prvColor = lastFrame.pixels[i];
          
          // (1) ----------------------------
          int r = (curColor>>16)&0xFF;
          int g = (curColor>>8)&0xFF;
          int b = curColor&0xFF;
          int oldR = (prvColor>>16)&0xFF;
          int oldG = (prvColor>>8)&0xFF;
          int oldB = prvColor&0xFF;
          // -----------------------------(1)
          
          int diffR = max(0,(r-oldR)-thresh);
          int diffG = max(0,(g-oldG)-thresh);
          int diffB = max(0,(b-oldB)-thresh);
          
          int tempSum = diffR+diffG+diffB;
          if(tempSum>0)
          {
            diffSum += tempSum;          
            diffPixels.add(new PVector(x,y));
            if(drawDiff)
              pixels[i] = color(0,255,0);
          }
          lastFrame.pixels[i] = curColor;
        }
      }
      updatePixels();
    }
    PVector avgPoint = avgDiffPixels(diffPixels);
    
    // (2) -----------------------
    float diffX = avgPoint.x - avgX;
    float diffY = avgPoint.y - avgY;
    if(abs(diffX)>threshX)
      avgX+=diffX*dampX;
    if(abs(diffY)>threshY)
      avgY+=diffY*dampY;
    // -------------------------(2)
        
    return new PVector(avgX, avgY);
  }
  
  PVector avgDiffPixels(ArrayList<PVector> arr)
  {
    float sumx=0;
    float sumy=0;
    for(int i=0;i<arr.size();i++)
    {
      PVector c = (PVector)arr.get(i);
      sumx+=c.x;
      sumy+=c.y;
    }
    return new PVector(sumx/arr.size(),sumy/arr.size());        
  }
  
  void finished()
  {
    vStream.stop();
    vStream.delete();
  }
}

//(1) http://processing.org/learning/library/framedifferencing.html
//(2) http://processing.org/learning/basics/easing.html

