package xxl;

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import xxl.exceptions.InvalidRangeException;
import xxl.exceptions.UnrecognizedEntryException;


public class Range implements Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private int _beginLine;
    private int _beginColumn;
    private int _endLine;
    private int _endColumn;
    private boolean _equalLines = false;
    private boolean _isCell = false;
    private Spreadsheet _spreadsheet; 

    public Range(int beginLine, int beginColumn, int endLine, int endColumn, Spreadsheet spreadsheet) throws InvalidRangeException{
        _beginLine = beginLine;
        _beginColumn = beginColumn;
        _endLine = endLine;
        _endColumn = endColumn;
        _spreadsheet = spreadsheet;

        if(_beginLine != _endLine && _beginColumn != _endColumn)
            throw new InvalidRangeException();

        if(_beginLine == _endLine){
            _equalLines = true;
        }

        if(_beginLine == _endLine && _beginColumn == _endColumn){
            _isCell = true;
        }
    }


    public ArrayList<Cell> getCells(){
        ArrayList<Cell> result = new ArrayList<Cell>();
        StorageStruct spreadsheetCells = _spreadsheet.getCellStorageStruct();
        int min, max;

        if(_equalLines){
            min = ((_beginColumn <= _endColumn) ? _beginColumn:_endColumn);
            max = ((_beginColumn <= _endColumn) ? _endColumn:_beginColumn);
            for(int col = min; col <= max; col++){
                result.add(spreadsheetCells.getCell(_beginLine, col));
            }
        }
        else{
            min = ((_beginLine <= _endLine) ? _beginLine:_endLine);
            max = ((_beginLine <= _endLine) ? _endLine:_beginLine);
            for(int lin = min; lin <= max; lin++){
                result.add(spreadsheetCells.getCell(lin,_beginColumn));
            }
        }
        
        return result;
    }

    //To put a copy of the same content on all cells
    public void setCells(String contentSpecification) throws UnrecognizedEntryException{
        int min, max;

        if(_equalLines){
            min = ((_beginColumn <= _endColumn) ? _beginColumn:_endColumn);
            max = ((_beginColumn <= _endColumn) ? _endColumn:_beginColumn);
            for(int col = min; col <= max; col++){
                _spreadsheet.insertContents(String.format("%d;%d", _beginLine,col), contentSpecification);
            }
        }
        else{
            min = ((_beginLine <= _endLine) ? _beginLine:_endLine);
            max = ((_beginLine <= _endLine) ? _endLine:_beginLine);
            for(int lin = min; lin <= max; lin++){
                _spreadsheet.insertContents(String.format("%d;%d", lin, _beginColumn), contentSpecification);
            }
        }
    } 

    //To put multiple copys of the content on all cells
    public void setCells(ArrayList<String> contentSpecifications) throws UnrecognizedEntryException{
        int min, max,count=0;
        if(_equalLines){
            min = ((_beginColumn <= _endColumn) ? _beginColumn:_endColumn);
            max = ((_beginColumn <= _endColumn) ? _endColumn:_beginColumn);
            for(int col = min; col <= max; col++){
                _spreadsheet.insertContents(String.format("%d;%d", _beginLine,col), contentSpecifications.get(count++));
            }
        }
        else{
            min = ((_beginLine <= _endLine) ? _beginLine:_endLine);
            max = ((_beginLine <= _endLine) ? _endLine:_beginLine);
            for(int lin = min; lin <= max; lin++){
                _spreadsheet.insertContents(String.format("%d;%d", lin, _beginColumn), contentSpecifications.get(count++));
            }
        }
    }

    public void deleteRange(){
        int min, max;

        if(_equalLines){
            min = ((_beginColumn <= _endColumn) ? _beginColumn:_endColumn);
            max = ((_beginColumn <= _endColumn) ? _endColumn:_beginColumn);
            for(int col = min; col <= max; col++){
                _spreadsheet.removeCell(_beginLine,col);
            }
        }
        else{
            min = ((_beginLine <= _endLine) ? _beginLine:_endLine);
            max = ((_beginLine <= _endLine) ? _endLine:_beginLine);
            for(int lin = min; lin <= max; lin++){
                _spreadsheet.removeCell(lin, _beginColumn);
            }
        }
    }

    public boolean getEqualLines(){return _equalLines;}
    public boolean getIsCell(){return _isCell;}
    public int getBeginLine(){return _beginLine;}
    public int getEndLine(){return _endLine;}
    public int getBeginColumn(){return _beginColumn;}
    public int getEndColumn(){return _endColumn;}

    public int getSize(){
        if(_equalLines){
            return Math.abs(_endColumn - _beginColumn);
        }
        else{
            return Math.abs(_endLine - _beginLine);
        }
    }
    
    public Literal accept(Visitor v){
        return v.visitRange(this);
    }
}
