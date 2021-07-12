
unit module CharCons;
use Colors :DEFAULT , :COLORS;
use Misc;
use HopcroftKarp;
use Screen;
use Rectangle;


#We consider There are no origin or destination points or if you prefer, origin is always the lowest value and destination the highest.
#Since Lines are always written in the same side
class Line is export {
    has Point $.a;
    has Point $.b;
    has Point $!p;
    has Int $.int-motif;
    has Int $!n;
    has Str $.motif; 
    has Str $.direction;
    has Point $.origin; 
    has Point $.destination;
    has Line $.prec is rw;
    has int-list $.ia;
    has int-list $.ib;

    multi method new(int-list $ia,int-list $ib,Int :$int-motif,Str :$motif){
        self.bless( :$ia, :$ib,:$int-motif,:$motif);
    }
    multi method new(Point $a,Point $b,Int :$int-motif,Str :$motif) {
        self.bless(:$a,:$b,:$int-motif,:$motif);
    }
    multi method new(Point :$a,Point :$b,Int :$int-motif ,Str :$motif) {
        self.bless(:$a,:$b,:$int-motif,:$motif);
    }
    submethod TWEAK() {
        die "You may not give motif and int-motif together!" if $!int-motif and $!motif;
        if not $!int-motif and not $!motif {
           $!motif = DEFAULT_MOTIF; 
        } elsif $!int-motif {
           $!motif = $!int-motif.chr;
        } 
        if $!ia and $!ib {
            $!a = Point.new($!ia);
            $!b = Point.new($!ib);
        } 
        if $!a.x != $!b.x {
            $!direction = 'h';
            my ($ypoint1,$ypoint2) = $!a.y,$!b.y;
            assert($ypoint1, &[==] , $ypoint2);
            ($!a.x > $!b.x) ?? ($!origin := $!b; $!destination:= $!a) !! ($!origin := $!a; $!destination := $!b);
        } elsif $!a.y != $!b.y {
            $!direction = 'v';
            ($!a.y > $!b.y) ?? ($!origin := $!b; $!destination:= $!a) !! ($!origin := $!a; $!destination := $!b);
        } else {
           die "You may not have 2 identical points to build a Line." 
        }
    } 

    method get_coords() {
        return $!a.x,$!a.y,$!b.x,$!b.y;
    }
    method str(--> Str) {
        return $!a.x.Str ~ ',' ~ $!a.y.Str ~ '/' ~ $!b.x.Str ~ ',' ~ $!b.y.Str;
    }

    #Return True if the given point is into this Line
    method has_point(Point $pt) {
        return ( $pt.y == $!origin.y  and ( $pt.x >=  $!origin.x and $pt.x <= $!destination.x ) )  if $!direction eq 'h';
        return ( $pt.x == $!origin.x  and ( $pt.y >= $!origin.y and $pt.y <= $!destination.y ) )  if $!direction eq 'v';
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
    
    has @!coordonnees;
    has Int $!int_border_motif; 
    has Str $.border_motif; 
    has Str ($!border_color_attr,$!fill_color_attr);
    has Point  @.corner_points; 
    has Color $!objcolor; 
    has Point @!concaves_points;
    has Line @!vertical_diagonales;
    has Line @!horizontal_diagonales;
    #---------------
    has Line @!lines;
    has Line @!mis_diagonales;
    has Line @!complete_rectangles;
    #--------------
    has Int $!rotation;
    has ScreenBuffer $.scrn;
    has @!rect;
    has $!log_fh;
    has @!rect_index;

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
      @!corner_points := self.control_and_get(@!coordonnees);
      push @!lines,Line.new(a => @!corner_points[0], b => @!corner_points[1],border_motif => $!border_motif);
      $!scrn.load_value(@!corner_points[0]);
      $!scrn.load_value(@!corner_points[1]);
      for 2 .. @!corner_points.end -> $n {
          my ($point,$prec_point) := @!corner_points[$n],@!corner_points[$n - 1];
          $!scrn.load_value($point);
          my $line := Line.new(a => $prec_point, b => $point,border_motif => $!border_motif);
          push @!lines,$line; 
          @!lines.tail.prec = @!lines[*-2];
      }
      push @!lines, Line.new(a => @!corner_points.tail,b => @!corner_points[0],border_motif => $!border_motif);
      for @!lines -> $l {
          given $l.direction {
              when 'h' { $!scrn.load_value( Point.new($_,$l.origin.y , setflag => 'LINE')) for $l.origin.x + 1 .. $l.destination.x - 1 ; }
              when 'v' {$!scrn.load_value( Point.new($l.origin.x,$_, setflag => 'LINE') ) for $l.origin.y + 1 .. $l.destination.y - 1 ;}
          }
      }
      @!lines.tail.prec = @!lines[*-2];
      $!scrn.make_indices();
      $!log_fh = open :w, 'char_cons.log';
      self!concave_angles();
      self!make_diagonales();
      self!make_graph_and_reduce();
      self!create_rectangles();
    }

    multi method new(**@coordonnees where all(@coordonnees>>.elems) == 2,:$int_border_motif? = -1 ,:$border_motif? = '' ) {
        self.bless(coordonnees => @coordonnees,:$int_border_motif,:$border_motif);
    }

    method control_and_get(@cord --> Array) {
        my Point @points;
        my Point $first = Point.new( @cord[0][0],@cord[0][1]);
        my Point $plast := $first;
      
        @points.push( $first );
        
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
        $first.prev = @points.tail;
        $first.next = @points[1];
        @points.tail.next = $first; 
        
    CATCH {
       default {
                say "Exception in !!! Polygone : " ~ $_.payload;
              }
         };
        return @points;
    }
    #TODO:
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
                          my Point ($p1,$p2) = $!scrn.get_value($bi,$ai),$!scrn.get_value($ci,$ai);
                          $p1.setflag('MIS'); 
                          $p2.setflag('MIS');
                          $p2.mis = $p1;
                          $p1.mis = $p2;
                          my $l = Line.new( ($bi  ,$ai ),($ci ,$ai) , motif => '-' );
                          for $bi + 1 .. $ci - 1 -> $x {
                              $!scrn.load_value($x,$ai,Point.new($x,$ai,setflag =>'MIS'));
                          }
                          push @!mis_diagonales, $l; 
                      }
                      when 'vertic' {
                          my Point ($p1,$p2) = $!scrn.get_value($ai,$bi),$!scrn.get_value($ai,$ci);
                          $p1.setflag('MIS');
                          $p2.setflag('MIS');
                          $p2.mis = $p1;
                          $p1.mis = $p2;
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
            next if $pt.hasflag('MIS');
            $pt.setflag('RECTANGLE');
            given $pt.direction { 
                when / (^ right) | (left $) / { 
                    my Point $other_point := $!scrn.for_xrange_aty($pt.y,$pt.x); 
                    $other_point.setflag('RECTANGLE');
                    $other_point.rect = $pt;
                    $other_point.prev = $pt;
                    $other_point.next = $pt;
                    $pt.rect = $other_point;
                    push @!complete_rectangles, Line.new($pt,$other_point,motif => '*');
                }
                when / (^ left ) | (right $) / {
                    my Point $other_point := $!scrn.for_xrange_aty($pt.y,$pt.x,sens => -1);
                    $other_point.setflag('RECTANGLE');
                    $other_point.rect =  $pt;
                    $other_point.prev = $pt;
                    $other_point.next = $pt;
                    $pt.rect = $other_point;
                    push @!complete_rectangles, Line.new($pt,$other_point,motif => '∘');
                }
               default { 
                   $!log_fh.say("Angle: '", $pt.direction , ' not defined or wrong.');
               }
            }
        }
    }

    multi method pointsAreLine(Point $p1,Point $p2 --> Bool ) {
        die 'p1 not defined' unless $p1.defined;
        my $prev = $p1.prev;
        my $next = $p1.next;
        die 'p2 not defined' unless $p2.defined;

        if ($prev.defined  and $next.defined ) and  ($prev == $p2   ||  $next == $p2) {
            return True;
        } elsif $p1.hasflag('CONCAVE') {
            if defined $p1.rect and $p2  ==  $p1.rect {
                return  True;
            }
            elsif $p1.hasflag('MIS') {
               return $p2 == $p1.mis ;
            }
        } elsif $p2.hasflag('CONCAVE') and defined $p2.rect {
            return $p1 == $p2.rect;
        }
        return False;

    }
    multi method pointsAreLine(int-list $a,int-list $b --> Bool){
           my $p1 = $!scrn.get_value($a[0],$a[1]);
           die 'Point ', $p1.str, ' not found.' unless defined $p1;
           my $p2 = $!scrn.get_value($b[0],$b[1]);
           die 'Point ', $p2.str, ' not found.' unless defined $p2;
           return self.pointsAreLine($p1,$p2);
    }
    
    multi method pointsAreSegment(Point $p1,Point $p2 --> Bool) {
      die 'p1 not defined' unless $p1.defined;
      die 'p2 not defined' unless $p2.defined;

      my ($which,$xv,$yv,$other);
      if $p1.x == $p2.x {
          $other = $p1.x;
          $which = 'y';  $yv = 'v'; $xv = 'other';
      } elsif $p1.y == $p2.y {
          $other = $p1.y;
          $which = 'x'; $yv = '$p1.y'; $xv = 'other';
      }
      else {
          die 'p1 and p2 are not on the same axe.';
      }
      if $p1.hasflag('RECTANGLE') and $p2.hasflag('RECTANGLE') {
          for $p1."$which"()+1 .. $p2."$which"()-1  -> $v {
              my $pt = $!scrn.get_value($::($xv),$::($yv));
              return False unless defined $pt;
              return False if $pt.hasflag('RECTANGLE');
              return False if $pt.hasflag('CONVEXE');
          }
          return True;
      }

      return False;
    }
    multi method pointsAreSegment(int-list $a,int-list $b --> Bool){
           my $p1 = $!scrn.get_value($a[0],$a[1]);
           die 'Point ', $p1.str, ' not found.' unless defined $p1;
           my $p2 = $!scrn.get_value($b[0],$b[1]);
           die 'Point ', $p2.str, ' not found.' unless defined $p2;
           return self.pointsAreSegment($p1,$p2);
    }



    
    method display_concave_angles {
        print $!fill_color_attr;
        for @!concaves_points -> $pt {
            $pt.fix;
            #print( $pt.direction );
            printf("%d,%d",$pt.x,$pt.y)# if $pt.direction eq 'X'; 
        }
       $!objcolor._;
    }
    method display_all_coordonnees {
        print $!fill_color_attr;
        for @!corner_points -> $pt {
            $pt.fix;
            printf("%d,%d",$pt.x,$pt.y);
       }
       $!objcolor._;
    }
    method draw {
        print $!border_color_attr;
        for @!lines -> $l {
            $l.draw;
        }
        #Les Mis
        $!objcolor._;
        $!objcolor.sequence8(LRED);
        for @!mis_diagonales -> $l {
            $l.draw;
        }
        $!objcolor.sequence8(LGREEN);
        for @!complete_rectangles -> $l {
            $l.draw;
        }
        self.display_all_coordonnees;

        $!objcolor._;
        gotoxy(1,1);
      }

    method index_rectangle(){
        for @!complete_rectangles -> $l {
            push @!rect_index[$l.b.x - 1 ] , $l.b.y;
        }
    }
    method split_vline(Line $vline,@lines) {
        return False if  $vline.direction ne 'v';
        my @lst = | @!rect_index[$vline.a.x - 1].grep({$_ > $vline.origin.y && $_ < $vline.destination.y }) if @!rect_index[$vline.a.x - 1];
        return False unless @lst;
        @lst .= sort;
        @lst .= unique;
        unshift @lst, $vline.origin.y;
        push @lst, $vline.destination.y;
        for @lst.kv -> $k,$v {
            push @lines, Line.new( ($vline.origin.x,@lst[$k - 1]) , ($vline.origin.x,$v), motif => '+' ) if $k > 0;
        }
        return True;
    }

    #Vérifie si le point est une ouverture ou une fermeture horizontale
    method open_or_close(Point $pt --> Str){
        #Si le point n'a pas de prev ET de next 'none' sera renvoyé
        return 'none' unless ($pt.prev and $pt.next);
        my Point $op; #Le point recherché.
        #Si 
        if $pt.hasflag('RECTANGLE') {
            if $pt.hasflag('CONCAVE') {
               $op := $pt.rect;
            } else {
               $op := $pt.rect;
            }
        } elsif $pt.prev.y == $pt.y {
            $op := $pt.prev;
        } elsif $pt.next.y == $pt.y {
            $op := $pt.next;
        }
        return ($op.x >  $pt.x) ?? 'OPEN' !! 'CLOSED';
    }
    
    method agregate(Line $vmis_or_part) {


    }

    method fill {
        
        my Point @allpoints;
        my (@xindex,@yindex);
        #Met les points des lignes de projections dans allpoints
        push @allpoints, .b for @!complete_rectangles;
        #Y ajoute tous les points d'angles
        append @allpoints,@!corner_points;
        #Les trie dans l'ordre x,y
        @allpoints .= sort: {.x,.y};
        #Ecrit les points dans le log
        for @allpoints -> $pt {
            $!log_fh.say($pt.str);
        }
        #Déclare un hash
        my %h;
        say '-' x 20 ~ ' Points de fermeture ' ~ '-' x 20 ;
        #Pour chaque point :  l'ordre, le point
        for @allpoints.kv -> $n,$pt {
            #$!log_fh.say($pt.str,' => ',self.open_or_close($pt));
            #Si l'ordre est > 0
            if $n > 0 {
                #Saute un tour si l'axe des x est différent du point précédent
                next if $pt.x ≠ @allpoints[$n - 1].x;
                #Fabrique la clé y_précédant_y.
                my $key = @allpoints[$n - 1].y.Str ~ '_' ~ $pt.y.Str;
                given self.open_or_close($pt) {
                    when 'OPEN' { # Si le point est ouvrant
                        %h{$key}{$pt.x} = 1; #Rempli le hash avec la clé, puis x
                    }
                    when 'CLOSED' {
                        if %h.EXISTS-KEY($key) { #Si la clé existe
                            #say $key, ' ',%h{$key}.kv[0] , ' : ', $pt.x; #Affiche : le clé, la valeur, et x;
                            my ($y1,$y2) = @allpoints[$n - 1].y + 1,$pt.y;
                            my ($x1,$x2) = %h{$key}.kv[0].Int + 1, $pt.x - 1;
                            my ($hlen,$vlen) = $x2 - $x1, $y2 - $y1;
                            #printf("(%d,%d)=>(%d,%d)\n",$x1 - 1 ,$x2 + 1,$y1 - 1,$y2);
                            printf("(%d,%d)=>(%d,%d)\n",  $y1 - 1,$y2,    $x1 - 1 ,$x2 + 1);
                            #Rectangle.new($x1,$y1,$hlen,$vlen,motif => 'K').draw;
                            %h{$key}:delete; #Supprime la clé
                        }

                    }
                }

                #$!log_fh.say($key);
            }
        }

        say '-' x 20 ~ ' Ce qui reste dans le hash, qui n\'a pas été fermé ' ~ '-' x 20 ;

        for %h.kv -> $k,$v {
            say $k , ' => ',$v ;
        }

#        my %h;
#        for (@!corner_points,@allpoints).flat.sort: {.x,.y } -> $pt {
#            $pt.setflag(self.open_or_close($pt));
#            $!log_fh.say($pt.str,' => ',self.open_or_close($pt));
#        } 


       exit; 
        for @allpoints -> $pt {
           push @xindex[$pt.x - 1],$pt.y;
           push @yindex[$pt.y - 1],$pt.x;
        }
        for @xindex -> $one {
            if $one {
                @$one .= sort if $one;
                @$one .= unique;
            }
        }
        $!log_fh.say('xindexes:');
        for @xindex -> $l {
            $!log_fh.say($l) if $l;
        }
        $!log_fh.say('yindexes:');
        for @yindex -> $l {
            $!log_fh.say($l) if $l;
        }
    }

    method set_border_motif( Int $m) {
        $!border_motif = $m;
    }

}

