package xxl;

import java.util.Objects;
import java.util.Map;
import java.util.TreeMap;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class StorageMap extends StorageStruct {

    private TreeMap<Coordinate,Cell> _cells = new TreeMap<Coordinate,Cell>();

    class Coordinate implements Comparable<Coordinate>, Serializable{
        private int _line;
        private int _column;

        public Coordinate(int line, int column){
            _line = line;
            _column = column;
        }

        @Override
        public int compareTo(Coordinate other){
            if(_line != other._line)
                return Integer.compare(_line, other._line);
            return Integer.compare(_column, other._column);
        }

        @Override
        public int hashCode(){
            return Objects.hash(_line,_column);
        }

        public int getLine(){return _line;}
        public int getColumn(){return _column;}
    }

    public StorageMap(int lines, int columns){
        super(lines,columns);
    }

    public Cell getCell(int line, int column){ 
        Coordinate coordinate = new Coordinate(line, column);
        if(_cells.containsKey(coordinate)){
            return _cells.get(new Coordinate(line,column));
        }
        else{
            return null; 
        }
    }

    public void setCell(int line, int column, Content cellContent){
        Coordinate coordinate = new Coordinate(line, column);
        if(cellContent == null) return; 
        if(_cells.containsKey(coordinate)){
            _cells.get(coordinate).setContent(cellContent);
        }
        else{
            Cell cell = new Cell();
            cell.setContent(cellContent);
            _cells.put(coordinate, cell);
        }
    }

    public void removeCell(int line, int column){
        _cells.remove(new Coordinate(line, column));
    }

    public void setCell(int line, int column, Cell cell){
        if(cell == null) return; 
        _cells.put(new Coordinate(line, column), cell);
    }
}
