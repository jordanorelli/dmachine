# dmachine

A very simple drum machine for the [Novation
Launchpad](http://us.novationmusic.com/midi-controllers-digital-dj/launchpad),
written in the [ChucK](http://chuck.cs.princeton.edu/) programming language.
This project is to serve as a tutorial for users not familiar with the
semantics of ChucK.

# Running dmachine

make sure you have ChucK and the Novation Launchpad drivers installed:
- [ChucK install page](http://chuck.cs.princeton.edu/release/)
- [Launchpad Driver download page](http://us.novationmusic.com/support/product-downloads?product=Launchpad#Software)

Clone or download this repository to somewhere convenient on your machine.  To
run the application, open up a terminal, navigate to the directory that
contains the repository, and execute the command `chuck run`.  This will launch
ChucK with the `run.ck` file, which will import the other source code files in
the project.

The file `dmachine.ck` contains the annotated source code of the drum machine
logic.  This is the main point of interest for developers looking to learn a
bit about ChucK.

The directory `lp` contains a set of chuck files that implement a handler for
the novation launchpad.  This greatly simplifies the project, since interacting
with the launchpad itself is largely taken care of.  Developers are encouraged
to read this file to see how chuck handles MIDI communication in the raw, but
it's also possible to simply ignore the implementation details and just pay
attention to the methods that are defined.

The file `run.ck` is the main entry point for our chuck application.  Chuck
doesn't have a `main()` method.  Files are included with `machine.Add`, but you
can't add a file and then use it in the same source code file, which is
extremely annoying.  That is, if you have two files A and B, such that B
depends on something defined in A, you need a third file, C, that includes both
of them; B can't include A and then use the definitions contained in A on its
own.  This is something of a wart in chuck but it's not that big of a deal.

The `samples` directory contains some drum sounds, since a drum machine without
any drum sounds is pretty useless.  This is a selection of 808 samples found
[here](http://trashaudio.com/2010/01/roland-tr-808-sample-pack/).
