#!/bin/env raku

use TraceBoxes;

my $trace = TraceBox.new(output => 'my_trace.raku');

$trace.start_at(x => 25,y =>40);

