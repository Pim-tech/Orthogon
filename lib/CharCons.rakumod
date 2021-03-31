
unit module CharCons;
use Colors :DEFAULT , :COLORS;
use Misc;
use HopcroftKarp;
use Screen;


#We consider There are no origin or destination points or if you prefer, origin is always the lowest value and destination the highest.
#Since Lines are always written in the same side
class Line is export {
    has Point $.a;
    has Point $.b;
    has Int $.int-motif;
    has Str $.motif; 
    has Str $.direction;
    has Point $.origin; 
    has Point $.destination;
    has Line $.prec is rw;

    submethod BUILD(:$!a,:$!b,:$!origin,:$!destination,:$!int-motif,:$!motif){

       ($!int-motif,$!motif) = DEFAULT_INT_MOTIF, DEFAULT_MOTIF   if ($!int-motif == -1 and $!motif eq '');
        if $!motif eq '' {
            $!motif = $!int-motif.chr;
        } elsif $!int-motif == -1 {
            my ($max,$len) = 1,$!motif.chars;
            assert $len, &[==], $max;
            $!int-motif = $!motif.ord;
        } elsif $!int-motif.chr ne $!motif {
            die "motif et int-motif spécifiés mais différents!";
        }
        if $!a.x ≠ $!b.x {
           $!direction = 'h';
        } else {
            $!direction = 'v';
        }
    }
    multi sub bound_control(Point $a ,Point $b ) {
       my Point ($origin,$destination);
       if $a.x ≠ $b.x {
           my ($ypoint1,$ypoint2) = $a.y,$b.y; 
           assert($ypoint1 , &[==] ,$ypoint2);
           ($a.x > $b.x) ?? ($origin := $b; $destination:=$a;)
           !! ($origin:=$a;$destination:=$b);
       } elsif $a.y ≠ $b.y {
           ($a.y > $b.y) ?? ($origin:=$b;$destination:=$a;) 
           !! ($origin:=$a;$destination:=$b);
       } else { $origin:=$a;$destination:=$b;}
       return $origin,$destination;
    }
    #Control limits and possibilities 
    multi sub bound_control(int-list $a,int-list $b){
        my Point ($pa,$pb,$origin,$destination);

        if  $a[0] ≠ $b[0] {
            my ($ypoint1,$ypoint2) = $a[1],$b[1]; 
            assert($ypoint1 , &[==] ,$ypoint2);
            if $a[0] > $b[0] {
                $pa := Point.new($b);
                $pb := Point.new($a);
                $origin := $pb;
                $destination := $pa;
            } else {
                $pa := Point.new($a);
                $pb := Point.new($b);
                $origin := $pa;
                $destination := $pb;
            }
        } elsif $a[1] ≠  $b[1] {
            if $a[1] > $b[1] {
                $pa := Point.new($b);
                $pb := Point.new($a);
                $origin := $pb;
                $destination := $pa;
            } else {
                $pa := Point.new($a);
                $pb := Point.new($b);
                $origin := $pa;
                $destination := $pb;
            }
        } else { 
                $pa := Point.new($a);
                $pb := Point.new($b);
                $origin := $pa;
                $destination := $pb;
 
        }

        return $pa, $pb, $origin,$destination; 
    }   
    multi method new(int-list $ia,int-list $ib,:$int-motif? = -1,:$motif? = ''){
        my Point ($a,$b,$origin,$destination) = bound_control($ia,$ib);
        self.bless( :$a, :$b,:$origin,:$destination,:$int-motif,:$motif);
    }
    multi method new(Point $p,Int $n,$direction,:$int-motif?  = -1,:$motif?  = '') {
        my Point ($a,$b,$origin,$destination);
        if $direction eq 'v' {
            if $n > 0  {
                $a = Point.new($p.x,$p.y);
                $b = Point.new($p.x,($p.y + $n));
                $origin = $a;
                $destination = $b;
           } elsif $n < 0 {
                $b = Point.new($p.x,$p.y);
                $a = Point.new($p.x,($p.y + $n));
                $origin = $b;
                $destination = $a;
           }
        } elsif $direction eq 'h' {
            if $n > 0 {
                $a = Point.new(($p.x),$p.y);
                $b = Point.new($p.x + $n ,$p.y);
                $origin = $a;
                $destination = $a;
            } elsif $n < 0 {
                $b = Point.new(($p.x),$p.y);
                $a = Point.new($p.x + $n ,$p.y);
                $origin = $b;
                $destination = $a;
            }
       }
        self.bless(:$a,:$b,:$origin,:$destination,:$direction,:$int-motif,:$motif);
    }
    multi method new(Point $a,Point $b,Int :$int-motif? = -1,Str :$motif? = '') {
        my Point ($origin,$destination) = bound_control($a,$b);
        self.bless(:$a,:$b,:$origin,:$destination,:$int-motif,:$motif);
    }
    multi method new(Point :$a,Point :$b,Int :$int-motif? = -1,Str :$motif? = '') {
        my Point ($origin,$destination) = bound_control($a,$b);
        self.bless(:$a,:$b,:$origin,:$destination,:$int-motif,:$motif);
    }

    method is_subset(Line $b --> Bool:D){
        if $!direction eq 'h' {
            return False if  $b.direction eq 'v';#Ce cas ne devrait pas arriver
            return True if $!a.y == $b.a.y and ($!a.x ≤ $b.b.x and $!a.x ≥ $b.a.x) and ($!b.x ≥ $b.a.x  and $!b.x ≤ $b.b.x);
            return False;
        } elsif $!direction eq 'v' {
            return False if $b.direction eq 'h';
            return True if $!a.x == $b.a.x and ($!a.y ≤ $b.b.y and $!a.y ≥ $b.a.y ) and ($!b.y >= $b.a.y and $!b.y ≤ $b.b.y);
            return False;
        }
    }
    method get_coords() {
        return $!a.x,$!a.y,$!b.x,$!b.y;
    }

    method draw {
        my Int $n;
        my Str $s;
        $!origin.fix;
        if $!direction eq 'h' {
            $n = $!destination.x - $!origin.x;
            $s = $!motif x ($n + 1);
        } 
        elsif $!direction eq 'v' {
            $n = $!destination.y - $!origin.y;
            $s = ($!motif ~ move_down_and_left(True)) x ($n + 1); 
        }
       print $s; 
    }
}

class Orthogone is export {
    
    has Line @!lines;
    has @!coordonnees;
    has Int $!int_border_motif; 
    has Str $.border_motif; 
    has Str ($!border_color_attr,$!fill_color_attr,$!mycolor);
    has Point  @.corner_points; 
    has Color $!objcolor; 
    has Point @!concaves_points;
    has Line @!vertical_diagonales;
    has Line @!horizontal_diagonales;
    has Line @!mis_diagonales;
    has Int $!rotation;
    has (@!v_indices,@!h_indices);
    has @!rectangles;
    has ScreenBuffer $.scrn;

    has $!log_fh;

    submethod BUILD(:@!coordonnees,:$!int_border_motif,:$!border_motif) {
       ($!int_border_motif,$!border_motif) = DEFAULT_INT_MOTIF, DEFAULT_MOTIF   if ($!int_border_motif == -1 and $!border_motif eq '');
      if $!border_motif eq '' {
          $!border_motif = $!int_border_motif.chr;
      } elsif $!int_border_motif == -1 {
          my ($max,$len) = 1,$!border_motif.chars;
          assert $len, &[==], $max;
          $!int_border_motif = $!border_motif.ord;
      } elsif $!int_border_motif.chr ne $!border_motif {
            die "border_motif et int_border_motif spécifiés mais différents!";
      }
      $!objcolor := Color.new;
      $!scrn = ScreenBuffer.new;
      $!border_color_attr = $!objcolor.sequence8(LWHITE+BBLUE,str => True);
      $!fill_color_attr = $!objcolor.sequence8(LYELLOW,str => True);
      $!mycolor = $!objcolor.sequence8(LYELLOW+BRED,str => True);
      @!corner_points := self.control_and_get(@!coordonnees);
      push @!lines,Line.new(a => @!corner_points[0], b => @!corner_points[1],border_motif => $!border_motif);
      $!scrn.load_value(@!corner_points[0]);
      $!scrn.load_value(@!corner_points[1]);
      for 2 .. @!corner_points.end -> $n {
          my ($point,$prec_point) := @!corner_points[$n],@!corner_points[$n - 1];
          $!scrn.load_value($point);
          my $line := Line.new(a => $prec_point, b => $point,border_motif => $!border_motif);
          given $line.direction {
              when 'h' { $!scrn.load_value( Point.new($_,$line.origin.y , setflag => 'LINE')) for $line.origin.x + 1 .. $line.destination.x - 1 ; }
              when 'v' {$!scrn.load_value( Point.new($line.origin.x,$_, setflag => 'LINE') ) for $line.origin.y + 1 .. $line.destination.y - 1 ;}
          }
          push @!lines,$line; 
          @!lines.tail.prec = @!lines[*-2];
      }
      $!scrn.make_indices();
      $!log_fh = open :w, 'char_cons.log';
      self!concave_angles();
      self!make_diagonales();
      self!make_graph_and_reduce();
      self!create_rectangles();
    }

    multi method new(**@coordonnees where all(@coordonnees>>.elems) == 2,:$int_border_motif? = -1 ,:$border_motif? = '' ) {
        my @pts;# = self.control_and_get(@coordonnees);
        self.bless(coordonnees => @coordonnees,:$int_border_motif,:$border_motif);
    }

    method control_and_get(@cord,--> Array) {
        my Point @points;
        my Point $plast := Point.new( @cord[0][0],@cord[0][1]);
        @points.push( $plast );
        
        for 1 .. @cord.end -> $n {
            my ($xp,$yp) = @cord[$n - 1][0],@cord[$n - 1][1];
            my ($x,$y) = @cord[$n][0],@cord[$n][1];
            unless $xp == $x {
                unless $yp == $y {
                       my $msg = sprintf("for point (%d,%d), none x or y equal to precedent point.",$x,$y);
                       die $msg;
                }
            }
            @points.push(Point.new($x,$y));
            @points.tail.prev = $plast;
            @points.tail.prev.next = @points.tail;
            $plast:=@points.tail;
        }
    CATCH {
       default {
                say "Exception in !!! Polygone : " ~ $_.payload;
              }
         };
        return @points;
    }
    method !get_direction(Line $l --> Str) {
        given $l.direction {
            when 'h' {
                given $l.a.x {
                    when $_ < $l.b.x { return 'right';} 
                    when $_ > $l.b.x { return 'left';} 
                }
            }
            when 'v' {
                given $l.a.y {
                    when $_ < $l.b.y { return 'down';} 
                    when $_ > $l.b.y { return 'up';} 
                }
            }
        }
        return '';
    }
    method !concave_angles {
        my Int $rotation = 0;
        my Line $first_line = @!lines[0].clone(prec => @!lines.tail);
        my Point (@r,@l);
        my @all_lines := @!lines;
        push @all_lines,$first_line;
        @all_lines[0].origin.direction='';
        for  1 .. @all_lines.end -> $n {
            my $l := @all_lines[$n]; 
            my Str $direction  = self!get_direction($l.prec) ~ self!get_direction($l);
            $!scrn.get_value($l.a).direction = $direction;
            given $direction {
                when 'rightdown' {  push @r,$l.a; $rotation++;   }
                when 'downleft' { push @r,$l.a;  $rotation++; }
                when 'upright'  { push @r,$l.a;  $rotation++; }
                when 'leftup' { push @r,$l.a; $rotation++;}
                when 'leftdown' { push @l,$l.a; $rotation--; }
                when 'downright' { push @l,$l.a; $rotation--; }
                when 'rightup' { push @l,$l.a; $rotation--;  }
                when 'upleft' {  push @l,$l.a; $rotation--;  }
                default { $!log_fh.say("direction: '", $direction, "'"); }
            } 
           }
           given $rotation {
               when $_ > 0   { .setflag('CONVEXE') for @r; @!concaves_points := @l; }
               when $_ < 0   { .setflag('CONVEXE') for @l; @!concaves_points := @r; }
               default { say '$rotation == ', $rotation , ' : did not move.'; } 
           }
           .setflag('CONCAVE') for @!concaves_points;
           $!rotation = $rotation;
    }     
    method get_source_dest(Point $p) {
        my $s = $p.str;
        my $s2 = $p.prev.str;

        return $p.prev, $p if $p.prev and ($p.x > $p.prev.x or $p.y > $p.prev.y);
        return $p, $p.prev if $p.prev and ($p.x < $p.prev.x or $p.y < $p.prev.y);   
        return $p.prev,$p;
    }
     method !diagonales(@x_or_y,@xy_o_yx,Str $x_or_y) {
         my (@diagonales,$motif,$for_range_at,$a,$b,$v1,$v2,$v3,$v4);
         if $x_or_y eq 'x' {
             @diagonales := @!vertical_diagonales;
             $motif = '|';
             $for_range_at = 'for_yrange_atx';
             ($a,$b,$v1,$v2,$v3,$v4) = 'x','y','xoy','asrc','xoy','adest';
         } elsif $x_or_y eq 'y' {
             @diagonales := @!horizontal_diagonales;
             $motif = '-';
             $for_range_at = 'for_xrange_aty';
             ($a,$b,$v1,$v2,$v3,$v4) = 'y','x','asrc','xoy','adest','xoy';
         }
        for @x_or_y -> $ai {
            my $sublist = @xy_o_yx[$ai];
            next if @$sublist.elems < 2;
            @$sublist .= sort;  
            for 1 .. @$sublist.end -> $n {
                my $adest  = @$sublist[$n] + 1;
                my $asrc  = @$sublist[$n - 1] + 1;
                my $xoy = $ai + 1;
                if (my $p=$!scrn.get_value($xoy,$adest)) {
                    my ($source,$dest) = self.get_source_dest($p);
                   next if $source."$a"() == $xoy and $source."$b"() == $asrc 
                        and $dest."$a"() == $xoy and $dest."$b"() == $adest;
                }
                if (my $p2=$!scrn.get_value($xoy,$asrc)) {
                    my ($source,$dest) = self.get_source_dest($p2);
                    next if $source."$a"() == $xoy and $source."$b"() == $asrc 
                        and $dest."$a"() == $xoy and $dest."$b"() == $adest;
                }
                next if  $!scrn."$for_range_at"($xoy,$asrc,$adest); 
                push @diagonales , Line.new( ($::($v1),$::($v2)),($::($v3),$::($v4)) , motif => $motif);
            }
        }
     }
     method !make_diagonales {
        my (@x,@xy,@y,@yx);
        for @!concaves_points -> $pt {
           push @x,$pt.x - 1;
           push @y,$pt.y - 1;
           push @xy[$pt.x - 1], $pt.y - 1;
           push @yx[$pt.y - 1], $pt.x - 1;
        } 
        @x .= sort;
        @x .= unique;
        @y .= sort;
        @y .= unique;
        self!diagonales(@x,@xy,'x');
        self!diagonales(@y,@yx,'y');
     }
     method !make_graph_and_reduce() {
         my %graph;
         for @!vertical_diagonales -> $l1 {
             my ($vx1,$vy1,$vx2,$vy2) = $l1.get_coords();
             my $vindice = 'vertic_' ~ $vx1.Str ~ '_'  ~ $vy1.Str ~ '_' ~ $vy2.Str;
             for @!horizontal_diagonales -> $l2 {
                 my ($hx1,$hy1,$hx2,$hy2) = $l2.get_coords();
                 my $hindice = 'horiz_' ~ $hy1.Str ~ '_'  ~ $hx1.Str ~ '_' ~ $hx2.Str;
                 if ( $hy1 ≥ $vy1 and $hy1 ≤ $vy2)
                     and
                ($vx1 ≥ $hx1 and $vx1 ≤ $hx2) {
                    push %graph{$vindice} , $hindice;
                } 
             }
         }
         my $obj := HopcroftKarp.new(%graph);
         $obj.maximum_matching(True);
         for $obj.vertices.keys -> $v {
              if  (my $match = $v.match(/^ ('horiz'|'vertic')  '_' (\d+) '_' (\d+) '_' (\d+) $/)) { 
                  my ($type,$a,$b,$c) = $match>>.Str;
                  my ($ai,$bi,$ci) = $a.Int,$b.Int,$c.Int;
                  given $type {
                      when 'horiz' { 
                          $!scrn.get_value($bi,$ai).setflag('MIS'); 
                          $!scrn.get_value($ci,$ai).setflag('MIS');
                          my $l = Line.new( ($bi  ,$ai ),($ci ,$ai) , motif => '-' );
                          for $bi + 1 .. $ci - 1 -> $x {
                              $!scrn.load_value($x,$ai,Point.new($x,$ai,setflag =>'MIS'));
                          }
                          push @!mis_diagonales, $l; 
                      }
                      when 'vertic' {
                          $!scrn.get_value($ai,$bi).setflag('MIS');
                          $!scrn.get_value($ai,$ci).setflag('MIS');
                          for $bi + 1 .. $ci - 1 -> $y {
                              $!scrn.load_value($ai,$y,Point.new($ai,$y,setflag => 'MIS'));
                          }
                          my $l = Line.new( ($ai,$bi), ($ai,$ci), motif => '|' );
                          push @!mis_diagonales, $l;
                      }
                  }
             }
          }

          $!scrn.make_indices();
      }
    method !create_rectangles {
        for @!concaves_points -> $pt {
            #next if $pt.mis === True; 
            # say $pt.hasflag('MIS');
            next if $pt.hasflag('MIS');
            $pt.setflag('RECTANGLE');
            given $pt.direction { 
                when / (^ right) | (left $) /  { 
                    my Point $other_point := $!scrn.for_xrange_aty($pt.y,$pt.x); 
                    $other_point.setflag('RECTANGLE');
                    $pt.rect = $other_point;
                    Line.new($pt,$other_point,motif => '*').draw;
                }
                when / (^ left ) | (right $) /  {
                    my Point $other_point := $!scrn.for_xrange_aty($pt.y,$pt.x,sens => -1);
                    $other_point.setflag('RECTANGLE');
                    $pt.rect = $other_point;
                    Line.new($pt,$other_point,motif => '∘').draw;
                }
               default { 
                   $!log_fh.say("Angle: '", $pt.direction , ' not defined or wrong.');
               }
            }
        }
    }
    multi method rectangle(int-list $a, int-list $b,:$motif=' ',:$color=BRED){
        my Int ($x1,$y1,$x2,$y2) = ( @$a,@$b ).flat;
        $!objcolor.sequence8($color);
        for $y1 .. $y2 -> $y {
            Line.new( ($x1,$y), ($x2,$y),:$motif).draw;
        }
        $!objcolor._;
    }
    multi method rectangle(Point $a,Point $b,:$motif=' ',:$color=BRED){
        self.rectangle( ($a.x,$a.y), ($b.x,$b.y), :$motif,:$color);
    }
    multi method fill_rectangle(Point $pt, :$motif = ' ', :$color = BRED) {
        my ($xmirror,$ymirror);
        my Point $mirror;
        if $pt.y == $pt.rect.y {
            if $pt.prev.y != $pt.y {
                $ymirror = $pt.prev.y;
                $xmirror = $pt.rect.x;
            }elsif $pt.next.y ≠ $pt.y {
                $ymirror = $pt.next.y;
                $xmirror = $pt.rect.x; 
            } 
            
            if (my $mirror = $!scrn.get_value($xmirror,$ymirror)) {
                $!log_fh.say('pt: ',$pt.str,', mirror: ',$xmirror,',',$ymirror,', direction: ',$pt.direction,', prec:',$pt.prev.str, ': ', $pt.prev.direction);
                self.fill_rectangle($pt,$mirror);
            }
            #self.rectangle($mirror,$pt);
        } 
    }

    multi method fill_rectangle(Point $a,Point $b,:$motif='O',:$color=LWHITE+BRED){
        my Int ($x1,$y1,$x2,$y2) = $a.x, $a.y,$b.x,$b.y;
        ($x1,$x2) = ($x1,$x2).sort;
        ($y1,$y2) = ($y1,$y2).sort;
        $x1++;
        $x2--;
        $y1++;
        $y2--;
        self.rectangle( ($x1,$y1) , ($x2,$y2), :$motif,:$color);
    }
    multi method fill_rectangle(int-list $a,int-list $b, :$motif = 'I',:$color = LWHITE+BRED){
        my Int ($x1,$y1,$x2,$y2) = (@$a,@$b).flat;
        ($x1,$x2) = ($x1,$x2).sort;
        ($y1,$y2) = ($y1,$y2).sort;
        $x1++;
        $x2--;
        $y1++;
        $y2--;
        self.rectangle( ($x1,$y1) , ($x2,$y2), :$motif,:$color);
    }
     method display_concave_angles {
         print $!fill_color_attr;
         for @!concaves_points -> $pt {
             $pt.fix;
             #print( $pt.direction );
             printf("%d,%d",$pt.x,$pt.y)# if $pt.direction eq 'X'; 
         }
        print $!objcolor._;
     }
    method draw {
        print $!border_color_attr;
        for @!lines -> $l {
            $l.draw;
        }
        for @!mis_diagonales -> $line {
            $line.draw;
        }
        $!objcolor._;
        gotoxy(1,1);
      }

    method fill {
        for 1 ..  @!concaves_points.end  -> $n {
           my $pt := @!concaves_points[$n];
           next unless $pt.rect;
           #print 'pt: ',$pt.str;
           #sleep 2;
           self.fill_rectangle($pt);
           #print ',rectangle: ',$pt.rect.str if $pt.rect;
           #print "\n";
        }
        self.display_concave_angles;
        gotoxy(1,1);
        print $!objcolor._;
    }
    method set_border_motif( Int $m) {
        $!border_motif = $m;
    }
}

