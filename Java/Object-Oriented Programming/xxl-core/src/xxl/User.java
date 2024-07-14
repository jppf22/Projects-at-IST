package xxl;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;
import java.util.ArrayList;

public class User implements Serializable{

    @Serial
    private static final long serialVersionUID = 202308312359L;

    private String _name;
    private List<Spreadsheet> _sheets = new ArrayList<Spreadsheet>();

    public User(String name){
        _name = name;
    }

    Spreadsheet getSheet(int index){
        return _sheets.get(index);
    }

    void add(Spreadsheet sheet){
        _sheets.add(sheet);
    }

    public String getName(){
        return _name;
    }

    @Override
    public boolean equals(Object obj){
        if(obj instanceof User user){
            return _name == user._name;
        }
        return false;
    }
}
