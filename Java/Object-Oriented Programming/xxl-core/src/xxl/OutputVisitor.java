package xxl;

import java.util.List;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;
import xxl.exceptions.InvalidReferenceTarget;

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;

public class OutputVisitor implements Visitor,Serializable{
    
    /*
     * The returns of the visit methods don't matter since methods
     * toString and toListStrings are the ones that will be called
     * whenever output is wanted
     */

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private String _currentString ="";
    private ArrayList<String> _currentStrings = new ArrayList<String>();
    private IntegerVisitor _intVisitor = new IntegerVisitor();

    public Literal visitCell(Cell cell) throws InvalidCellValueException,InvalidFunctionArgument{
        if(cell != null){
            Content content = cell.getContent();
            if(content != null){
                content.accept(this);
            }
            return null;
        }
        return null;
    }

    public Literal visitRange(Range range){
        try{
            ArrayList<Cell> cells = range.getCells();
            int start, constant;
            int cellCount = 0;

            if(range.getEqualLines()){
                constant = range.getBeginLine();
                start = (range.getBeginColumn() <= range.getEndColumn()) ? range.getBeginColumn():range.getEndColumn(); 
                for(Cell cell : cells){
                    if(cell != null){
                        cell.accept(this); //_currentString will be populated with the output of the Cell content
                        _currentString = String.format("%d;%d|",constant,start) + toString();
                        _currentStrings.add(_currentString);
                    }
                    else{
                        _currentString = String.format("%d;%d|",constant,start);
                        _currentStrings.add(_currentString);
                    }
                    resetString();  //we need to empty _currentString afterwards
                    cellCount++;
                    start++;
                }
            }
            else{
                constant = range.getBeginColumn();
                start = (range.getBeginLine() <= range.getEndLine()) ? range.getBeginLine():range.getEndLine(); 
                for(Cell cell : cells){
                    if(cell != null){
                        cell.accept(this); //_currentString will be populated with the output of the Cell content
                        _currentString = String.format("%d;%d|",start,constant) + toString();
                        _currentStrings.add(_currentString);
                    }
                    else{
                        _currentString = String.format("%d;%d|",constant,start);
                        _currentStrings.add(_currentString);
                    }
                    cellCount++;
                    resetString(); //we need to empty _currentString afterwards
                    start++;
                }
            }
            return new LiteralInteger(cellCount); //instead of returning null it returns a literal int corresponding to the cells in the range
        }catch(InvalidCellValueException | InvalidFunctionArgument e){
            // Never happens!!!!
            return null;
        }
    }

    public Literal visitLInteger(LiteralInteger lInteger){
        _currentString += Integer.toString(lInteger.getValue());
        return null;
    }

    public Literal visitLString(LiteralString lString)  throws InvalidFunctionArgument{
        _currentString += lString.getValue();
        return null;
    }

    public Literal visitReference(Reference reference)  throws InvalidCellValueException,InvalidFunctionArgument {
        try{
            Literal refTarget = reference.getRefTarget();
            if(refTarget != null){
                refTarget.accept(this);
                _currentString += String.format("=%d;%d",reference.getLine(),reference.getColumn());
            }
            return null; 
        }catch(InvalidReferenceTarget | InvalidFunctionArgument e){
            _currentString += String.format("#VALUE=%d;%d",reference.getLine(),reference.getColumn());
            return null; 
        }
    }

    
    public Literal visitADD(Add add)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            add.accept(_intVisitor);
            int result = _intVisitor.getResult();
            _currentString += String.format("%d=ADD(%s,%s)",result,add.getArgAsString(add.left()),add.getArgAsString(add.right()));
            return null;
        }catch(InvalidFunctionArgument e){
            _currentString += String.format("#VALUE=ADD(%s,%s)",add.getArgAsString(add.left()),add.getArgAsString(add.right()));
            return null;
        }
    }

    public Literal visitMUL(Mul mul)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            mul.accept(_intVisitor);
            int result = _intVisitor.getResult();
            _currentString += String.format("%d=MUL(%s,%s)",result,mul.getArgAsString(mul.left()),mul.getArgAsString(mul.right()));
            return null;
        }catch(InvalidFunctionArgument e){
            _currentString += String.format("#VALUE=MUL(%s,%s)",mul.getArgAsString(mul.left()),mul.getArgAsString(mul.right()));
            return null;
        }
    }
    public Literal visitSUB(Sub sub)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            sub.accept(_intVisitor);
            int result = _intVisitor.getResult();
            _currentString += String.format("%d=SUB(%s,%s)",result,sub.getArgAsString(sub.left()),sub.getArgAsString(sub.right()));
            return null;
        }catch(InvalidFunctionArgument e){
            _currentString += String.format("#VALUE=SUB(%s,%s)",sub.getArgAsString(sub.left()),sub.getArgAsString(sub.right()));
            return null;
        }
    }

    public Literal visitDIV(Div div)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            div.accept(_intVisitor);
            int result = _intVisitor.getResult();
            _currentString += String.format("%d=DIV(%s,%s)",result,div.getArgAsString(div.left()),div.getArgAsString(div.right()));
            return null;
        }catch(InvalidFunctionArgument e){ 
            _currentString += String.format("#VALUE=DIV(%s,%s)",div.getArgAsString(div.left()),div.getArgAsString(div.right()));
            return null;
        }
    }

    public Literal visitAVERAGE(Average average) throws InvalidCellValueException, InvalidFunctionArgument{
        try{
            average.accept(_intVisitor);
            int result = _intVisitor.getResult();
            _currentString += String.format("%d=AVERAGE(%s)",result,average.getRangeAsString());
            return null;
        }catch(InvalidFunctionArgument e){
            _currentString += String.format("#VALUE=AVERAGE(%s)",average.getRangeAsString());
            return null;
        }
    }

    public Literal visitPRODUCT(Product product) throws InvalidCellValueException, InvalidFunctionArgument{
        try{
            product.accept(_intVisitor);
            int result = _intVisitor.getResult();
            _currentString += String.format("%d=PRODUCT(%s)",result,product.getRangeAsString());
            return null;  
        }catch(InvalidFunctionArgument e){
            _currentString += String.format("#VALUE=PRODUCT(%s)",product.getRangeAsString());
            return null;
        }
    }

    public Literal visitCONCAT(Concat concat) throws InvalidCellValueException,InvalidFunctionArgument{
        String result = "";
        OutputVisitor oVisitor = new OutputVisitor();
        LiteralVisitor lVisitor = new LiteralVisitor();

        for(Cell cell : concat.getCells().getCells()){
            if(cell != null){
                try{
                    Literal cellLiteral = cell.accept(lVisitor);
                    cellLiteral.accept(oVisitor);  
                    String cellLiteralString = oVisitor.toString();
                    oVisitor.resetString();

                    if(cellLiteralString.charAt(0) == '\''){
                        // This is done so there is only one ' in the final String
                        result += cellLiteralString.replace("'","");
                    }
                }
                catch(InvalidCellValueException | InvalidFunctionArgument e){}
            }
        }

        _currentString += "'" + String.format("%s=CONCAT(%s)",result,concat.getRangeAsString());
        return null;
    }

    public Literal visitCOALESCE(Coalesce coalesce) throws InvalidCellValueException,InvalidFunctionArgument{
        String result="";
        
        OutputVisitor oVisitor = new OutputVisitor();
        LiteralVisitor lVisitor = new LiteralVisitor();

        for(Cell cell : coalesce.getCells().getCells()){
            if(cell != null){
                try{
                    Literal cellLiteral = cell.accept(lVisitor);
                    cellLiteral.accept(oVisitor);  
                    String cellLiteralString = oVisitor.toString();
                    oVisitor.resetString();

                    if(cellLiteralString.charAt(0) == '\''){
                        // This is done so there is only one ' in the final String
                        result += cellLiteralString.replace("'","");
                        break; //we only need the first String
                    }
                }
                catch(InvalidCellValueException | InvalidFunctionArgument e){}
            }
        }
        _currentString += "'" + String.format("%s=COALESCE(%s)",result,coalesce.getRangeAsString());
        return null;
    }


    @Override
    public String toString(){
        return _currentString;
    }

    public List<String> toListStrings(){
        return _currentStrings;
    }

    public void resetString(){
        _currentString = "";
    }

    public void resetStrings(){
        _currentStrings = new ArrayList<String>();
    }
}
