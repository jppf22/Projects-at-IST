package xxl;

import java.io.Serial;
import java.io.Serializable;
import java.util.regex.Pattern;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Matcher;

import xxl.StorageMap.Coordinate;
import xxl.exceptions.InvalidRangeException;
import xxl.exceptions.UnrecognizedEntryException;

/**
 * Class representing a spreadsheet.
 */
public class Spreadsheet implements Serializable {

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private int _lines;
    private int _columns;
    private StorageStruct _cells; 
    private boolean _changed = true; 
    private Hashtable<String,User> _users = new Hashtable<String,User>();
    private User _root;
    private CutBuffer _cutbuffer = null;
    
    private LiteralVisitor _literalVisitor = new LiteralVisitor();
    private IntegerVisitor _intVisitor = new IntegerVisitor();
    private OutputVisitor _outVisitor = new OutputVisitor();

    public Spreadsheet(int lines, int columns){
        _lines = lines;
        _columns = columns;
        _cells = new StorageMap(lines, columns);
        _users.put("root", new User("root"));
        _root = _users.get("root");
    }

    public LiteralVisitor getLiteralVisitor(){return _literalVisitor;}
    public IntegerVisitor getIntegerVisitor(){return _intVisitor;}
    public OutputVisitor getOutputVisitor(){return _outVisitor;}

    public boolean getChanged(){ return _changed;}
    public void setChanged(boolean choice){_changed = choice;}
    
    public void addUser(User user){
        user.add(this);
        _users.put(user.getName(), user);
    }

    /**
     * Insert specified content in specified range.
     *
     * @param rangeSpecification
     * @param contentSpecification
     */
    public void insertContents(String rangeSpecification, String contentSpecification) throws UnrecognizedEntryException{
        ArrayList<Integer> rangeToInts = rangeToInts(rangeSpecification);
        try{
            Range range;
            boolean isRangeCell = false;
            if(rangeToInts.size() == 2){
                range = new Range(rangeToInts.get(0), rangeToInts.get(1), rangeToInts.get(0), rangeToInts.get(1),this);
                isRangeCell = true;
            }
            else{
                range = new Range(rangeToInts.get(0), rangeToInts.get(1), rangeToInts.get(2), rangeToInts.get(3),this);
            }

            if(!isRangeCell){
                range.setCells(contentSpecification);
            }

            int line = rangeToInts.get(0);
            int column = rangeToInts.get(1);

            if(contentSpecification == "" || contentSpecification == null){
                insertNull(line,column);
                return;
            }
    
            switch (contentSpecification.charAt(0)) {
                case '=':
                    if(Character.isDigit(contentSpecification.charAt(1))){
                        insertReference(line,column,contentSpecification);
                        break;
                    }
                    else if(Character.isLetter(contentSpecification.charAt(1))){
                        insertFunction(line,column,contentSpecification);
                        break;
                    }
                    
                case '\'':
                    insertString(line,column,contentSpecification);
                    break;
                case '-':
                    if(Character.isDigit(contentSpecification.charAt(1))){
                        insertInteger(line, column, contentSpecification);
                        break;
                    }
                default:
                    if(Character.isDigit(contentSpecification.charAt(0))){
                        insertInteger(line,column,contentSpecification);
                        break;
                    }
            } 
        }catch(InvalidRangeException e){
            throw new UnrecognizedEntryException(contentSpecification);
        }
    }
      
    public void insertNull(Range range){
        for(Cell cell : range.getCells()){
            cell.setContent(null);
        }
    }

    public void insertNull(int line, int column){
        _cells.setCell(line, column, null);
    }

    public void insertInteger(int line, int column, String contentSpecification){
        if(contentSpecification.matches("-?\\d+(\\.\\d+)?")){
                _cells.setCell(line, column, new LiteralInteger(Integer.parseInt(contentSpecification))); 
        }
    }

    public void insertString(int line, int column, String contentSpecification){
        _cells.setCell(line,column, new LiteralString(contentSpecification));
    }
    
    public void insertReference(int line, int column, String contentSpecification){
        
        Pattern pattern = Pattern.compile("\\d+");
        Matcher matcher = pattern.matcher(contentSpecification);

        matcher.find();
        int pointedLine = Integer.parseInt(matcher.group());
        matcher.find();
        int pointedColumn = Integer.parseInt(matcher.group());

        _cells.setCell(line, column, new Reference(pointedLine, pointedColumn,this));    
    }


    public void insertFunction(int line, int column, String contentSpecification) throws UnrecognizedEntryException{ 

        // Pattern to find the name of the function
        Pattern pattern = Pattern.compile("[A-Z]+");
        Matcher matcher = pattern.matcher(contentSpecification);

        if(matcher.find()){
            switch(matcher.group()){
                case "ADD":case "SUB":case "MUL":case "DIV": 
                    insertBinaryFunction(line, column, contentSpecification);
                    break;
                case "AVERAGE":case "PRODUCT":case "CONCAT": case "COALESCE":
                    insertIntervalFunction(line,column,contentSpecification);
                    break;
                default:
                    throw new UnrecognizedEntryException(contentSpecification);
            }
        }
    }

    public void insertBinaryFunction(int line, int column, String contentSpecification){

        // Pattern to find the arguments of the function
        Pattern pattern = Pattern.compile("\\d+(;\\d+)?");
        Matcher matcher = pattern.matcher(contentSpecification);
        Content[] arguments = new Content[2];
        for(int i=0; i < arguments.length; i++){
            if(matcher.find()){
                String argumentAsString = matcher.group();
                String[] argumentSplited = argumentAsString.split(";");
                if(argumentSplited.length == 1){
                    arguments[i] = new LiteralInteger(Integer.parseInt(argumentSplited[0]));
                }
                else{
                    arguments[i] = new Reference(Integer.parseInt(argumentSplited[0]), Integer.parseInt(argumentSplited[1]),this);
                }
            }
        }

        // Pattern to find the name of the function
        pattern = Pattern.compile("[A-Z]+");
        matcher = pattern.matcher(contentSpecification);

        if(matcher.find()){
            switch(matcher.group()){
                case "ADD":
                    _cells.setCell(line, column, new Add(arguments[0], arguments[1]));
                    break;
                case "SUB":
                    _cells.setCell(line, column, new Sub(arguments[0], arguments[1]));
                    break;
                case "DIV":
                    _cells.setCell(line, column, new Div(arguments[0], arguments[1]));
                    break;
                case "MUL":
                    _cells.setCell(line, column, new Mul(arguments[0], arguments[1]));
                    break;    
                default:
                    break;
            }
        }

    }

    public void insertIntervalFunction(int line, int column, String contentSpecification){
        ArrayList<Integer> intervalValues = new ArrayList<Integer>();
        Pattern pattern = Pattern.compile("\\d+");
        Matcher matcher = pattern.matcher(contentSpecification);
        while(matcher.find()){
            intervalValues.add(Integer.parseInt(matcher.group()));
        }

        // Pattern to find the name of the function
        pattern = Pattern.compile("[A-Z]+");
        matcher = pattern.matcher(contentSpecification);

        try{
            if(matcher.find()){
                switch(matcher.group()){
                    case "AVERAGE":
                        _cells.setCell(line, column, new Average(new Range(intervalValues.get(0), intervalValues.get(1), intervalValues.get(2), intervalValues.get(3), this)));
                        break; 
                    case "PRODUCT":
                        _cells.setCell(line, column, new Product(new Range(intervalValues.get(0), intervalValues.get(1), intervalValues.get(2), intervalValues.get(3), this)));
                        break;   
                    case "CONCAT":
                        _cells.setCell(line, column, new Concat(new Range(intervalValues.get(0), intervalValues.get(1), intervalValues.get(2), intervalValues.get(3), this)));
                        break;  
                    case "COALESCE":
                        _cells.setCell(line, column, new Coalesce(new Range(intervalValues.get(0), intervalValues.get(1), intervalValues.get(2), intervalValues.get(3), this)));
                        break;    
                    default:
                        break;
                }
            }
        }catch(InvalidRangeException e){}

    }

    public StorageStruct getCellStorageStruct(){
        return _cells;
    }

    public Cell getCell(int line, int column){
        return _cells.getCell(line, column);
    }

    public void setCell(int line, int column, Content content){
        _cells.setCell(line, column, content);
    }

    
    /**
     * Creates a List of Strings representing cells in a given range
     *
     * @param rangeSpecification given range as a String
     * @return the List of Strings
     */
    public List<String> showRange(String rangeSpecification) throws InvalidRangeException{
        ArrayList<Integer> values = rangeToInts(rangeSpecification);
        if(!ensureRangeValues(values)){
            throw new InvalidRangeException();
        }

        Range range;
        if(values.size() == 2){
            range = new Range(values.get(0),values.get(1),values.get(0),values.get(1),this);
        }
        else{
            range = new Range(values.get(0),values.get(1),values.get(2),values.get(3),this);
        }

        List<String> result = new ArrayList<String>();
        LiteralInteger nCells = (LiteralInteger) range.accept(_outVisitor);
        result = _outVisitor.toListStrings();
        result.add("The number of cells in the interval were: " + nCells.getValue());
        _outVisitor.resetStrings();
        return result;
    }
    
    ArrayList<Integer> rangeToInts(String rangeSpecification){
        String[] rangeValueString = rangeSpecification.split("[;:]");
        ArrayList<Integer> rangeValues = new ArrayList<>(rangeValueString.length);
        for(int i=0; i < rangeValueString.length; i++){
            rangeValues.add(i, Integer.parseInt(rangeValueString[i]));
        }
        return rangeValues;
    }
    
    /**
     * Checks if the given range values fit the defined dimensions
     *
     * @param values lines and columns of a certain range
     * @return wether lines and columns fit spreadSheet dimensions
     */
    public boolean ensureRangeValues(ArrayList<Integer> values){
        if(values.size() == 2){
            return values.get(0) > 0 && values.get(0) <= _lines && values.get(1) > 0 && values.get(1) <= _columns;
        }
        else if(values.size() == 4){
            return values.get(0) > 0 && values.get(0) <= _lines && values.get(1) > 0 && values.get(1) <= _columns && 
                values.get(2) > 0 && values.get(2) <= _lines && values.get(3) > 0 && values.get(3) <= _columns;
        }
        return false;
    }

    public EqualsValue getEqualsValue(String value){return new EqualsValue(value);}
    public EqualsFunction getEqualsFunction(String functionName){return new EqualsFunction(functionName);}
    public EqualsEvenValue getEqualsEvenValue(){return new EqualsEvenValue();}
    public EqualsReference getEqualsReference(){return new EqualsReference();}

    
    public List<String> search(Predicate p){
        List<String> _validCells = new ArrayList<String>();
        for(int i=1; i <= _lines; i++){
            for(int j=1; j <= _columns; j++){
                Cell cell = getCell(i, j);
                if(cell != null){
                    if(p.test(cell)){
                        try{
                            Range cellAsRange = new Range(i, j, i, j, this);
                            cellAsRange.accept(_outVisitor);
                            _validCells.addAll(_outVisitor.toListStrings());
                            _outVisitor.resetStrings();
                        }
                        catch(InvalidRangeException e){} //Won't happen
                    }
                }
            }
        }
        return _validCells;
    }
    
    public void deleteRange(String rangeSpecification) throws InvalidRangeException{
        ArrayList<Integer> values = rangeToInts(rangeSpecification);
        if(!ensureRangeValues(values)){
            throw new InvalidRangeException();
        }

        Range range;
        if(values.size() == 2){
            range = new Range(values.get(0),values.get(1),values.get(0),values.get(1),this);
        }
        else{
            range = new Range(values.get(0),values.get(1),values.get(2),values.get(3),this);
        }
        range.deleteRange();
    }

    public void removeCell(int line, int column){
        _cells.removeCell(line,column);
    }

    public void copy(String rangeSpecification) throws InvalidRangeException{
        ArrayList<Integer> values = rangeToInts(rangeSpecification);
        if(!ensureRangeValues(values)){
            throw new InvalidRangeException();
        }

        Range range;
        if(values.size() == 2){
            range = new Range(values.get(0),values.get(1),values.get(0),values.get(1),this);
        }
        else{
            range = new Range(values.get(0),values.get(1),values.get(2),values.get(3),this);
        }

        if(_cutbuffer == null){
            _cutbuffer = new CutBuffer(_lines, _columns);
        }
        _cutbuffer.copy(range, rangeSpecification);
    }

    public void cut(String rangeSpecification) throws InvalidRangeException{
        ArrayList<Integer> values = rangeToInts(rangeSpecification);
        if(!ensureRangeValues(values)){
            throw new InvalidRangeException();
        }

        Range range;
        if(values.size() == 2){
            range = new Range(values.get(0),values.get(1),values.get(0),values.get(1),this);
        }
        else{
            range = new Range(values.get(0),values.get(1),values.get(2),values.get(3),this);
        }

        if(_cutbuffer == null){
            _cutbuffer = new CutBuffer(_lines, _columns);
        }
        _cutbuffer.cut(range, rangeSpecification);
    }

    public void paste(String rangeSpecification) throws InvalidRangeException{
        ArrayList<Integer> values = rangeToInts(rangeSpecification);
        if(!ensureRangeValues(values)){
            throw new InvalidRangeException();
        }

        Range range;
        if(values.size() == 2){
            range = new Range(values.get(0),values.get(1),values.get(0),values.get(1),this);
        }
        else{
            range = new Range(values.get(0),values.get(1),values.get(2),values.get(3),this);
        }

        if(_cutbuffer == null){return;}
        _cutbuffer.paste(range);
    }

    public List<String> showCutBuffer(){
        if(_cutbuffer == null){return null;}
        _cutbuffer.getHoldingRange().accept(_outVisitor);
        List<String> results = _outVisitor.toListStrings();
        _outVisitor.resetStrings();
        return results;
    }
}
