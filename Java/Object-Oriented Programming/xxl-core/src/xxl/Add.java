package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Add extends BinaryFunction{
    public Add(Content argument1, Content argument2){
        super(argument1,argument2);
        setName("ADD");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitADD(this);
    }
}
