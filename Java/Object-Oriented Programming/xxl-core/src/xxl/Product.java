package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Product extends IntervalFunction{
    public Product(Range range){
        super(range);
        setName("Product");
    }

    public Literal accept(Visitor v) throws InvalidCellValueException, InvalidFunctionArgument{
        return v.visitPRODUCT(this);
    }
}
