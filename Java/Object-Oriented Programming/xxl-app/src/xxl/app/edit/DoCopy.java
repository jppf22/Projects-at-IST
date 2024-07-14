package xxl.app.edit;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import pt.tecnico.uilib.menus.CommandException;
import xxl.Spreadsheet;
import xxl.exceptions.InvalidRangeException;


/**
 * Copy command.
 */
class DoCopy extends Command<Spreadsheet> {

    DoCopy(Spreadsheet receiver) {
        super(Label.COPY, receiver);
    }

    @Override
    protected final void execute() throws CommandException {
        String rangeSpecification = Form.requestString(Prompt.address());
        try{
            _receiver.copy(rangeSpecification);
        }catch(InvalidRangeException e){
            throw new InvalidCellRangeException(rangeSpecification);
        }
    }

}
