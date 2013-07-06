public class LP_Launchpad {
    LP_Event e;
    MidiOut  out;
    MidiIn   in;
    int      lightStatus[9][9];
    int      keyDown[9][9];

    // Creates a LP_Launchpad object and initializes its input and output channels
    // based on the supplied integer.
    fun static LP_Launchpad LP_Launchpad(int midiChannel) {
        LP_Launchpad lp;
        if(!lp.in.open(midiChannel)) me.exit();

        chout <= "Midi device: " <= midiChannel <= " -> " <= lp.in.name() <= IO.newline();
        if(!lp.out.open(midiChannel)) me.exit();

        chout <= "Midi device: " <= midiChannel <= " <- " <= lp.out.name() <= IO.newline();

        for(0 => int i; i < 9; i++) {
            for(0 => int j; j < 9; j++) {
                false => lp.lightStatus[i][j];
                false => lp.keyDown[i][j];
            }
        }

        lp.clear();
        spork ~ lp.midiListener();
        return lp;
    }

    // sets up the midi listener for this device.  You should never need to
    // call this method directly, since it is automatically invoked when
    // creating a new LP_Launchpad object.
    fun void midiListener() {
        MidiMsg m;
        while(true) {
            in => now;
            while(in.recv(m)) {
                LP_Event.fromMidi(m).copyInto(e);
                e.signal();
                e.velocity => keyDown[e.column][e.row];
                me.yield();
            }
        }
    }

    fun void setGridLight(int column, int row, int velocity) {
        setGridLight(LP_Event.LP_Event(column, row, velocity));
    }

    fun void setGridLight(LP_Event e) {
        if(lightStatus[e.column][e.row] == e.velocity) {
            return;
        }

        e.velocity => lightStatus[e.column][e.row];
        e.toMidi() @=> MidiMsg m;
        out.send(m);
    }

    fun void clear() {
        for(0 => int i; i < 9; i++) {
            for(0 => int j; j < 9; j++) {
                setGridLight(i, j, 0);
                5::ms => now;
            }
        }
    }
}
