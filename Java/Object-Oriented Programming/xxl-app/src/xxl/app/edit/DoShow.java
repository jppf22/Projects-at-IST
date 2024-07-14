package xxl.app.edit;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import pt.tecnico.uilib.menus.CommandException;
import xxl.Spreadsheet;
import xxl.exceptions.InvalidRangeException;

// FIXME import classes

/**
 * Class for searching functions.
 */
class DoShow extends Command<Spreadsheet> {

    DoShow(Spreadsheet receiver) {
        super(Label.SHOW, receiver);
        // FIXME add fields
    }

    @Override
    protected final void execute() throws CommandException {
        String rangeSpecification = Form.requestString(Prompt.address());
         try{ 
            _display.popup(_receiver.showRange(rangeSpecification));
         }
         catch(InvalidRangeException e){
             throw new InvalidCellRangeException(rangeSpecification);
         }
    }

}
