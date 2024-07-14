package xxl;

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;
import xxl.exceptions.InvalidReferenceTarget;

public class IntegerVisitor implements Visitor,Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private int _result;

    public int getResult(){
        return _result;
    }

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

    //Nunca é chamado
    public Literal visitRange(Range range){
        return null;
    }

    public Literal visitLInteger(LiteralInteger lInteger){
        _result = lInteger.getValue();
        return null;
    }

    //Literal Strings can't be arguments of Binary Functions
    public Literal visitLString(LiteralString lString) throws InvalidFunctionArgument{
        throw new InvalidFunctionArgument(); 
    }

    public Literal visitReference(Reference reference)  throws InvalidCellValueException,InvalidFunctionArgument {
        try{
            Literal refTarget = reference.getRefTarget();
            refTarget.accept(this);
            return null;
        }
        catch(InvalidReferenceTarget e){
            throw new InvalidFunctionArgument();
        }
    }

    public Literal visitADD(Add add) throws InvalidFunctionArgument,InvalidCellValueException{
        int result = 0;
        add.left().accept(this);
        result += _result;
        add.right().accept(this);
        result = result + _result;
        _result = result;
        return null;
    }

    public Literal visitMUL(Mul mul) throws InvalidFunctionArgument,InvalidCellValueException{
        int result = 0;
        mul.left().accept(this);
        result += _result;
        mul.right().accept(this);
        result = result * _result;
        _result = result;
        return null;
    }

    public Literal visitSUB(Sub sub) throws InvalidFunctionArgument,InvalidCellValueException{
        int result = 0;
        sub.left().accept(this);
        result += _result;
        sub.right().accept(this);
        result = result - _result;
        _result = result;
        return null;
    }

    public Literal visitDIV(Div div) throws InvalidFunctionArgument,InvalidCellValueException{
        try{
            int result = 0;
            div.left().accept(this);
            result += _result;
            div.right().accept(this);
            result = result / _result;
            _result = result;
            return null;
        }
        catch(ArithmeticException e){
            throw new InvalidFunctionArgument();
        }
    }

    public Literal visitAVERAGE(Average average) throws InvalidCellValueException, InvalidFunctionArgument{
        int result = 0;
        ArrayList<Cell> cells = average.getCells().getCells();
        int max = cells.size();

        for(int ix=0; ix < max; ix++){
            if(cells.get(ix) == null){
                throw new InvalidFunctionArgument();
            }
            cells.get(ix).accept(this);
            result += _result;
        }
        _result = result / max;
        return null;
    }

    public Literal visitPRODUCT(Product product) throws InvalidCellValueException, InvalidFunctionArgument{
        int result = 1;
        for(Cell cell : product.getCells().getCells()){
            if(cell == null){
                throw new InvalidFunctionArgument();
            }
            cell.accept(this);
            result *= _result;
        }
        _result = result;
        return null;
    }

    public Literal visitCONCAT(Concat concat) throws InvalidCellValueException,InvalidFunctionArgument{
        throw new InvalidFunctionArgument();
    }

    public Literal visitCOALESCE(Coalesce coalesce) throws InvalidCellValueException,InvalidFunctionArgument{
        throw new InvalidFunctionArgument();
    }
}
