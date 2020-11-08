import java.util.*;

public class BoxPile
{
public class BoxBatch {
  public int size;
  public int available;
  public float dim1;
  public float dim2;
  public float dim3;
  public int col;
  public BoxBatch(int av, float d1, float d2, float d3, int col) {
    available = av;
    size = av;
    dim1 = d1;
    dim2 = d2;
    dim3 = d3;
    this.col = col;
  }
  public void reset() {
    available = size;
  }
}

  private List<BoxBatch> batches;
  public int available;
  public int size;
  public BoxPile() {
    batches = new LinkedList<BoxBatch>();
    available = 0;
  }
  
  public void addBatch(int size, float d1, float d2, float d3, int col) {
    batches.add(new BoxBatch(size, d1, d2, d3, col));
    available += size;
    this.size += size;
  }
  
  public void reset() {
    for (BoxBatch bb: batches) bb.reset();
    available = size;
  }
  
  public List<BoxBatch> getBatches() {
    return batches;
  }
  
  public void takeOne(BoxBatch bb){
    bb.available--;
    available--;
  }
}
