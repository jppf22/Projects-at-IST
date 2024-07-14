package xxl.app.search;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import xxl.Spreadsheet;


/**
 * Command for searching content values.
 */
class DoShowEven extends Command<Spreadsheet> {

    DoShowEven(Spreadsheet receiver) {
        super(Label.SEARCH_VALUES_EVEN, receiver);
    }

    @Override
    protected final void execute() {
        _display.popup(_receiver.search(_receiver.getEqualsEvenValue()));
    }

}
