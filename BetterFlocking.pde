/**
 * <p>Flocking by <a href="http://www.shiffman.net">Daniel Shiffman</a>
 * created for The Nature of Code class, ITP, Spring 2009.</p>
 * 
 * <p>Ported to toxiclibs by Karsten Schmidt</p>
 * 
 * <p>Demonstration of <a href="http://www.red3d.com/cwr/">Craig Reynolds' "Flocking" behavior</a><br/>
 * <p>Rules: Cohesion, Separation, Alignment</p>
 * 
 * <p><strong>Usage:</strong> Click mouse to add boids into the system</p>
 */

/* 
 * Copyright (c) 2009 Daniel Shiffman
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
 
import toxi.geom.*;
import toxi.math.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.processing.*;
import codeanticode.gsvideo.*;

ToxiclibsSupport gfx;

int _width = 800;
int _height = 600;
// Reference to physics world
VerletPhysics2D physics;
AttractionBehavior mouseAttractor;

Flock flock;
PImage bg;

//"motion tracking"
GSCapture vStream;
DiffMotion _differ;
PVector avg;
Vec2D tracked;

void setup()
{
  size(_width,_height);
  bg = loadImage("water.jpg");
  gfx = new ToxiclibsSupport(this);
  avg = new PVector(width/2,height/2);
  tracked = new Vec2D(width/2,height/2);
  
   // Initialize the physics
  physics=new VerletPhysics2D();
  physics.setDrag(0.05f);
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.15f)));
  
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 300; i++)
  {
    flock.addBoid(new Boid(new Vec2D(width/2,height/2),6.0,0.15)); // default speed 3.0, force 0.05
    VerletParticle2D pi = (VerletParticle2D) flock.boids.get(i);
    physics.addParticle(pi);
    physics.addBehavior(new AttractionBehavior(pi, 20, -1.2f, 0.01f));
  }
  smooth();
  noCursor();
  
  //startup motion tracking
  vStream = new GSCapture(this, _width, _height);
  _differ = new DiffMotion(vStream, _width, _height);
  _differ.init();
}

void draw()
{
  background(255);
  image(bg, 0,0);
  flock.run();
  
  avg = _differ.processFrame();
  tracked.x = width-avg.x;
  tracked.y = avg.y;
  for (int i = 0; i < 300; i++)
  {
    Boid b = (Boid) flock.boids.get(i);
    if(!mousePressed)
    {
      b.avoid(tracked, 100);
      fill(255,50, 30,100);
    }
    else
    {
      b.seek(tracked);
      fill(40,100,230,200);
    }
    for(int w = 0;w< width;w+=50)
    {
      Vec2D wtBumper = new Vec2D(w, 0);
      b.avoid(wtBumper, 50);
      
      Vec2D wbBumper = new Vec2D(w, height);
      b.avoid(wbBumper, 50);
    }
    
    for(int h = 0;h< height;h+=50)
    {
      Vec2D htBumper = new Vec2D(0, h);
      b.avoid(htBumper, 50);
      
      Vec2D hbBumper = new Vec2D(width,h);
      b.avoid(hbBumper, 50);
    }
  }
  ellipse(tracked.x,tracked.y,5,5);
}

// Add a new boid into the System
void mousePressed() {
 // flock.addBoid(new Boid(new Vec2D(mouseX,mouseY),2.0,0.05f));
}

void stop()
{
  _differ.finished();
  super.stop();
}

void keyPressed()
{
  
}
