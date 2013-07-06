// create an array of strings that represent the (relative) paths to the
// filenames of our samples.
[
    "samples/bass.aif",
    "samples/snare.aif",
    "samples/clap.aif",
    "samples/cowbell.aif",
    "samples/cymbal.aif",
    "samples/hihat_open.aif",
    "samples/hihat_closed.aif",
    "samples/rimshot.aif"
] @=> string samples[];

// a SndBuf object is a buffer of samples with a position and a rate.  That is,
// it's a representation of sound, stored in memory.  For our purposes, we
// create a new SndBuf for each drum hit we're going to utilize.  The full
// SndBuf documentation can be found here:
// http://chuck.cs.princeton.edu/doc/program/ugen_full.html#sndbuf

// create an array of SndBuf objects that is as long as the list of sample
// paths that we've created.
SndBuf sampleBuffers[samples.cap()];

// for each sample...
for (0 => int i; i < samples.cap(); i++) {
    // create a new SndBuf object and chuck it to the dac (the sound card).
    SndBuf buf => dac;

    // read our audio file into the SndBuf, so that our audio sample is stored
    // in memory ahead of time.
    samples[i] => buf.read;

    // set the SndBuf's position to the very end, so that it doesn't play when
    // we start our application.
    buf.samples() => buf.pos;

    // keep a reference to our SndBuf in our sampleBuffers array.
    buf @=> sampleBuffers[i];
}

// the USB midi channel of your LaunchPad.  It's 0 by default.  You'll have to
// change this if you're using a different midi channel.  You can use `chuck
// --probe` on the command line to see what midi devices are seen by chuck, as
// well as their midi port numbers.
0 => int midiChannel;

// create a new LP_Launchpad object for the given MIDI channel, and store a
// reference to it in the LP_Launchpad variable named "lp".
LP_Launchpad.LP_Launchpad(midiChannel) @=> LP_Launchpad lp;

// length of time between our steps.  Make this bigger if you want your score
// to run more slowly.
100::ms => dur stepDelay;

// keeps track of the current step in our score.
0 => int currentStep;

// a two-dimensional array will be used to store the state of our score.  For
// each value, if we place a 1 in the array, it means the note is enabled.  A 0
// will make the note disabled.
int score[9][9];

// our listener function will serve to listen to user input coming in on the
// Launchpad.  This is standard event-handling logic for chuck.  For more info
// about Event handling on ChucK, see here:
// http://chuck.cs.princeton.edu/doc/language/event.html
fun void listener() {
    while(true) {
        // block until we have a new event
        lp.e => now;

        // a velocity of 127 is a midi message that means key down.  We're only
        // interested in key down events, not key up events.
        if (lp.e.velocity == 127) {

            // toggle the column and row value for this event.  This will
            // modify our score.  This is not a race condition because ChucK is
            // single-threaded.
            toggle(lp.e.column, lp.e.row);
        }
    }
}
// spork our listener, putting it in its own shred.  This means that our
// listener() function that we called before won't block the whole world, even
// though it's in an infinite loop; it only blocks itself.  For more
// information on how ChucK's concurrency primitives work, see here:
// http://chuck.cs.princeton.edu/doc/language/spork.html
spork ~ listener();

// toggle a note in our score.  If it's enabled, disabled it; if it's disabled,
// enable it.
fun void toggle(int col, int row) {
    // ChucK lacks a boolean type, but an integer value of 0 is considered
    // false in a boolean context, and an integer value of 1 is considered true
    // in a boolean context.
    if (score[col][row]) {
        // if the note is enabled, disable it.
        0 => score[col][row];

        // also turn off the light on the launchpad that corresponds to this note.
        lp.setGridLight(col, row, 0);

        // bail here, because we're done.
        return;
    }

    // since we returned early when the note was enabled, we already know the
    // note was disabled.  Enable the note.
    1 => score[col][row];

    // also turn on the light on the launchpad that corresponds to this note.
    lp.setGridLight(col, row, LP_Color.lightRed);
}

// the function columnOn will be run to enable an entire column of notes.  That
// is, we'll illuminate the entire column, so that the player can see something
// analogous to a playhead on the launchpad.
fun void columnOn(int col) {
    for (0 => int row; row < 8; row++) {
        if (score[col][row]) {
            // if the note is enabled, illuminate the corresponding light on the launchpad.
            lp.setGridLight(col, row, LP_Color.red);

            // this is where we trigger a sound to start playing.  We already
            // loaded our sample into memory and connected it to the dac, so
            // all we need to do is rewind our sample to the beginning and it
            // will play.
            0 => sampleBuffers[row].pos;
        } else {

            // since the note isn't on, we'll illuminate the corresponding grid
            // position to some color that represents the current play head, so
            // that the performer can see where we are in the sequence.
            lp.setGridLight(col, row, LP_Color.yellow);
        }
    }
}

// the function columnOff will be run to disable an entire column of notes.
// That is, we'll turn all of the lights off, unless a note is enabled, in
// which case we leave it illuminated so that the player can always have a view
// of the current score.
fun void columnOff(int col) {
    for (0 => int row; row < 8; row++) {
        if (score[col][row] == 1) {
            lp.setGridLight(col, row, LP_Color.lightRed);
        } else {
            lp.setGridLight(col, row, 0);
        }
    }
}

while(true) {
    // turn off the light on the current column position.  This will remove the
    // play head entirely.
    columnOff(currentStep);

    // go to the next step in our sequence.
    currentStep++;

    // if we've gone off the end, go back to the beginning
    if (currentStep > 7) 0 => currentStep;

    // turn on the current column position.  This will draw the play head.
    columnOn(currentStep);

    // delay for some fixed amount of time.
    stepDelay => now;
}
