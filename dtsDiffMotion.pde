class DiffMotion
{
  private float avgX;
  private float avgY;
  private color curColor;
  private color prvColor;
  private PImage lastFrame;
  
  int streamWidth, streamHeight, thresh;
  float threshX, threshY, dampX, dampY;
  GSCapture vStream = null;
  
  DiffMotion(GSCapture _vStream, int _streamWidth, int _streamHeight)
  {
    vStream = _vStream;
    threshX = threshY = 2;
    dampX = dampY = 0.5;
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
          }
          lastFrame.pixels[i] = curColor;
        }
      }
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

