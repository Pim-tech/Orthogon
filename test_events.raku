#!/bin/env raku
#
use Events :EVENTS, :DEFAULT;


sub test_this {
    say "Hey , this works!";
}

my $inst = Event.new(events => { (KEY_PG_DOWN) =>  'exit', (KEY_UP) => '',(KEY_DOWN) => '' ,(KEY_RIGHT) => '',(KEY_LEFT) => '', (KEY_ESCAPE) => &test_this}, exit_key => KEY_F1 ,verbose => True);
#my $inst = Event.new(test => 'bla bla bla' );

$inst.wait_event();


