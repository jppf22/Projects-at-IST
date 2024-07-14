package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Div extends BinaryFunction{
    public Div(Content argument1, Content argument2){
        super(argument1,argument2);
        setName("DIV");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitDIV(this);
    }
}
