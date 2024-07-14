package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class EqualsEvenValue implements Predicate{

    public boolean test(Cell cell){
        try{
            OutputVisitor outputVisitor = new OutputVisitor();
            cell.accept(outputVisitor);
            String cellString = outputVisitor.toString();
            int indexOfEquals = cellString.indexOf('=');
            int value;
            if(indexOfEquals != -1)
                value = Integer.parseInt(cellString.substring(0, indexOfEquals));
            else
                value = Integer.parseInt(cellString);

            return value % 2 == 0;

        }catch(InvalidCellValueException | InvalidFunctionArgument | NumberFormatException e){
            return false;
        }
    }
}
