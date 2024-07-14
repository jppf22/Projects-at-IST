package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Mul extends BinaryFunction{
    public Mul(Content argument1, Content argument2){
        super(argument1,argument2);
        setName("MUL");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitMUL(this);
    }
}