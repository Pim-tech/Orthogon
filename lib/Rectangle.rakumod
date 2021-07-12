use Colors :DEFAULT, :COLORS;
use Misc;
use Screen;

constant HLINE = 0;
constant VLINE = 1;
constant UPLEFT = 2;
constant UPRIGHT = 3;
constant DWNLEFT = 4;
constant DWNRIGHT = 5;

constant SIMPLE = 1;
constant DOUBLE = 2;
constant HEAVY  = 3;

class Border {
    has Str $.motif;
    has Int $.color;
};

class Rectangle {
    has Int $!xpos;
    has Int $!ypos; 
    has Int $!hlen;
    has Int $!vlen;
    has Str $!motif;
    has Border $!border; 
    has Bool $!has_border;
    has Int $!color;
    has Int $!box;
    has Bool $!has_box;
    has Point $!a;
    has Point $!b;
    has $!boxes = 
    (
        "\c[BOX DRAWINGS LIGHT HORIZONTAL]",
        "\c[BOX DRAWINGS LIGHT VERTICAL]" ,
        "\c[BOX DRAWINGS LIGHT DOWN AND RIGHT]",
        "\c[BOX DRAWINGS LIGHT DOWN AND LEFT]",
        "\c[BOX DRAWINGS LIGHT UP AND RIGHT]",
        "\c[BOX DRAWINGS LIGHT UP AND LEFT]"
        ;
        "\c[BOX DRAWINGS DOUBLE HORIZONTAL]",
        "\c[BOX DRAWINGS DOUBLE VERTICAL]" ,
        "\c[BOX DRAWINGS DOUBLE DOWN AND RIGHT]",
        "\c[BOX DRAWINGS DOUBLE DOWN AND LEFT]",
        "\c[BOX DRAWINGS DOUBLE UP AND RIGHT]",
        "\c[BOX DRAWINGS DOUBLE UP AND LEFT]"
        ;
        "\c[BOX DRAWINGS HEAVY HORIZONTAL]",
        "\c[BOX DRAWINGS HEAVY VERTICAL]" ,
        "\c[BOX DRAWINGS HEAVY DOWN AND RIGHT]",
        "\c[BOX DRAWINGS HEAVY DOWN AND LEFT]",
        "\c[BOX DRAWINGS HEAVY UP AND RIGHT]",
        "\c[BOX DRAWINGS HEAVY UP AND LEFT]"
        ;
    );

    submethod BUILD(:$xpos,:$ypos,:$hlen,:$vlen,:$motif='x',:$color=WHITE+BBLACK,:$has_border=False,:$border_motif='*',:$border_color=LWHITE+BBLACK,:$box = 0,:$a,:$b) {
        if (not $xpos.defined and not $hlen.defined)   and $a.defined and $b.defined {
            ($!xpos,$!ypos,$!hlen,$!vlen) = $a.x,$a.y,$b.x - $a.x,$b.y - $a.y;
        } else {
            ($!xpos,$!ypos,$!hlen,$!vlen) = $xpos,$ypos,$hlen,$vlen;
        }
        ($!motif,$!color,$!has_border) = $motif,$color,$has_border;
        if $box == 0 and ($has_border or $border_motif ne '*' or $border_color ≠ LWHITE+BBLACK) {
           $!has_border = True;
           $!border := Border.new(motif => $border_motif,color => $border_color); 
        } elsif $box > 0 {
            if $border_motif ne '*' {
                die "You may not give border_motif with boxes.";
            }
            $!border := Border.new(color => $border_color); 
            $!has_box = True;
            $!box = $box - 1;
        }

    }
    multi method new($xpos,$ypos,$hlen,$vlen,:$motif='x',:$color=LWHITE+BBLACK,:$has_border=False,:$border_motif='*',:$border_color=LWHITE+BBLACK,:$box=0){
        self.bless(:$xpos,:$ypos,:$hlen,:$vlen,:$motif,:$color,:$has_border,:$border_color,:$border_motif,:$box);
    }
    multi method new($xpos,$ypos,:$hlen,:$vlen,:$motif='x',:$color=LWHITE+BBLACK,:$has_border=False,:$border_motif='*',:$border_color=LWHITE+BBLACK,:$box=0){
        self.bless(:$xpos,:$ypos,:$hlen,:$vlen,:$motif,:$color,:$has_border,:$border_color,:$border_motif,:$box);
    }
    multi method new(Point $a,Point $b,:$motif='x',:$color=LWHITE+BBLACK,:$has_border=False,:$border_motif='*',:$border_color=LWHITE+BBLACK,:$box=0){
        self.bless(:$a,:$b,:$motif,:$color,:$has_border,:$border_color,:$border_motif,:$box);
    }
    method show(){
       say 'xpos: ' ~ $!xpos;
       say 'ypos: ' ~ $!ypos;
       say 'hlen: ' ~ $!hlen;
       say 'vlen: ' ~ $!vlen;
       say 'motif: ' ~ $!motif;
       say 'color: ' ~ $!color;
       if $!has_border {
           say 'border_motif: ' ~ $!border.motif;
           say 'border_color: ' ~ $!border.color;
       }
    }
    method draw() {
       gotoxy($!xpos,$!ypos);
       my ($xpos,$ypos,$hlen,$vlen) = $!xpos,$!ypos,$!hlen,$!vlen;
       my ($c,$b_color,$s);
       if $!has_border or $!has_box {
           $c = Color.new;
           $b_color = $c.sequence8($!border.color,str => True);
       }

       if $!has_border {
           my $h_border = $!border.motif x $!hlen;
           my $v_border_right = (move_down_and_left(True) ~ $!border.motif ) x ($!vlen - 1);
           my $v_border_left = ($!border.motif ~ move_down_and_left(True)  ) x ($!vlen - 1);
           $s = ($b_color ~ $h_border ~ $v_border_right ~ gotoxy($!xpos,$!ypos,True) ~ $v_border_left ~ $h_border ~ $c._(True)); 
       } elsif $!has_box {
           my $h_border_top = $!boxes[$!box][UPLEFT] ~ $!boxes[$!box][HLINE] x ($!hlen - 2 ) ~ $!boxes[$!box][UPRIGHT];
           my $h_border_bottom = $!boxes[$!box][DWNLEFT] ~ $!boxes[$!box][HLINE] x ($!hlen - 2 ) ~ $!boxes[$!box][DWNRIGHT];
           my $v_border_right = (move_down_and_left(True) ~ $!boxes[$!box][VLINE]  ) x ($!vlen - 2);
           my $v_border_left = ($!boxes[$!box][VLINE] ~ move_down_and_left(True)  ) x ($!vlen - 2);
           $s = ($b_color ~ $h_border_top ~ $v_border_right ~ gotoxy($!xpos,$!ypos+1,True) ~ $v_border_left  ~ $h_border_bottom ~ $c._(True)); 
       }
       if $!has_border or $!has_box {
           print $s;
           gotoxy($!xpos+1,$!ypos+1);
           $hlen-=2;
           $vlen-=2;
           $xpos++;
           $ypos++;
       }

       my $line = $!motif x $hlen;
       my $bc = Color.new;
       my $bc_color = $bc.sequence8($!color,str => True);
       my $bloc = $bc_color ~ $line;
       for 1 .. $vlen - 1  -> $n {
           $bloc ~=  ( gotoxy($xpos , $ypos + $n,True) ~ $line ); 
       }
       $bloc ~= $bc._(True);
       print $bloc;
     }
 };
    
