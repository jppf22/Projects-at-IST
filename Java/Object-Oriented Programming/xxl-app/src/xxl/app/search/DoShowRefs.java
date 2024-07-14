package xxl.app.search;

import pt.tecnico.uilib.forms.Form;
import pt.tecnico.uilib.menus.Command;
import xxl.Spreadsheet;


/**
 * Command for searching content values.
 */
class DoShowRefs extends Command<Spreadsheet> {

    DoShowRefs(Spreadsheet receiver) {
        super(Label.SEARCH_REFERENCES, receiver);
    }

    @Override
    protected final void execute() {
        _display.popup(_receiver.search(_receiver.getEqualsReference()));
    }

}
