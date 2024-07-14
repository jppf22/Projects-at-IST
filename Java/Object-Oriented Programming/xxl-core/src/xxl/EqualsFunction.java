package xxl;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class EqualsFunction implements Predicate{

    private String _functionName="";

    public EqualsFunction(String functionName){
        _functionName = functionName;
    }

    public boolean test(Cell cell){
        try{
            if(cell.getContent() != null && _functionName != ""){
                OutputVisitor outputVisitor = new OutputVisitor();
                cell.accept(outputVisitor);
                String cellString = outputVisitor.toString();
                if(cellString != "" && cellString.length() >= _functionName.length()){
                    if(cellString.contains(_functionName)){
                        return true;
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
