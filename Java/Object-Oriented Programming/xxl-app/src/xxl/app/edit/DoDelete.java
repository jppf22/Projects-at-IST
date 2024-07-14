package xxl.app.edit;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import pt.tecnico.uilib.menus.CommandException;
import xxl.Spreadsheet;
import xxl.exceptions.InvalidRangeException;

/**
 * Delete command.
 */
class DoDelete extends Command<Spreadsheet> {

    DoDelete(Spreadsheet receiver) {
        super(Label.DELETE, receiver);
        
    }

    @Override
    protected final void execute() throws CommandException {
        String rangeSpecification = Form.requestString(Prompt.address());
        try{
            _receiver.deleteRange(rangeSpecification);
        }catch(InvalidRangeException e){
            throw new InvalidCellRangeException(rangeSpecification);
        }
        _receiver.setChanged(true);
    }

}
