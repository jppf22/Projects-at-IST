package xxl;

import java.io.Serial;
import java.io.Serializable;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public abstract class Content implements Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    public abstract Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException;
}
