unit module Screen;
use Misc;

constant LINE      = 0b0000000000000001;
constant CONCAVE   = 0b0000000000000010;
constant DIAGONALE = 0b0000000000000100;
constant MIS       = 0b0000000000001000;
constant RECTANGLE = 0b0000000000010000;
constant CONVEXE   = 0b0000000000100000;
constant MARKED    = 0b0000000001000000;
constant OPEN      = 0b0000000010000000;
constant CLOSED    = 0b0000000100000000;
constant FLAGMASK  = 0b1111111111111111; 

class Point is export {
    has Int $.x; 
    has Int $.y;
    has Point $.prev  is rw;
    has Point $.next  is rw;
    has Point $.rect  is rw;
    has Point $.mis   is rw;
    has @lines;#Due tu circular module not possible we cannot type has a Line Array objects
    has Str  $.direction is rw = 'X';
    has Int $!flags = 0 ;
    has Str $.setflag;
    
    submethod TWEAK() {
        self.setflag($!setflag) if $!setflag;
    }
    multi method new(Int $x, Int $y,:$setflag='') {
        self.bless(:$x,:$y,:$setflag);
    }
    multi method new(int-list $n,:$setflag=''){
        self.bless(x => $n[0],y => $n[1],:$setflag);
    }
    method fix() {
        gotoxy($!x,$!y);
    }
    method show() {
        say "x : $.x, y : $.y";
    }
    method str() {
        return "x : $.x, y : $.y";
    }
    method setflag(Str $flag){
        $!flags = $!flags +| ::($flag);
        $!flags = $!flags  +& ( CONCAVE +^ FLAGMASK)  if $flag eq 'CONVEXE';
        $!flags = $!flags  +& ( CONVEXE +^ FLAGMASK)  if $flag eq 'CONCAVE';
        if $flag eq 'LINE' {
            $!flags = $!flags  +& ( CONCAVE +^ FLAGMASK);
            $!flags = $!flags  +& ( CONVEXE +^ FLAGMASK);
        }

        return $!flags;
    }
    method unsetflag(Str $flag) {
        $!flags = $!flags +& ( ::($flag) +^ FLAGMASK);
    }
    method hasflag(Str $flag --> Bool) {
        return ($!flags +& ::($flag)).Bool;
    }
}

multi sub infix:<==>(Point $p1, Point $p2 --> Bool) is export {
    return $p1.x == $p2.x && $p1.y == $p2.y; 
}

class ScreenBuffer is export {
    has @!buffer;
    has (@!xy,@!yx);

    method make_indices() {
        @!xy = ();
        @!yx = ();
         for 0 .. @!buffer.end -> $tx { #Les x
            if @!buffer[$tx] {
                my $ally = @!buffer[$tx];
                for 0 .. @$ally.end -> $ty { #Les y;
                    if @$ally[$ty] {
                        push @!xy[$tx],$ty;
                        push @!yx[$ty], $tx;
                    }
                }
            }
        }

    }

    multi method load_value(Int $x,Int $y,$value,:$push=False) {
        ($push === False) ?? ( @!buffer[$x-1;$y-1] = $value ) !! (push @!buffer[$x-1;$y-1], $value);
    }
    multi method load_value(Point $p,$value = Any,:$push=False){
        my $val := ( not $value ) ?? $p !! $value;
        ($push === False) ?? ( @!buffer[$p.x-1;$p.y-1] = $val) !! ( push @!buffer[$p.x - 1; $p.y - 1], $val);
    }
    multi method get_value(Int $x,Int $y) {
        return-rw @!buffer[$x-1;$y-1];
    }
    multi method get_value(Point $p) {
        return-rw @!buffer[$p.x-1;$p.y-1];
    }

    #Permits to find the next vertices point on the left (or right) without looping
    method for_xrange_aty(Int $y,Int $x1,Int $x2?,:$sens = 1) {
        my $yindices = @!yx[$y - 1];
        my $nextindice = @$yindices.first($x1 - 1,:k) + $sens;
        my $xnextindice = @$yindices[$nextindice];
        if $x2 {
            return @!buffer[$xnextindice;$y - 1] if @!buffer[$xnextindice;$y - 1] and ($x2 - 1) > $xnextindice;
            return;
        }
        return @!buffer[$xnextindice;$y - 1] if @!buffer[$xnextindice;$y - 1];
    }

    method for_yrange_atx(Int $x,Int $y1,Int $y2?) {
        my $ypoints = @!buffer[$x - 1];
        my $next = @!xy[$x - 1].first($y1 - 1,:k) + 1;
        my $next_indice = @!xy[$x - 1][$next];
        if $y2 {
           return @$ypoints[$next_indice] if @$ypoints[$next_indice] and ($y2 - 1) > $next_indice;
           return;
        }
        return @$ypoints[$next_indice] if @$ypoints[$next_indice]; 
    } 

    method get_xy(Int $x){ return @!xy[$x - 1];}

    method getyx(Int $y) { return @!yx[$y - 1];}
}







