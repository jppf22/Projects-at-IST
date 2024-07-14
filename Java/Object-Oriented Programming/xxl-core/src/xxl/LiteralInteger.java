package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class LiteralInteger extends Literal{
    private int _value;

    public LiteralInteger(int value){
        _value = value;
    }

    public int getValue(){
        return _value;
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitLInteger(this);
    }

}
