package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public interface Visitor {
    public abstract Literal visitCell(Cell cell) throws InvalidCellValueException,InvalidFunctionArgument;
    public abstract Literal visitRange(Range range);
    public abstract Literal visitLInteger(LiteralInteger lInteger);
    public abstract Literal visitLString(LiteralString lString)  throws InvalidFunctionArgument;
    public abstract Literal visitReference(Reference reference) throws InvalidCellValueException,InvalidFunctionArgument;

    public abstract Literal visitADD(Add add) throws InvalidCellValueException,InvalidFunctionArgument;
    public abstract Literal visitMUL(Mul mul) throws InvalidCellValueException,InvalidFunctionArgument;
    public abstract Literal visitSUB(Sub sub) throws InvalidCellValueException,InvalidFunctionArgument;
    public abstract Literal visitDIV(Div div) throws InvalidCellValueException,InvalidFunctionArgument;

    public abstract Literal visitAVERAGE(Average average) throws InvalidCellValueException, InvalidFunctionArgument;
    public abstract Literal visitPRODUCT(Product product) throws InvalidCellValueException, InvalidFunctionArgument;
    public abstract Literal visitCONCAT(Concat concat) throws InvalidCellValueException,InvalidFunctionArgument;
    public abstract Literal visitCOALESCE(Coalesce coalesce) throws InvalidCellValueException,InvalidFunctionArgument;
}
