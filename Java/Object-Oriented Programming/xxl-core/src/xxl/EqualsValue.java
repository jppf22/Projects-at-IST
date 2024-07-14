package xxl;


import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class EqualsValue implements Predicate{

    private String _value;

    public EqualsValue(String value){_value = value;}

    public boolean test(Cell cell){
        try{
            OutputVisitor outputVisitor = new OutputVisitor();
            cell.accept(outputVisitor);
            String cellString = outputVisitor.toString();
            int indexOfEquals = cellString.indexOf('=');
            if(indexOfEquals != -1){
                return cellString.substring(0, indexOfEquals).equals(_value);
            }
            else{
                return cellString.equals(_value);
            }
        }catch(InvalidCellValueException | InvalidFunctionArgument e){
            return false;
        }
    }
}
