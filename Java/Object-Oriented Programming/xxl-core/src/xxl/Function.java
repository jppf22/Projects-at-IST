package xxl;

public abstract class Function extends Content{
    private String _name;
    public String getName(){
        return _name;
    }

    protected void setName(String name){
        _name = name;
    }
}
