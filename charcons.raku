#!/bin/env raku

use CharCons;
use Misc;
use Screen;



#my $a = Line.new((34,64),(100,64), int-motif => 8364).draw;
#my $b = Line.new((80,64),(192,64));
#my $c = Line.new((34,64),(100,64), int-motif => 8364);

#my $c = Line.new((11,22),(11,22), motif => 'i').draw;
#$c.draw;

#my $d = Line.new((6,22),(6,24), motif => 'i');
#my $e = Line.new((8,24),(8,22), motif => 'R');
#my $f = Line.new((1,7),(1,60),int-motif => 8364);
#my $g = Line.new((2,1),(60,1),int-motif => 8364);
#my $h = Line.new((18,12),(18,30), motif => 'U');
#my $i = Line.new((18,30),(4,30), motif => 'A').draw;
#Line.new((30,30),(30,4), motif => 'A').draw;
#Line.new((40,4),(40,30), motif => 'A').draw;
#Line.new(Point.new(18,30),Point.new(4,30),motif => 'a').draw;
#Line.new(Point.new(4,40),Point.new(18,40),motif => 'b').draw;
#Line.new(Point.new(2,50),Point.new(18,50),motif => 'c').draw;
#Line.new(Point.new(18,60),Point.new(2,60),motif => 'd').draw;

#Line.new(Point.new(18,30),Point.new(18,50),motif => 'e').draw;
#Line.new(Point.new(20,50),Point.new(20,30),motif => 'f').draw;
#cursor;




#my $j = Line.new(a => Point.new(33,22),b => Point.new(100,22),motif => '-');
#my $m = Line.new(a => Point.new(33,22),b => Point.new(100,22), int-motif => 8364);
#my $l = Line.new(Point.new(33,22),Point.new(100,22), int-motif => 8364);
#nocursor();
#$c.draw;
#$d.draw;
#$e.draw;
#$f.draw;
#$g.draw;
#$h.draw;
#$i.draw;
#$l.draw;
#$m.draw;

#my $p = Orthogone.new( (8,6),(8, 44),(78,44),(78,6),(8,6),int-motif => 8364);

#my $p = Orthogone.new( (8,6),(8,12),(18,12),(18,30),(4,30),(4,60),(6,60),(98,60),(98,70),(170,70),(170,28),(192,28),(192,11),(40,11),(40,6),(8,6));
#my $p = Orthogone.new( (8,6),(8,12),(18,12),(18,30),(4,30),(4,60),(6,60),(98,60),(98,70),(170,70),(170,28),(192,28),(192,11),
#my $p = Orthogone.new( (8,6),(8,12),
#                      (18,12),(18,30),
#                      (4,30),(4,60),
#                      (30,60),(30,22),
#                      (50,22),(50,60),
#                      (98,60),(98,70),
#                      (170,70),(170,28),
#                      (192,28),(192,11),
#                      (140,11),(140,40),
#                      (130,40),(130,2),
#                      (110,2),(110,30),
#                      (98,30),(98,2),
#                      (60,2),(60,15),
#                      (24,15),(24,6),
#                      (8,6));
my $p = Orthogone.new(
(25,40),(43,40),
(43,7),(85,7),
(85,4),(102,4),
(102,55),(84,55),
(84,14),(72,14),
(72,55),(69,55),
(69,60),(83,60),
(83,75),(115,75),
(115,55),(138,55),
(138,75),(178,75),
(178,55),(202,55),
(202,51),(115,51),
(115,4),(138,4),
(138,44),(202,44),
(202,14),(151,14),
(151,4),(297,4),
(297,14),(275,14),
(275,44),(259,44),
(259,51),(295,51),
(295,44),(285,44),
(285,22),(316,22),
(316,44),(313,44),
(313,51),(308,51),
(308,55),(259,55),
(259,76),(281,76),
(281,81),(178,81),
(178,79),(138,79),
(138,81),(115,81),
(115,78),(83,78),
(83,81),(44,81),
(44,60),(58,60),
(58,55),(43,55),
(43,51),(25,51),
(25,40));


#my $p = Orthogone.new(
#(25,40),(69,40),
#(69,18),(11,18),
#(11,1),(95,1),
#(95,18),(177,18),
#(177,1),(243,1),
#(243,18),(200,18),
#(200,42),(177,42),
#(177,26),(95,26),
#(95,57),(177,57),
#(177,53),(200,53),
#(200,57),(244,57),
#(244,73),(25,73),
#(25,40));

#my $p = Orthogone.new(
#(25,3),(55,3),
#(55,39),(82,39),
#(82,13),(92,13),
#(92,20),(100,20),
#(100,8),(75,8),
#(75,19),(70,19),
#(70,18),(67,18),
#(67,7),(62,7),
#(62,3),(111,3),
#(111,6),(148,6),
#(148,32),(168,32),
#(168,34),(136,34),
#(136,16),(140,16),
#(140,8),(107,8),
#(107,36),(116,36),
#(116,14),(120,14),
#(120,44),(164,44),
#(164,39),(150,39),
#(150,41),(137,41),
#(137,36),(155,36),
#(155,37),(167,37),
#(167,36),(171,36),
#(171,30),(153,30),
#(153,3),(178,3),
#(178,40),(186,40),
#(186,43),(176,43),
#(176,40),(174,40),
#(174,38),(171,38),
#(171,44),(190,44),
#(190,37),(183,37),
#(183,3),(192,3),
#(192,24),(191,24),
#(191,29),(190,29),
#(190,32),(198,32),
#(198,37),(203,37),
#(203,44),(209,44),
#(209,48),(216,48),
#(216,54),(209,54),
#(209,57),(203,57),
#(203,64),(208,64),
#(208,69),(190,69),
#(190,48),(171,48),
#(171,69),(119,69),
#(119,49),(116,49),
#(116,69),(107,69),
#(107,44),(99,44),
#(99,69),(82,69),
#(82,45),(55,45),
#(55,69),(24,69),
#(24,3));

#my $p = Orthogone.new(
#(112,46),(112,27),
#(126,27),(126,30),
#(142,30),(142,22),
#(177,22),(177,46),
#(192,46),(192,49),
#(166,49),(166,51),
#(200,51),(200,53),
#(196,53),(196,56),
#(152,56),(152,62),
#(148,62),(148,53),
#(142,53),(142,55),
#(126,55),(126,64),
#(119,64),(119,46),
#(112,46));

#my $p = Orthogone.new(
#(25,4),(62,4),
#(62,22),(77,22),
#(77,4),(98,4),
#(98,22),(124,22),
#(124,1),(146,1),
#(146,29),(124,29),
#(124,37),(137,37), 
#(137,34), (156,34),
#(156,1),(222,1),
#(222,11),(217,11), 
#(217,13),(222,13),
#(222,16),(230,16),
#(230,2),(299,2),
#(299,34),(230,34),
#(230,37),(299,37),
#(299,78),(230,78),
#(230,42),(217,42),
#(217,78),(137,78),
#(137,46),(124,46),
#(124,78),(97,78),
#(97,46),(77,46),
#(77,78),(25,78),
#(25,4));

#my $p = Orthogone.new( 
#(105,13),(146,13),
#(146,49),(99,49),
#(99,38),(134,38),
#(134,44),(127,44),
#(127,41),(121,41),
#(121,46),(127,46),
#(127,47),(140,47),
#(140,44),(139,44),
#(139,36),(99,36),
#(99,13),(105,13));

#my $p = Orthogone.new(
#(8,7),(284,7),
#(284,80),(8,80),
#(8,7));


#my $p = Orthogone.new((18,12),(18,30),(4,30));
    $p.draw;
    #        $p.fill;

#my $sc = $p.scrn;
#my $machin = $sc.for_yrange_atx(85,7,56);
#my $machin  = $sc.for_xrange_aty(55,58);
#$machin.raku.say;

#sleep 2;
#$p.fill;
#$p.set_motif(789);
#$p.control;
#sleep 4;




#$p.gotoxy( 40, 38 );
#$p.print_motif;

#my $pt = Point.new( 30 , 42);
#my $pt = Point.new(x => 30 , y => 42);
#$pt.show;
#$pt.set2(12,48);
#$pt.show;


#my Int @n;
#push @n,8,1,9,12,6,33,2,47,4;

#say @n.min;
#say @n.max;