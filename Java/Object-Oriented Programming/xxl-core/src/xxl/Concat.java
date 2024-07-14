package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Concat extends IntervalFunction{
    public Concat(Range range){
        super(range);
        setName("Concat");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument, InvalidCellValueException{
        return v.visitCONCAT(this);
    }
}
