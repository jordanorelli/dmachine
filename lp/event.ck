public class LP_Event extends Event {
    int column;
    int row;
    int velocity;

    fun static LP_Event LP_Event(int column, int row, int velocity) {
        if(column < 0 || column > 8) {
            cherr <= "Parameter out of range in LP_Event.LP_Event."
                <=  "  Supplied column value: " <= column <= ".  Maximum is 8."
                <= IO.newline();
            me.exit();
        }

        if(row < 0 || row > 8) {
            cherr <= "Parameter out of range in LP_Event.LP_Event."
                <=  "  Supplied column value: " <= column <= ".  Maximum is 8."
                <= IO.newline();
            me.exit();
        }

        if(velocity < 0 || velocity > 127) {
            cherr <= "Parameter out of range in LP_Event.LP_Event."
                <=  "  Supplied velocity value: " <= column
                <= ".  Maximum is 127." <= IO.newline();
            me.exit();
        }

        LP_Event e;
        column => e.column;
        row => e.row;
        velocity => e.velocity;
        return e;
    }

    fun static LP_Event fromMidi(MidiMsg m) {
        LP_Event e;
        if(m.data1 == 176) {
            8 => e.row;
            m.data2 - 104 => e.column;
        } else if(m.data1 == 144) {
            if(m.data2 % 16 == 8) {
                m.data2 / 16 => e.row;
            } else {
                7 - (m.data2 / 16) => e.row;
            }
            m.data2 % 16 => e.column;
        } else {
            cherr <= "Received request to parse unrecognized Midi message "
                <= "format.  Could not generate LP_Event."
                <= IO.newline();
        }
        m.data3 => e.velocity;
        return e;
    }

    fun void copyInto(LP_Event @ e) {
        column => e.column;
        row => e.row;
        velocity => e.velocity;
    }

    fun MidiMsg toMidi() {
        MidiMsg m;

        if(row == 8) {
            176 => m.data1;
            104 + column => m.data2;
        } else {
            144 => m.data1;
            if(column == 8) {
                16 * row + column => m.data2;
            } else {
                16 * (7 - row) + column => m.data2;
            }
        }

        velocity => m.data3;
        return m;
    }

    fun string toString() {
        return "LP_Event " + "\t" + Std.itoa(column) + "\t" + Std.itoa(row) + "\t" + Std.itoa(velocity);
    }
}
