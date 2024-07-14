package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Average extends IntervalFunction{
    public Average(Range range){
        super(range);
        setName("Average");
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument, InvalidCellValueException{
        return v.visitAVERAGE(this);
    }
}
