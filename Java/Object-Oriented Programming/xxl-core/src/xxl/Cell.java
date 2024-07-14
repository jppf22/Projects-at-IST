package xxl;

import java.io.Serial;
import java.io.Serializable;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;

public class Cell implements Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;


    private Content _content = null; 
    
    //FIXME - observer
    public void setContent(Content content){
        _content = content;
    }
    
    public Content getContent(){
        return _content;
    }

    public Literal accept(Visitor v) throws InvalidFunctionArgument,InvalidCellValueException{
        return v.visitCell(this);
    }
}
