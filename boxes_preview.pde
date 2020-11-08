import java.util.*; //<>//
import peasy.PeasyCam;
import processing.dxf.*;

LinkedList<Box> boxes = new LinkedList<Box>();
PeasyCam pcam;

volatile File inputFile = null;
void filePicked(File f)
{
  inputFile = f;
}

List<Solver.Layer> solution;
int nShow = 0;

void writeOutput(List<Solver.Layer> s, int t, BoxPile pile, Pallet p) {
  int nPacked = 0;
  double vTotal = 0;
  double vHoles = 0;
  beginRaw(DXF, "solution.dxf");
  for (Solver.Layer l : s) {
    nPacked += l.boxes.size();
    vTotal += l.V;
    vHoles += l.VHoles;
    for (Box b : l.boxes) {
      b.draw();
    }
  }
  endRaw();
  double vPallet = (double) (p.w) * (double) (p.h) * (double)(p.d);
  PrintWriter writer = createWriter("statistics.csv");
  writer.println("\"Running time\", " + 
                 "\"Number of packed boxes\", " + 
                 "\"Number of given boxes\", " + 
                 "\"Volume utilization\", " + 
                 "\"Total empty space\", " +
                 "\"Virtual boxes volume\", " + 
                 "\"Virtual boxes to actual boxes volume ratio\"");
  writer.println(t + ", " + 
                 nPacked + ", " +  
                 pile.size + ", "  +   
                 vTotal/vPallet*100  + ", "  +
                 (vPallet - vTotal) + ", " +
                 vHoles + ", " +
                 vHoles/vTotal);
  writer.close();
}

void setPerspective() {
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), 
    cameraZ/10.0, cameraZ*20.0);
}

int x_offset;
int y_offset;
int z_offset;

PShape palletShape;

int nPacked;
void setup()
{
  size(800, 600, P3D);
  background(0);
  lights();
  selectInput("Izaberite ulazni fajl", "filePicked");
  while (inputFile == null);
  BoxLoader b = new BoxLoader(inputFile);
  BoxPile pile = b.load();
  Solver solver = new Solver(pile, b.getPallet());
  int solver_start = millis();
  solution = solver.solve();
  int solver_end = millis();
  writeOutput(solution, solver_end - solver_start, pile, b.getPallet());
  x_offset = solver.orientation()[0]/2;
  y_offset = solver.orientation()[1]/2;
  z_offset = 0;
  setPerspective();

  Pallet pallet = b.getPallet();
  if (solver.orientation()[0] < solver.orientation()[1]) {    
    palletShape = loadShape("pallet.obj");
  } else {
    palletShape = loadShape("nova-eu-paleta.obj");
  }
  palletShape.scale(float(pallet.h)/1200.0, 1.0, float(pallet.w)/800.0);
  palletShape.translate(0, -144, 0);
  pcam = new PeasyCam(this, x_offset, 0, y_offset, 400);
  pcam.lookAt(width/2 + x_offset, z_offset, height/2 + y_offset);
  pcam.setDistance(2200);

  pcam.rotateX(-0.7866);
  pcam.rotateY(0.6624);
  pcam.rotateZ(-2.5714);
  
  for (Solver.Layer l : solution)
    nPacked += l.boxes.size();

  colorMode(RGB, 1);
}

void updateBoxes() {
  int nLayers = 0;
  boxes.clear();
  for (Solver.Layer l : solution) {        
    if (boxes.size() < nShow) {
      nLayers++;
      for (Box b : l.boxes) {
        boxes.add(b);
        if (boxes.size() == nShow) break;
      }
    }
    if (boxes.size() >= nShow) break;
  }

  z_offset = boxes.size() > 0 ? int(boxes.getFirst().dim2 * nLayers /2) : 0;
  pcam.lookAt(width/2 + x_offset, z_offset, height/2 + y_offset);

}

void keyPressed() {
  switch(key) {
  case 'x':
    if (nShow < nPacked) nShow += 1;
    updateBoxes();
    break;
  case 'z':
    if (nShow > 0) nShow -= 1;
    updateBoxes();
    break;
  }
  println(nShow);
}

void draw() {
  background(0);
  lights();

  pushMatrix();
  translate (width/2, 0, height/2);
  shapeMode(CORNER);
  shape(palletShape, 0, 0);
  for (Box b : boxes) {
    b.draw();
  }
  popMatrix();
}
