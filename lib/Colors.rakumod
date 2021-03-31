use Misc; 
unit module Colors;

#These constant will be exported into tab COLORS
my package EXPORT::COLORS {
    constant BLACK = 0;
    constant RED = 1;
    constant GREEN = 2;
    constant BROWN = 3;
    constant BLUE = 4;         #couleurs de bases
    constant MAGENTA = 5;
    constant CYAN = 6;
    constant WHITE = 7;
    
    constant LBLACK = 8;
    constant LRED = 9;
    constant LGREEN = 10;
    constant LYELLOW = 11;
    constant LBLUE = 12;        
    constant LMAGENTA = 13;        #couleurs claires
    constant LCYAN = 14; 
    constant LWHITE = 15;
    
    
    constant BBLACK = 0;         # Les couleurs de fond commencent  a  16
    constant BRED = 16;
    constant BGREEN = 32;       
    constant BYELLOW = 48;        #couleurs de fond
    constant BBLUE = 64;
    constant BMAGENTA = 80;
    constant BCYAN = 96;
    constant BWHITE = 112;
    
    constant LBBLACK = 128;
    constant LBRED = 144;
    constant LBGREEN = 160;
    constant LBYELLOW = 176;
    constant LBBLUE = 192;
    constant LBMAGENTA = 208;
    constant LBCYAN = 224;
    constant LBWHITE = 240;
    
    constant NOCOLOR = 129;
    
    constant BOLD = 1;
    constant LOW = 2;
    constant ITALIC = 3;
    constant UNDERLINED = 4;
    constant CONSFGLIGHT = 5; #clignote sur xterm, en console couleur claire d'avant plant
    constant BLINK = 6;       #clignote sur xterm seulement
    constant INVERSE = 7;
    constant MASQUED = 8;
    constant STRIKE  = 9;
    constant REINIT = 10;       
    constant NULLC = 11;     #needded to display chars to build boxes
    constant NULLCCMETA = 12;
    constant NORMAL1 = 21;
    constant NORMAL2 = 22;
    constant NO_UNDERLINE = 24;
    constant NO_BLINK = 25;
    constant NOINVERSE = 27;
    constant GRMOD = "\016";
}


#Theses constants remain in module scope.
constant DRKCOLMSK = 0b00000111;
constant LICOLMSK  = 0b00001000;
constant DRKBGMSK  = 0b01110000;
constant LIBGMSK   = 0b10000000;
constant COLOR_256_MASQ = 0b0000000011111111;
constant BGND_256_MASQ  = 0b1111111100000000;


constant COLOR_ANSI = 1;
constant COLOR_256 = 2;
constant COLOR_TRUECOLOR = 3;


subset uInt8 of Int where * ~~ 0..255;
subset uInt16 of Int where * ~~ 0..65535;


class Color is export {

    has Int $!current_color = 0;
    has Int $!current_bg = -1;
    has Int $!current_mode = 0;
    has Bool $!current_li = False;
    has uint8 $!current_color_256 = 0;
    has uint8 $!current_bgcolor_256 = 0;
    has Str $!format;

    #Optimizes a sequences to not repeat actual state
    method sequence8(uInt8 $attr, $mode?,:$str=False) {
       my $print = ($str == False) ?? &printf !! &sprintf;
       my uint8 $color =  ($attr +& DRKCOLMSK);
       my Bool $is_licolor   =  (($attr +& LICOLMSK) +> 3).Bool;
       my uint8 $bgcolor    =  ($attr +& DRKBGMSK) +> 4;
       my Bool $is_libgcolor      = (($attr +& LIBGMSK) +> 7).Bool; 
    
       my @seq;   
       my Bool $reset;
       if ($!current_li == True and $is_licolor == False) || ($mode.defined and $mode == 0) {
           $reset = True;
           push @seq,'0';
       } else {
           $reset=False;
           push @seq ,'1' if $is_licolor == True and  $!current_li == False;
       }
       push @seq ,$color + 30 if  $reset == True || $color ≠ $!current_color; 
       my $n_light = $is_libgcolor ?? 100 !! 40;
       my $bg = $bgcolor + $n_light; #$bg is bgcolor + lightness;
       push @seq, $bg  if  $reset == True || $bg ≠ $!current_bg;
       push @seq, $mode if $mode.defined and $mode > 0 and $mode ≠ $!current_mode;
       

       $!current_color = $color;
       $!current_bg = $bg;
       $!current_li = $is_licolor;
       $!current_mode = $mode if $mode.defined;

       my Str $seq = chr(27) ~ '[' ~  join(';', @seq) ~ 'm';
       #print join(';' , @seq) ~ ' : ';
       return $print($seq);
    }
   
    method fixed_width(Str $str is copy,$width,$seek? --> Str)  {
         $str .= indent($seek) if $seek.defined;
         if $width.defined {
             return $str.substr(0,$width) if $str.chars > $width;
             return $str ~ ( ' ' x ( $width - $str.chars) ) if $str.chars < $width ;
         }
         return $str;   
    } 
    #256 colors in one attr
    multi method sequence256(uInt16 $attr,:$str=False){
        my uint8 $color = ($attr +& COLOR_256_MASQ);
        my uint8 $bgcolor = ($attr +& BGND_256_MASQ) +> 8;
        return self.sequence256($color,$bgcolor,:$str);
    }
    #256 color, color and background 
     multi method sequence256(uInt8 $color, uInt8 $bgcolor,:$str=False) {
        my @seq;
        my $print = ($str == False) ?? &print_the_string !! &return_the_string;
        push @seq, 38,5,$color if $color ≠ $!current_color_256;
        push @seq, 48,5,$bgcolor if $bgcolor ≠ $!current_bgcolor_256;
        $!current_color_256 = $color;
        $!current_bgcolor_256 = $bgcolor;
        my Str $seq = chr(27) ~ '[' ~  join(';', @seq) ~ 'm';
        return $print($seq);
    }

    method print(Str $s,uInt8 $attr,$mode?,:$str=False,:$reset=True,:$fixed_width,:$spacing) {
       my $print = ($str == False) ?? &print_the_string !! &return_the_string;
       my $chaine = self.sequence8($attr,$mode,str => True);
       $chaine ~= ($fixed_width.defined or $spacing.defined) ?? self.fixed_width($s,$fixed_width,$spacing) !! $s;
       $chaine ~= self._(True) if $reset === True;
       return $print($chaine);
    }
    method say(Str $s,uInt8 $attr,$mode?,:$str=False,:$reset=True,:$fixed_width,:$spacing) {
        my $print = ($str == False) ?? &print_the_string !! &return_the_string;
        my $chaine = self.print($s,$attr,$mode,:$reset,str => True,:$fixed_width,:$spacing);
        $chaine ~= "\n";
        return $print($chaine);
    }
    multi method print256(Str $s,uInt16 $color,:$str=False,:$reset=True,:$fixed_width,:$spacing) {
        my $print = ($str == False) ?? &print_the_string !! &return_the_string;
        my $chaine = self.sequence256($color,str => True);
        $chaine ~= ($fixed_width.defined or $spacing.defined) ?? self.fixed_width($s,$fixed_width,$spacing) !! $s;
        $chaine ~= self._(True) if $reset === True;
        return $print($chaine);
    }
    multi method print256(Str $s,uInt8 $fg,uInt8 $bg,:$str=False,:$reset=True,:$fixed_width,:$spacing) {
        my $print = ($str == False) ?? &print_the_string !! &return_the_string;
        my $chaine = self.sequence256($fg,$bg,str => True);
        $chaine ~= ($fixed_width.defined or $spacing.defined) ?? self.fixed_width($s,$fixed_width,$spacing) !! $s;
        $chaine ~= self._(True) if $reset === True;
        return $print($chaine);
    }
    multi method say256(Str $s,uInt16 $attr,:$str=False,:$reset=True,:$fixed_width,:$spacing){
        my $print = ($str == False) ?? &print_the_string !! &return_the_string;
        my $chaine = self.print256($s,$attr,:$reset,str => True,:$fixed_width,:$spacing);
        $chaine ~= "\n";
        return $print($chaine);
    }
    multi method say256(Str $s,uInt8 $bg,uInt8 $fg,:$str=False,:$reset=True,:$fixed_width,:$spacing){
        my $print = ($str == False) ?? &print_the_string !! &return_the_string;
        my $chaine = self.print256($s,$fg,$bg,:$reset,str => True,:$fixed_width,:$spacing);
        $chaine ~= "\n";
        return $print($chaine);
    }


    method _($str = False) {
       my $print = ($str == False) ?? &printf !! &sprintf;
        return $print(chr(27) ~ "[0m");
    }
}
