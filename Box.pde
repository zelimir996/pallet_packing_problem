public class Box {
  public float x;
  public float y;
  public float z;
  public float dim1;
  public float dim2;
  public float dim3;
  public PVector col = new PVector(random(1), random(1), random(1));
  public int col_int;
  public Box (float _x, float _y, float _z, float d1, float d2, float d3) {
    x = _x;
    y = _y;
    z = _z;
    dim1 = d1;
    dim2 = d2;
    dim3 = d3;
  }
  public void setDims(int d1, int d2, int d3){
    dim1 = d1;
    dim2 = d2;
    dim3 = d3;
  }

  public void draw() {
    beginShape(QUADS);
    fill(col_int);
    vertex(x, y, z); 
    vertex(x + dim1, y, z); 
    vertex(x + dim1, y + dim2, z); 
    vertex(x, y + dim2, z);
    vertex(x, y, z + dim3); 
    vertex (x + dim1, y, z + dim3); 
    vertex (x + dim1, y+dim2, z + dim3); 
    vertex(x, y+dim2, z+dim3);
    vertex(x, y, z); 
    vertex(x, y, z+dim3); 
    vertex(x, y + dim2, z + dim3); 
    vertex(x, y + dim2, z);
    vertex(x+dim1, y, z); 
    vertex(x+dim1, y+dim2, z); 
    vertex(x+dim1, y+dim2, z+dim3); 
    vertex(x+dim1, y, z+dim3);
    vertex(x, y, z); 
    vertex(x + dim1, y, z); 
    vertex(x+dim1, y, z+dim3); 
    vertex(x, y, z + dim3);
    vertex(x, y + dim2, z); 
    vertex(x + dim1, y + dim2, z); 
    vertex(x+dim1, y+dim2, z+dim3); 
    vertex(x, y+dim2, z+dim3);

    endShape();
    stroke(0.1);
  }
}
