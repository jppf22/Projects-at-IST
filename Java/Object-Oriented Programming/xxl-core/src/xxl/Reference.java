package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;
import xxl.exceptions.InvalidReferenceTarget;

public class Reference extends Content {
    private Spreadsheet _spreadsheet; 
    private int _line;
    private int _column;

    public Reference(int line, int column, Spreadsheet spreadsheet){
        _line = line;
        _column = column;
        _spreadsheet = spreadsheet;
    }

    public int getLine(){return _line;}
    public int getColumn(){return _column;}
    
    public Literal getRefTarget() throws InvalidReferenceTarget,InvalidFunctionArgument {
        try{
            Cell cell = _spreadsheet.getCell(_line, _column);
            if(cell != null){   //uma referência não pode apontar para nada
                Content contentPointingTo = cell.getContent();
                if(contentPointingTo == null || this.equals(contentPointingTo)){
                    throw new InvalidReferenceTarget(); //will be catched somwhere to display #VALUE
                }
                return cell.accept(_spreadsheet.getLiteralVisitor());
            }
            throw new InvalidReferenceTarget();
        }
        catch(InvalidCellValueException e){
            throw new InvalidReferenceTarget();
        }
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitReference(this);
    }

    /*
    @Override
    Literal value(){
        Cell cell = _cells.getCell(_line, _column);
        if(cell != null){
            Content contentPointingTo = _cells.getCell(_line, _column).getContent();
            if(contentPointingTo == null | equals(contentPointingTo)){
                return new LiteralString("#VALUE");
            }
            return contentPointingTo.value();
        }
        return new LiteralString("#VALUE");
    }

    @Override
    public String toString(){
        return String.format("%s=%d;%d",value().asString(),_line,_column);
    }

    @Override
    public String asString(){
        return String.format("%d;%d",_line,_column);
    }

    @Override
    public int asInt(){
        return value().asInt();
    }
    */
    
    @Override
    public boolean equals(Object o){
        if(o instanceof Reference ref){
            return _line == ref._line && _column == ref._column;
        }
        return false;
    }
}
