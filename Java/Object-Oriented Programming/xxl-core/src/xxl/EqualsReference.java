package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class EqualsReference implements Predicate{

    public boolean test(Cell cell){
        try{
            if(cell.getContent() != null){
                OutputVisitor outputVisitor = new OutputVisitor();
                cell.accept(outputVisitor);
                String cellString = outputVisitor.toString();
                if(cellString != ""){
                    int indexOfEquals = cellString.indexOf('=');
                    if(indexOfEquals != -1){
                        return cellString.substring(indexOfEquals,cellString.length()).matches("=\\d+;\\d+");
                    }
                    else{
                        return false;
                    }
                }
            }
            return false;
        }
        catch(InvalidCellValueException | InvalidFunctionArgument e){
            return false;
        }
    }

}