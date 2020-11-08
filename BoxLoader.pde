import org.w3c.dom.*;
import javax.xml.parsers.*;
import java.io.*;
import java.util.*;

public class BoxLoader
{
  private File inFile;
  private Pallet pallet;
  public BoxLoader(File file) {
    inFile = file;
  }
  

  public Pallet getPallet(){
    return pallet;
  }
  public BoxPile load() {
    BoxPile pile = new BoxPile();
    DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    Document doc = null;
    try {
      DocumentBuilder builder = null;
      builder = factory.newDocumentBuilder();
      doc = builder.parse(inFile);
    }
    catch (Exception e) {
      System.out.println(e);
      return null;
    }
    NodeList boxes = doc.getElementsByTagName("box");
    for(int i = 0; i < boxes.getLength(); i++) {
      Node nBox = boxes.item(i);
      if (nBox.getNodeType() == Node.ELEMENT_NODE){
        Element box = (Element) nBox;
        
        float w = float(box.getAttribute("width"));
        float h = float(box.getAttribute("height"));
        float d = float(box.getAttribute("depth"));
        int n = int(box.getAttribute("available"));
        String c = box.getAttribute("color");
        pile.addBatch(n, w, h, d, unhex(c));
      }
    }
    
    NodeList pallets = doc.getElementsByTagName("pallet");
    for (int i = 0; i < pallets.getLength(); i++){ //<>//
      Node nPallet = pallets.item(i);
      if (nPallet.getNodeType() == Node.ELEMENT_NODE){
        Element pallet = (Element) nPallet;
        int w = int(pallet.getAttribute("width"));
        int h = int(pallet.getAttribute("height"));
        int d = int(pallet.getAttribute("depth"));
        this.pallet = new Pallet(w,h,d);
      }
    }
    if (pallet == null){ //asume EURpallet
      pallet = new Pallet(1200, 800, 1800);
    }
    
    return pile;
  }
}
