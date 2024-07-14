package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Coalesce extends IntervalFunction{
    public Coalesce(Range range){
        super(range);
        setName("Coalesce");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument, InvalidCellValueException{
        return v.visitCOALESCE(this);
    }
}
