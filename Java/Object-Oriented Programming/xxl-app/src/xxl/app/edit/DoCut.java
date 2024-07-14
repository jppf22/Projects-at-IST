package xxl.app.edit;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import pt.tecnico.uilib.menus.CommandException;
import xxl.Spreadsheet;
import xxl.exceptions.InvalidRangeException;

/**
 * Cut command.
 */
class DoCut extends Command<Spreadsheet> {

    DoCut(Spreadsheet receiver) {
        super(Label.CUT, receiver);
    }

    @Override
    protected final void execute() throws CommandException {
        String rangeSpecification = Form.requestString(Prompt.address());
        try{
            _receiver.cut(rangeSpecification);
        }catch(InvalidRangeException e){
            throw new InvalidCellRangeException(rangeSpecification);
        }
    }

}
