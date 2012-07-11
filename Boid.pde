// Boid class
// Methods for Separation, Cohesion, Alignment added

class Boid extends VerletParticle2D{

  Vec2D loc;
  Vec2D vel;
  Vec2D acc;
  float r;
  float maxforce;
  float maxspeed;
  color fishColor = color(random(230,255),random(230,255),random(0,100),150);
  
   
//  Boid(Vec2D pos) {
//    super(pos);
//  }
  
  public Boid(Vec2D l, float ms, float mf) {
    super(l);
    loc=l;
    acc = new Vec2D();
    vel = Vec2D.randomVector();
    r = 20.0;
    maxspeed = ms;
    maxforce = mf;
  }

  void run(ArrayList boids) {
    flock(boids);
    update();
    hitBorders();
    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids) {
    Vec2D sep = separate(boids);   // Separation
    Vec2D ali = align(boids);      // Alignment
    Vec2D coh = cohesion(boids);   // Cohesion

    // Arbitrarily weight these forces
    sep.scaleSelf(1.5); //1.5
    ali.scaleSelf(1.0);//1.0
    coh.scaleSelf(1.0);//1.0
    // Add the force vectors to acceleration
    acc.addSelf(sep);
    acc.addSelf(ali);
    acc.addSelf(coh);
   
  }

  // Method to update location
  void update() {
    // Update velocity
    
    vel.addSelf(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.addSelf(vel);
    // Reset accelertion to 0 each cycle
    acc.clear();
  }

  void seek(Vec2D target) {
    acc.addSelf(steer(target,false));
  }
  
void avoid (Vec2D target, float desiredseparation) {
   
    Vec2D steer = new Vec2D();
    int count = 0;
      float d = loc.distanceTo(target);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        Vec2D diff = loc.sub(target);
        diff.normalizeTo(1.0/d);
        steer.addSelf(diff);
        count++;            // Keep track of how many
      }
    
    // Average -- divide by how many
    if (count > 0) {
      steer.scaleSelf(1.0/count);
    }

    // As long as the vector is greater than 0
    if (steer.magnitude() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalizeTo(maxspeed);
      steer.subSelf(vel);
      steer.limit(maxforce);
    }
    steer.scaleSelf(3.0);//1.0
    acc.addSelf(steer);
  }

  void arrive(Vec2D target) {
    acc.addSelf(steer(target,true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  Vec2D steer(Vec2D target, boolean slowdown) {
    Vec2D steer;  // The steering vector
    Vec2D desired = target.sub(loc);  // A vector pointing from the location to the target
    float d = desired.magnitude(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if (slowdown && d < 100.0f) desired.scaleSelf(maxspeed*d/100.0f); // This damping is somewhat arbitrary
      else desired.scaleSelf(maxspeed);
      // Steering = Desired minus Velocity
      steer = desired.sub(vel).limit(maxforce);  // Limit to maximum steering force
    } 
    else {
      steer = new Vec2D();
    }
    return steer;
  }

  void render() {
   /*
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading() + radians(90);
    fill(175);
    stroke(0);
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
    */
    //ellipse(loc.x, loc.y, 10, 10);
    //stroke(255,255, 255, 200);
    int tailLength = 10;
    //fish tail
    Vec2D m=new Vec2D(loc.x+(vel.x*tailLength),loc.y+(vel.y*tailLength));
  Vec2D o=new Vec2D(loc.x+(vel.x*-1), loc.y+(vel.y*-1));
  Vec2D n=m.sub(o).perpendicular().normalizeTo(random(8,10));
  Triangle2D t = new Triangle2D(o.sub(n),m,o.add(n));
  fill(fishColor); 
noStroke();
  gfx.triangle(t, true);
    
    
    //fish body
    stroke(fishColor);
    strokeWeight(5);
    line(loc.x, loc.y, loc.x+(vel.x*tailLength), loc.y+(vel.y*tailLength));
    
    //fish head
    noStroke();
    fill(fishColor);
    ellipse(loc.x+(vel.x*tailLength),loc.y+(vel.y*tailLength),15,15);
    
    //white part of eye
    fill(255, 255);
    noStroke();
    ellipse(loc.x+(vel.x*tailLength),loc.y+(vel.y*tailLength), 4, 4);
    
    //fish pupil
    fill(0, 255);
    noStroke();
    ellipse(loc.x+(vel.x*tailLength),loc.y+(vel.y*tailLength)-2, 2, 2);
    
    
      
  }

  // Wraparound
  void borders() {
    if (loc.x < -r) loc.x = width+r;
    if (loc.y < -r) loc.y = height+r;
    if (loc.x > width+r) loc.x = -r;
    if (loc.y > height+r) loc.y = -r;
  }

void hitBorders(){
   if(loc.x<r) vel.x *= -1; 
   if (loc.y < r) vel.y *= -1;
   if (loc.x > width-r) vel.x *= -1;
   if (loc.y > height-r) vel.y *= -1;
}
  // Separation
  // Method checks for nearby boids and steers away
  Vec2D separate (ArrayList boids) {
    float desiredseparation = 25.0f;
    Vec2D steer = new Vec2D();
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.distanceTo(other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        Vec2D diff = loc.sub(other.loc);
        diff.normalizeTo(1.0/d);
        steer.addSelf(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.scaleSelf(1.0/count);
    }

    // As long as the vector is greater than 0
    if (steer.magnitude() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalizeTo(maxspeed);
      steer.subSelf(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  Vec2D align (ArrayList boids) {
    float neighbordist = 50.0;
    Vec2D steer = new Vec2D();
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.distanceTo(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        steer.addSelf(other.vel);
        count++;
      }
    }
    if (count > 0) {
      steer.scaleSelf(1.0/count);
    }

    // As long as the vector is greater than 0
    if (steer.magnitude() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalizeTo(maxspeed);
      steer.subSelf(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  Vec2D cohesion (ArrayList boids) {
    float neighbordist = 50.0;
    Vec2D sum = new Vec2D();   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.distanceTo(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.addSelf(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.scaleSelf(1.0/count);
      return steer(sum,false);  // Steer towards the location
    }
    return sum;
  }
}




