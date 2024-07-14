package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class LiteralString extends Literal{
    private String _value;

    public LiteralString(String value){
        _value = value;
    }

    public String getValue(){return _value;}

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitLString(this);
    }
}
