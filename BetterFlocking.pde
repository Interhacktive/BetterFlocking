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

ToxiclibsSupport gfx;

// Reference to physics world
VerletPhysics2D physics;
AttractionBehavior mouseAttractor;
Vec2D mousePos;

Flock flock;
PImage bg;
void setup() {
  size(1000,700);
  bg = loadImage("water.jpg");
    gfx = new ToxiclibsSupport(this);
  
   // Initialize the physics
  physics=new VerletPhysics2D();
   physics.setDrag(0.05f);
  physics.setWorldBounds(new Rect(10,10,width-20,height-20));
  physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.15f)));
  
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 300; i++) {

    flock.addBoid(new Boid(new Vec2D(width/2,height/2),6.0,0.15)); // default speed 3.0, force 0.05
          VerletParticle2D pi = (VerletParticle2D) flock.boids.get(i);
       physics.addParticle(pi);
        physics.addBehavior(new AttractionBehavior(pi, 20, -1.2f, 0.01f));

    
  }
  smooth();
  noCursor();
}

void draw() {
  background(255);
  image(bg, 0,0);
  flock.run();
  for (int i = 0; i < 300; i++) {
          Vec2D myMouse = new Vec2D(mouseX, mouseY);
        Boid b = (Boid) flock.boids.get(i);
        if(!mousePressed){
          b.avoid(myMouse, 100);
          fill(255,50, 30,100);
        } else{
          b.seek(myMouse);
          fill(40,100,230,200);
        }
        ellipse(mouseX, mouseY, 5, 5);

        for(int w = 0;w< width;w+=50){
        Vec2D wtBumper = new Vec2D(w, 0);
        b.avoid(wtBumper, 50);
        
        Vec2D wbBumper = new Vec2D(w, height);
        b.avoid(wbBumper, 50);
        }
        
        for(int h = 0;h< height;h+=50){
        Vec2D htBumper = new Vec2D(0, h);
        b.avoid(htBumper, 50);
        
        Vec2D hbBumper = new Vec2D(width,h);
        b.avoid(hbBumper, 50);
        }
        
  }
}

// Add a new boid into the System
void mousePressed() {
 // flock.addBoid(new Boid(new Vec2D(mouseX,mouseY),2.0,0.05f));
}

