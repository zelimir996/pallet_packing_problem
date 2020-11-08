import java.util.*;
import javafx.util.Pair;
import java.lang.Math.*;

public class Solver {
  public class LSegment {
    public int x;
    public int len;
    public int z;
    public LSegment(int x, int len, int z) {
      this.x = x;
      this.len = len;
      this.z = z;
    }
  }
  
  public class Layer {
    public boolean last = false;
    public long V = 0;
    public long VHoles = 0;
    public LinkedList<Box> boxes = new LinkedList<Box>();
    void add(Box b) {
      boxes.add(b);
      V += b.dim1 * b.dim2 * b.dim3;
    }
  }
  
  class LayerComparator implements Comparator<Layer> {
    public int compare(Layer a, Layer b) {
      if (a.last) return 1;
      return int(a.VHoles - b.VHoles);
    }
  }

  private BoxPile pile;
  private Pallet pallet;
  int[] bestOrientation;
  public Solver(BoxPile pile, Pallet pallet) {
    this.pile = pile;
    this.pallet = pallet;
  }
  
  public int[] orientation(){
    return bestOrientation;
  }

  int findLowestSegment(LinkedList<LSegment> segments) {
    int min = MAX_INT;
    int i = 0;
    int minIndex = 0;
    for (LSegment seg : segments) {
      if (seg.z < min) {
        min = seg.z;
        minIndex = i;
      }
      i++;
    }
    return minIndex;
  }

  int[][] permutationMatrix = {{0,1,2}, {0,2,1}, {1,0,2}, {1,2,0}, {2, 1, 0}, {2,0,1}};

  
  Box pickBox(int maxX, int optY, int maxY, int optZ, int maxZ) {
    BoxPile.BoxBatch bestBatch = null;
    Box bestBox = new Box(0, 0, 0, 0, 0, 0);;
    int bestFitX = MAX_INT, bestFitY = MAX_INT, bestFitZ = MAX_INT;
    
    for (BoxPile.BoxBatch bb: pile.getBatches()){
      if (bb.available == 0) continue;
      int[] dims = {int(bb.dim1), int(bb.dim2), int(bb.dim3)};
      for (int[] perm: permutationMatrix){
        int ww = dims[perm[0]],
            hh = dims[perm[1]],
            dd = dims[perm[2]];
        if (ww > maxX || hh > maxY || dd > maxZ) continue;
            
        int hScore = abs(hh-optY),
            wScore = abs(ww-maxX),
            dScore = abs(dd-optZ);
        if ((hScore < bestFitY) ||
            (hScore == bestFitY && wScore < bestFitX) ||
            (hScore == bestFitY && wScore == bestFitX && dScore < bestFitZ)) {
            bestFitY = hScore;
            bestFitX = wScore;
            bestFitZ = dScore;
            bestBatch = bb;
            bestBox.setDims(ww, hh, dd);        
        }
                
      }
      
    }
    if (bestBatch == null) return null;
    if (bestBox.dim2 > optY) return null;
    pile.takeOne(bestBatch);
    bestBox.col_int = bestBatch.col;
   return bestBox;
  }
  
  void packLeft(Box box, LSegment segment, LinkedList<LSegment> segments, int newZ, int segmentPos){
        box.x = segment.x;
        if (box.dim1 != segment.len) {
          LSegment newSeg = new LSegment(segment.x + int(box.dim1), 
            int(segment.len - box.dim1), 
            segment.z);
          segments.add(segmentPos + 1, newSeg);
        }
        segment.z = newZ;
        segment.len = int(box.dim1);
  }
  
  void packRight(Box box, LSegment segment, LinkedList<LSegment> segments, int newZ, int segmentPos){
        box.x = segment.x + segment.len - box.dim1;

        if (int(box.dim1) == segment.len) {
          segment.z += box.dim3;
        } else {
          LSegment newSeg = new LSegment (int(box.x), int(box.dim1), segment.z + int(box.dim3));
          segments.add(segmentPos + 1, newSeg);
          segment.len -= box.dim1;
        }
  }

  Layer packLayer(int maxW, int maxH, int maxZ, int layerThicknes, int y) {
    Layer layer= new Layer();
    
    LinkedList<LSegment> segments = new LinkedList<LSegment>();
    segments.add(new LSegment(-1, 0, maxZ)); /* left wall */
    segments.add(new LSegment(0, maxW, 0));
    segments.add(new LSegment(maxW+1, 0, maxZ+1)); /* right wall */

    while (true) {
      if (pile.available == 0) { 
        layer.last = true;
        break;
      }
      int segmentPos = findLowestSegment(segments);
      if (segmentPos == 0) break;
      ListIterator<LSegment> it = segments.listIterator(segmentPos-1);

      LSegment prev = it.next();
      LSegment segment = it.next();
      LSegment next = null;
      /* merge current */
      while (it.hasNext()){
        next = it.next();
        if (next.z == segment.z){
          segment.len += next.len;
          it.remove();
        }
        else break;
      }
      
      int lWallH = abs(segment.z - prev.z);
      int rWallH = abs(segment.z - next.z);
      int optZ = min(lWallH, rWallH);
      Box box = pickBox(segment.len, layerThicknes, maxH, optZ, maxZ-segment.z);     
      if (box == null){ /* no box can fit hole */
        int oldz = segment.z;      
        segment.z = min(prev.z, next.z);
        layer.VHoles += layerThicknes * segment.len * (segment.z-oldz);
        continue;
      }
      int newZ = int( box.dim3) + segment.z;
      box.z = segment.z;
      box.y = y;
      if (prev == segments.getFirst() && next != segments.getLast()) { /* no boxes on left, and there is box on right */
        packRight(box, segment, segments, newZ, segmentPos);
      }
      else if(prev != segments.getFirst() && next == segments.getLast()){
        packLeft(box, segment, segments, newZ, segmentPos);
      }
      else if (abs (newZ - prev.z) < abs (newZ - next.z)) { /* left */
        packLeft(box, segment, segments, newZ, segmentPos);
      } 
      else { /* right */
        packRight(box, segment, segments, newZ, segmentPos);
      }
      layer.add(box);
      
    }
    return layer;
  }
  
  void increment(HashMap<Integer,Integer> ss, int k) {
    if (ss.containsKey(k)){
      int a = ss.get(k);
      a++;
      ss.put(k, a);
    }
    else 
      ss.put(k, 1);
  }
  List<Integer> findThicknes(){
    List<Integer> ret = new LinkedList<Integer>();
    HashMap<Integer, Integer> sideScore = new HashMap<Integer,Integer>();
    for (BoxPile.BoxBatch bb: pile.getBatches()){
      increment(sideScore, int(bb.dim1));
      increment(sideScore, int(bb.dim2));
      increment(sideScore, int(bb.dim3));
    }
    int bestSideScore = -1;
    for (int k: sideScore.keySet()){
      int score = sideScore.get(k);
      if (score > bestSideScore){
        ret.clear();
        ret.add(k);
        bestSideScore = score;
      }
      else if (score == bestSideScore) 
        ret.add(k);
    }
    return ret;
  }
  
  
  List<Layer> solve() {
    List<Integer> layerThickneses = findThicknes();
    int[][] orientations = {{pallet.w, pallet.h}, {pallet.h, pallet.w}};
    int maxHeight = pallet.d;
    List<Layer> bestSolution = null;
    int solutionScore = 0, currentScore;
    
    int i = 0;
    int pickedSolution = 0;
    int pickedThickness = 0, currentThickness = 0;
    
    for(Integer layerThicknes: layerThickneses){
      for (int[] orientation: orientations){
        currentScore = MAX_INT;
        Layer layer = null;
        List<Layer> solution = new LinkedList<Layer>();
        do {
          layer = packLayer(orientation[0], maxHeight-solution.size()*layerThicknes, orientation[1],  layerThicknes, layerThicknes*solution.size());
          if (layer != null && layer.boxes.size() > 0) {
            solution.add(layer);
            currentScore += layer.VHoles;
          }
          else break;
        } while (pile.available > 0);
        pile.reset();
        if (currentScore < solutionScore) {
          pickedSolution = i;
          solutionScore = currentScore;
          bestSolution = solution;      
          bestOrientation = orientation;
          pickedThickness = currentThickness;
        }
         i++;
      }
      currentThickness++;
     
    }
    Collections.sort(bestSolution, new LayerComparator());
    int y = 0;
    /* fix y position of boxes */
    for (Layer l: bestSolution){
      println(l.VHoles + "|" + l.V + "|" + (l.VHoles + l.V) + "|" + (pallet.w*pallet.h*layerThickneses.get(0)));
      for (Box b: l.boxes){
        b.y = y;
      }
      y += layerThickneses.get(pickedThickness);
    }
    
    return bestSolution;
  }
  
}
