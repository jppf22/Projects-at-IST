package xxl;

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/*
  class that represents the concept of a structure made up of cells
 */
public abstract class StorageStruct implements Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private int _lines;
    private int _columns;

    public StorageStruct(int lines, int columns){
        _lines = lines;
        _columns = columns;
    }
    
    public int getLines(){return _lines;}
    public int getColumns(){return _columns;}
    
    public abstract Cell getCell(int line, int column);
    public abstract void setCell(int line, int column, Content cellContent);
    public abstract void removeCell(int line, int column);
}
