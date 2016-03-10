class FadeText   // class for displaying temporary texts on screen
{
  PVector location;
  float life = frameRate *3;
  String msg="";
  boolean permanent = false;
  
  public FadeText(String _txt , float x , float y)
  {
    location = new PVector(x,y);
    msg = _txt;
  }
  
  public FadeText(String _txt , float x , float y , boolean perma)
  {
    location = new PVector(x,y);
    msg = _txt;
    life = max(150,frameRate*3);
    if (perma)
      permanent = true;
  }
  
  public void draw()
  {
    pushStyle();
    stroke(255,map(life, frameRate*3, 0, 255, 0));
    fill(255, map(life, frameRate*3, 0, 255, 0));
    textAlign(CENTER);
    textSize(42);
    if (!permanent)
      life--;
    if (life > 0)
      text(msg, location.x, location.y);
    popStyle();
  }
  
  public boolean isFaded()
  {
     return (life <=0);
  }

}