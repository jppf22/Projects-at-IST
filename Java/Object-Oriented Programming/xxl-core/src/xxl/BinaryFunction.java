package xxl;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public abstract class BinaryFunction extends Function{
    private Content _left,_right;

    public BinaryFunction(Content argument1,Content argument2){
        _left = argument1;
        _right = argument2;
    }
    
    public Content left(){return _left;}
    public Content right(){return _right;}

    //FIX feio para obter argumentos em forma de String (ou intervalo ou int)
    public String getArgAsString(Content arg){
        try{
            OutputVisitor v = new OutputVisitor(); 
            arg.accept(v); 
            String res = v.toString();
            try{
                Integer.parseInt(res);
                return res; //retorna um inteiro
            }catch(NumberFormatException e){
                Pattern refRegex = Pattern.compile("\\d+;\\d+");
                Matcher matcher = refRegex.matcher(res);
                matcher.find();
                return matcher.group(); //retorna uma coordenada
            }
        }
        catch(InvalidCellValueException | InvalidFunctionArgument e){
            return "THIS WILL LITERALLY NEVER HAPPEN.";
        }
    }
 
}
