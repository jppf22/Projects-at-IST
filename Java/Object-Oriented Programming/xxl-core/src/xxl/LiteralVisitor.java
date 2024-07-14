package xxl;

import java.io.Serial;
import java.io.Serializable;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;
import xxl.exceptions.InvalidReferenceTarget;

public class LiteralVisitor implements Visitor,Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private IntegerVisitor _intVisitor = new IntegerVisitor();
    private OutputVisitor _oVisitor = new OutputVisitor();
    
    public Literal visitCell(Cell cell)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            if(cell != null){
                Content content = cell.getContent();
                if(content != null){
                    return content.accept(this);
                }
                return null;
            }
            return null;
        }catch(InvalidCellValueException e){
            throw new InvalidCellValueException();
        }
    }

    
    public Literal visitRange(Range range){
        return null; //Never happens
    }

    public Literal visitLInteger(LiteralInteger lInteger){
        return lInteger;
    }

    public Literal visitLString(LiteralString lString)  throws InvalidFunctionArgument{
        return lString;
    }

    public Literal visitReference(Reference reference)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            return reference.getRefTarget();
        }catch(InvalidReferenceTarget e){
            throw new InvalidCellValueException();
        }
    }

    public Literal visitADD(Add add)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            add.accept(_intVisitor);
            int result = _intVisitor.getResult();
            return new LiteralInteger(result);
        }catch(InvalidFunctionArgument e){
            throw new InvalidCellValueException();
        }
    }

    public Literal visitMUL(Mul mul)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            mul.accept(_intVisitor);
            int result = _intVisitor.getResult();
            return new LiteralInteger(result);
        }catch(InvalidFunctionArgument e){
            throw new InvalidCellValueException();
        }
    }

    public Literal visitSUB(Sub sub)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            sub.accept(_intVisitor);
            int result = _intVisitor.getResult();
            return new LiteralInteger(result);
        }catch(InvalidFunctionArgument e){
            throw new InvalidCellValueException();
        }
    }

    public Literal visitDIV(Div div)  throws InvalidCellValueException,InvalidFunctionArgument{
        try{
            div.accept(_intVisitor);
            int result = _intVisitor.getResult();
            return new LiteralInteger(result);
        }catch(InvalidFunctionArgument | ArithmeticException e){ //FIXME -- será que dá para / 0
            throw new InvalidCellValueException();
        }
    }

    public Literal visitAVERAGE(Average average) throws InvalidCellValueException, InvalidFunctionArgument{
        try{
            average.accept(_intVisitor);
            int result = _intVisitor.getResult();
            return new LiteralInteger(result);
        }catch(InvalidFunctionArgument e){
            throw new InvalidCellValueException();
        }
    }

    public Literal visitPRODUCT(Product product) throws InvalidCellValueException, InvalidFunctionArgument{
        try{
            product.accept(_intVisitor);
            int result = _intVisitor.getResult();
            return new LiteralInteger(result);
        }catch(InvalidFunctionArgument e){
            throw new InvalidCellValueException();
        }
    }

    public Literal visitCONCAT(Concat concat) throws InvalidCellValueException,InvalidFunctionArgument{
        concat.accept(_oVisitor);
        String concatResult = _oVisitor.toString();
        _oVisitor.resetString();
        int indexOfEquals = concatResult.indexOf('=');
        return new LiteralString(concatResult.substring(0,indexOfEquals));
    }


    public Literal visitCOALESCE(Coalesce coalesce) throws InvalidCellValueException,InvalidFunctionArgument{
        coalesce.accept(_oVisitor);
        String coalesceResult = _oVisitor.toString();
        _oVisitor.resetString();
        int indexOfEquals = coalesceResult.indexOf('=');
        return new LiteralString(coalesceResult.substring(0, indexOfEquals));
    }
}
