// oscillation6

// physical parameters

float x0 = 0.05;
float y0 = 0.2;

float m = 0.5;

float radius = 0.05;

float k = 100.0;
float l0 = 0.2;
float d = 0.5;

float gx = 0.0;
float gy = 9.8;

float dt = 0.01;

// viewing parameters

float viewingSize = 2.0;

int xOffset;
int yOffset;
float viewingScale;

// objects

int nParticles = 5;
int nSprings = nParticles - 1;

Particle[] particles;
Spring[] springs;



// particle //////////////////////////////

class Particle {
  float x, y;
  float vx, vy;
  float fx, fy;
  
  float m;
  boolean isFixed;
  
  float radius;
  
  float xPrev, yPrev;
  float vxPrev, vyPrev;
  float fxPrev, fyPrev;
  
  Particle(float x0, float y0, float vx0, float vy0, float m0,
           boolean f, float r) {
    m = m0;
    x = x0;
    y = y0;
    vx = vx0;
    vy = vy0;
    isFixed = f;
    radius = r;
  }
  
  void init() {
    fx = 0.0;
    fy = 0.0;
    
    xPrev = x;
    yPrev = y;
    vxPrev = vx;
    vyPrev = vy;
    fxPrev = fx;
    fyPrev = fy;
  }
  
  void clearForce() {
    fx = 0.0;
    fy = 0.0;
  }
  
  void addForce(float x, float y) {
    fx += x;
    fy += y;
  }
  
  void move(float dt) {
    if (isFixed) {
      return;
    }
    
    float xNew = x + (3 * vx - vxPrev) * 0.5 * dt;
    float yNew = y + (3 * vy - vyPrev) * 0.5 * dt;
    float vxNew = vx + (3 * fx - fxPrev) * 0.5 * dt / m;
    float vyNew = vy + (3 * fy - fyPrev) * 0.5 * dt / m;
    
    xPrev = x;
    yPrev = y;
    vxPrev = vx;
    vyPrev = vy;
    fxPrev = fx;
    fyPrev = fy;
    
    x = xNew;
    y = yNew;
    vx = vxNew;
    vy = vyNew;
  }
  
  void draw() {
    if (radius <= 0.0) {
      return;
    }
    
    fill(224);
    stroke(128);
    strokeWeightScaled(1.0);
    
    pushMatrix();
    translate(x, y);
    ellipse(0, 0, radius, radius);
    stroke(200, 0, 0);
    line(0, 0, fx*0.03, fy*0.03);
    popMatrix();
  }
};

// spring ////////////////////////////////////

class Spring {
  Particle[] particles;
  float k;
  float l0;
  float d;
  
  Spring(Particle p0, Particle p1, float k0, float l00, float d0)
  {
    particles = new Particle[2];
    particles[0] = p0;
    particles[1] = p1;
    k = k0;
    l0 = l00;
    d = d0;
  }
  
  void init() {
  }
  
  void calc() {
    float dx = particles[1].x - particles[0].x;
    float dy = particles[1].y - particles[0].y;
    float l = sqrt(dx * dx + dy * dy);
    float ex = dx / l;
    float ey = dy / l;
    float fx = -k * (l - l0) * ex;
    float fy = -k * (l - l0) * ey;
    
    float vx = particles[1].vx - particles[0].vx;
    float vy = particles[1].vy - particles[0].vy;
    fx += -d * vx;
    fy += -d * vy;
    
    particles[0].addForce(-fx, -fy);
    particles[1].addForce(fx, fy);
  }
  
  void draw() {
    noFill();
    stroke(128);
    strokeWeightScaled(1.0);
    
    line(particles[0].x, particles[0].y, particles[1].x, particles[1].y);
  }
};

// simulation /////////////////////////////////////

void simulationInit() {
  particles = new Particle[nParticles];
  for (int i = 0; i < nParticles; i++) {
    if (i == 0) {
      particles[i] = new Particle(0.0, 0.0, 0.0, 0.0, m, true, 0.0);
    } else {
      particles[i] = new Particle(x0 * i, y0 *i, 0.0, 0.0, m, false, radius);
    }
  }
  
  springs = new Spring[nSprings];
  for (int i = 0; i < nSprings; i++) {
    springs[i] = new Spring(particles[i], particles[i + 1], k, l0, d);
  }
  
  for (Particle p: particles) {
    p.init();
  }
  
  for (Spring s: springs) {
    s.init();
  }
}

void simulationCalc(float dt) {
  for (Particle p: particles) {
    p.clearForce();
    p.addForce(p.m * gx, p.m * gy);
  }
  
  if (mousePressed == true) {
    float mx = (mouseX - xOffset) / viewingScale;
    float my = (mouseY - yOffset) / viewingScale;
    for (Particle p: particles) {
      float dx = mx - p.x;
      float dy = my - p.y;
      float pullK = 50.0; p.addForce(pullK * dx, pullK * dy);
    }
  }
  
  for (Spring s: springs) {
    s.calc();
  }
  
  for (Particle p: particles) {
    p.move(dt);
  }
}

void simulationDraw() {
  ellipseMode(RADIUS);
  background(255);
  
  translate(xOffset, yOffset);
  scale(viewingScale);
  
  for (Spring s: springs) {
    s.draw();
  }
  
  for (Particle p: particles) {
    p.draw();
  }
}

// utility function ///////////////////////////////

void strokeWeightScaled(float s) {
  strokeWeight(s / viewingScale);
}

// setup //////////////////////////////////////////

void setup() {
  size(512, 512);
  frameRate(60);
  smooth(4);
  
  xOffset = width / 2;
  yOffset = 0;
  viewingScale = width / viewingSize;
  
  simulationInit();
}

// draw ///////////////////////////////////////////

void draw() {
  simulationCalc(dt);
  simulationDraw();
}

// callbacks //////////////////////////////////////

void keyPressed() {
  if (key == ESC || key == 'q') {
    exit();
  }
}
