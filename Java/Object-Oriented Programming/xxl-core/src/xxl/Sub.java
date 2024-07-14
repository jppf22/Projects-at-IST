package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Sub extends BinaryFunction{
    public Sub(Content argument1, Content argument2){
        super(argument1,argument2);
        setName("SUB");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitSUB(this);
    }
}