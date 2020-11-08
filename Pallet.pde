public class Pallet {
  public int w;
  public int h;
  public int d;

  public Pallet(int m_w, int m_h, int m_d){
    this.w = min(m_w, m_h);
    this.h = max(m_w, m_h);
    this.d = m_d;
  }
}
