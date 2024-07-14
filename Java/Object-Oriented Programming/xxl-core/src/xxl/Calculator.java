package xxl;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.Dictionary;
import java.util.Hashtable;
import java.io.ObjectInputStream;

import xxl.exceptions.ImportFileException;
import xxl.exceptions.MissingFileAssociationException;
import xxl.exceptions.UnavailableFileException;
import xxl.exceptions.UnrecognizedEntryException;




/**
 * Class representing a spreadsheet application.
 */
public class Calculator {
    
    private String _filename = "";
    private Spreadsheet _spreadsheet = null;
    private User _active = new User("root"); /* O user default que tá ativo é a root */
    private Dictionary<String,User> _users = new Hashtable<String,User>();

    public Calculator(){
        _users.put(_active.getName(),_active);
    }

    //FIXME - adicionar métodos calculadora parra impedir breaches do core

    /**
     * Saves the serialized application's state into the file associated to the current network.
     *
     * @throws FileNotFoundException if for some reason the file cannot be created or opened. 
     * @throws MissingFileAssociationException if the current network does not have a file.
     * @throws IOException if there is some error while serializing the state of the network to disk.
     */
    public void save() throws FileNotFoundException, MissingFileAssociationException, IOException {
        if(!_spreadsheet.getChanged())
            return; 
        if(_filename == null || _filename.equals("")) //FIXME- segundo check necessário?
            throw new MissingFileAssociationException();
        try (ObjectOutputStream oos = new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(_filename)))){
            oos.writeObject(_spreadsheet);
            _spreadsheet.setChanged(false);
        }
    }

    /**
     * Saves the serialized application's state into the specified file. The current network is
     * associated to this file.
     *
     * @param filename the name of the file.
     * @throws FileNotFoundException if for some reason the file cannot be created or opened.
     * @throws MissingFileAssociationException if the current network does not have a file.
     * @throws IOException if there is some error while serializing the state of the network to disk.
     */
    public void saveAs(String filename) throws FileNotFoundException, MissingFileAssociationException, IOException {
        _filename = filename;
        _spreadsheet.setChanged(true);
        save();
    }

    /**
     * @param filename name of the file containing the serialized application's state
     *        to load.
     * @throws UnavailableFileException if the specified file does not exist or there is
     *         an error while processing this file.
     */
    public void load(String filename) throws UnavailableFileException {
        _filename = filename;
        try(ObjectInputStream ois = new ObjectInputStream(new BufferedInputStream(new FileInputStream(filename)))){
            _spreadsheet  = (Spreadsheet) ois.readObject();
            _spreadsheet.addUser(_active);
            _spreadsheet.setChanged(false);
        } catch(IOException | ClassNotFoundException e){ 
            throw new UnavailableFileException(filename);
        }
    }

    /**
     * Read text input file and create domain entities..
     *
     * @param filename name of the text input file
     * @throws ImportFileException
     */
    public void importFile(String filename) throws ImportFileException {
        try {
            BufferedReader in = new BufferedReader(new FileReader(filename));
            String line;
            int lines, columns;
            lines = Integer.valueOf(((in.readLine()).split("linhas="))[1]);     
            columns = Integer.valueOf(((in.readLine()).split("colunas="))[1]);  
            _spreadsheet = new Spreadsheet(lines, columns);
            _spreadsheet.addUser(_active);
            while((line = in.readLine()) != null){
                String[] fields = line.split("\\|");
                if(fields.length == 1){     //if there are any empty cells in the import file
                    _spreadsheet.insertContents(fields[0], "");
                    continue;
                } 
                _spreadsheet.insertContents(fields[0],fields[1]);               
            }
            //_spreadsheet.setChanged(false); 
            in.close();
        } catch (IOException | UnrecognizedEntryException e) {
            throw new ImportFileException(filename, e);
        }
    }

    /**
     * Create new Spreadsheet with given dimensions
     * 
     * @param lines number of lines the sheet will have
     * @param columns number of columns the sheet will have
    */
    public void createNewSpreadsheet(int lines, int columns){
        _spreadsheet = new Spreadsheet(lines, columns);
        _spreadsheet.addUser(_active);
    }

    public Spreadsheet getSpreadsheet(){
        return _spreadsheet;
    }

    public boolean getSpreadsheetChanged(){
        if(getSpreadsheet() != null)
            return _spreadsheet.getChanged();
        return false;
    }

    public String getFilename(){
        return _filename;
    }

    public void setFilename(String filename){
        _filename = filename;
    }

    public void createNewUser(String name){
        _users.put(name, new User(name));
        _active = _users.get(name);
    }
}
