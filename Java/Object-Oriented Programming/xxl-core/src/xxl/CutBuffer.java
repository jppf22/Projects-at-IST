package xxl;

import java.io.Serial;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import xxl.exceptions.InvalidCellValueException;
import xxl.exceptions.InvalidFunctionArgument;
import xxl.exceptions.InvalidRangeException;
import xxl.exceptions.UnrecognizedEntryException;

public class CutBuffer implements Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private Spreadsheet _spreadsheet;
    private Range _holdingRange = null;

    public CutBuffer(int lines, int columns){
        _spreadsheet = new Spreadsheet(lines, columns);
    }

    public Range getHoldingRange(){return _holdingRange;}

    public void copy(Range range, String contentSpecification){
        int beginLine = 1;
        int beginColumn = 1;
        int endLine;
        int endColumn;
        if(range.getIsCell()){
            endLine = 1;
            endColumn = 1;
        }
        else if(range.getEqualLines()){
            endLine = 1;
            endColumn = Math.abs(range.getEndColumn()-range.getBeginColumn()) + 1;
        }
        else{
            endLine = Math.abs(range.getEndLine()-range.getBeginLine()) + 1;
            endColumn = 1;
        }

        try{
            _holdingRange = new Range(beginLine, beginColumn, endLine, endColumn, _spreadsheet);
            ArrayList<String> contentSpecifications = new ArrayList<String>();
            OutputVisitor oVisitor = new OutputVisitor();
            for(Cell cell : range.getCells()){
                try{
                    cell.accept(oVisitor);
                }catch(InvalidFunctionArgument | InvalidCellValueException e){}
                
                String result = oVisitor.toString();
                if(result.contains("=")){
                    //This process happens because updating the coordinates to their new spreadsheet values is needed
                    result = result.substring(result.indexOf("="), result.length());
                    int fixForCoordinates; //this will subtract the non-equal ones
                    int constantNumber; //This will replace the equal ones
                    if(range.getEqualLines()){
                        fixForCoordinates = range.getBeginColumn() - beginColumn;
                        constantNumber = range.getBeginLine();
                    }
                    else{
                        fixForCoordinates = range.getBeginLine() - beginLine;
                        constantNumber = range.getBeginColumn();
                    }

                    Pattern pattern = Pattern.compile("\\d+");
                    Matcher matcher = pattern.matcher(result);
                    StringBuilder fixedString = new StringBuilder();
                    int lastIndex = 0;
                    
                    //Assumindo que se deve atualizar o número da ref e da função
                    while(matcher.find()){
                        String nString = matcher.group();
                        int thisIndex = matcher.start();
                        int number = Integer.parseInt(nString);
                        if(result.charAt(thisIndex-1) == ';' || result.charAt(thisIndex+1) == ';'){
                            if(number == constantNumber) 
                                number = 1;
                            else{
                                number = number - fixForCoordinates;
                            }
                        }
                        fixedString.append(result,lastIndex,thisIndex);
                        fixedString.append(number);
                        lastIndex = matcher.end();
                    }
                    fixedString.append(result,lastIndex,result.length());
                    contentSpecifications.add(fixedString.toString());
                }
                else{
                    contentSpecifications.add(result);
                }
            
                oVisitor.resetString();
            }
            try{
                _holdingRange.setCells(contentSpecifications);
            }catch(UnrecognizedEntryException e){}

        }catch(InvalidRangeException e){} //Se chegou ao cutbuffer está válido
    }

    public void delete(){
        _holdingRange.deleteRange();
        _holdingRange = null;
    }

    public void cut(Range range, String contentSpecification){
        copy(range,contentSpecification);
        range.deleteRange();
    }

    public void paste(Range range){
        if(_holdingRange == null){return;}
        // FIXME - cell individual método
        if(range.getEqualLines() == _holdingRange.getEqualLines() && range.getSize() == _holdingRange.getSize()){
            ArrayList<String> contentSpecifications = new ArrayList<String>();
            OutputVisitor oVisitor = new OutputVisitor();
            for(Cell cell : _holdingRange.getCells()){
                try{
                    cell.accept(oVisitor);
                }catch(InvalidFunctionArgument | InvalidCellValueException e){}

                String result = oVisitor.toString();
                contentSpecifications.add(result.substring(result.indexOf('='), result.length())); //may need a +1 on index and -1 on length
                oVisitor.resetString();
            }
            try{
                range.setCells(contentSpecifications);
            }catch(UnrecognizedEntryException e){}
        }
        delete();
    }
}
