package xxl.app.main;

import java.io.FileNotFoundException;
import java.io.IOException;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import pt.tecnico.uilib.menus.CommandException;
import xxl.Calculator;

import xxl.exceptions.MissingFileAssociationException;

/**
 * Save to file under current name (if unnamed, query for name).
 */
class DoSave extends Command<Calculator> {

    DoSave(Calculator receiver) {
        super(Label.SAVE, receiver, xxl -> xxl.getSpreadsheet() != null);
    }

    @Override
    protected final void execute() throws CommandException{
        
        try{ 
            if(_receiver.getFilename() == ""){
                String fileName = Form.requestString(Prompt.newSaveAs());
                _receiver.saveAs(fileName);
            }
        }catch(FileNotFoundException | MissingFileAssociationException e){
            throw new FileOpenFailedException(e);
        }
        catch(IOException e){
            throw new FileOpenFailedException(e);
        }
    }

}
