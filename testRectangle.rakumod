#!/bin/env raku

use Rectangle;
use Colors :DEFAULT, :COLORS;
use Screen;

my $r2 = Rectangle.new(xpos => 1,ypos => 1,hlen => 18, vlen => 10,
   border_color => LWHITE+BRED, color => WHITE+BBLUE);
$r2.draw;


my $r = Rectangle.new(xpos => 100 ,ypos => 1,hlen => 4,vlen => 4,color => LWHITE+BCYAN);
$r.draw;


my $r3 =Rectangle.new(xpos => 100,ypos => 20,hlen => 10, vlen => 10,box => SIMPLE,
border_color => LWHITE+BCYAN,
color => LWHITE+BBLUE);
$r3.draw;

my $r4 = Rectangle.new(200,20,hlen => 20,vlen => 20,box => DOUBLE, border_color => LWHITE+BBLUE, color => LWHITE+BGREEN);

$r4.draw;

my $r5 = Rectangle.new(Point.new(120,40),Point.new(160,80),box => DOUBLE, border_color => LWHITE+BBLUE, color => LWHITE+BGREEN);
$r5.draw;

my $r6 = Rectangle.new(Point.new(20,40),Point.new(60,80),box => HEAVY, border_color => LWHITE+BCYAN, color => WHITE+BRED, motif => "\c[DARK SHADE]");
$r6.draw;

#my $r7 = Rectangle.new(1,40,40,30,box => 3,border_color => LWHITE+BRED);
#$r7.draw;

sleep 4;
