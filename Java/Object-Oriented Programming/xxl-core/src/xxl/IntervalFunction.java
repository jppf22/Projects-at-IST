package xxl;

public abstract class IntervalFunction extends Function{
    private Range _cells;

    public IntervalFunction(Range cells){
        _cells = cells;
    }

    public Range getCells(){
        return _cells;
    }

    public String getRangeAsString(){
        return String.format("%d;%d:%d;%d",_cells.getBeginLine(),_cells.getBeginColumn(),_cells.getEndLine(),_cells.getEndColumn());
    }
}
