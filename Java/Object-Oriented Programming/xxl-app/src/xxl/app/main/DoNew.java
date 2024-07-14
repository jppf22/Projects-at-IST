package xxl.app.main;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import pt.tecnico.uilib.menus.CommandException;
import xxl.Calculator;

/**
 * Open a new file.
 */
class DoNew extends Command<Calculator> {

    DoNew(Calculator receiver) {
        super(Label.NEW, receiver);
    }

    @Override
    protected final void execute() throws CommandException {
        if(_receiver.getSpreadsheetChanged()){  
            boolean choice = Form.confirm(Prompt.saveBeforeExit());
            if(choice){
                new DoSave(_receiver).execute();
            }
        }

        int lines = Integer.parseInt(Form.requestString(Prompt.lines()));
        int columns = Integer.parseInt(Form.requestString(Prompt.columns()));
        _receiver.createNewSpreadsheet(lines, columns);
    }

}
