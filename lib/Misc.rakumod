

sub export_subs(*@_) { Map.new( @_.map: { '&' ~ .name => $_ } ) }

constant STARTSEQ = 27.chr() ~ "[";
constant DEFAULT_INT_MOTIF = 43;
constant DEFAULT_MOTIF = '+';

subset int-list of Positional where { .all ~~ Int && .elems == 2}

sub EXPORT {
    %(
        export_subs(
            &assert,
            &gotoxy,
            &move_up,
            &move_down,
            &move_right,
            &move_left,
            &move_down_and_left,
            &move_up_and_left,
            &cursor,
            &nocursor,
            &erase,
            &clear_screen,
            &print_the_string,
            &return_the_string
        )
    )
}

multi assert($a is raw , &op ,$b is raw) {
     assert(($a,&op,$b));
}

multi assert (**@tests where all(@tests>>.elems) == 3) { 
    my Str @msgs;
    for @tests -> ($a is raw,$op is raw, $b is raw) {
        my ($x, $y )  = ($a.VAR.^name eq 'Scalar') ?? $a.VAR.name !! $a.VAR.^name, ($b.VAR.^name eq 'Scalar') ?? $b.VAR.name !! $b.VAR.^name;
        @msgs.push("Assertion $x "  ~ &$op.name.substr(7,*-1) ~ " $y failed : $x = $a, $y = $b") unless &$op($a,$b);
    }     
    if @msgs {
        my $message = join " ", @msgs;
        die $message;
    }
}

sub nocursor(Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ '?25l');
}
sub cursor(Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ '?25h');
}

sub gotoxy(Int $x, Int $y,Bool $rstr=False) {
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "%d;%dH",$y,$x);
}
sub move_up(Int $n,Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "%dA",$n);
}
sub move_down(Int $n,Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "%dB",$n);
}
sub move_right(Int $n,Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "%dC",$n);
}
sub move_left(Int $n,Bool $rstr=False) {
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "%dD",$n);
}
sub clear_screen(Bool $rstr=False) {
    my $print = ($rstr == False) ?? &printf !! &printf;
    return $print(STARTSEQ ~ '2J');
}
sub erase(Int $n,Bool $rstr=False) {
    my $print = ($rstr == False) ?? &printf !! &printf;
    return $print(STARTSEQ ~ '%dX',$n);
}


multi move_up_and_left(Bool $rstr=False) {
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "1A" ~ STARTSEQ ~ "1D");
}
multi move_up_and_left(Int $up,Int $left,Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print( STARTSEQ ~ "%dA" ~ STARTSEQ ~ "%dD",$up,$left);
}

multi move_down_and_left(Bool $rstr=False) {
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print(STARTSEQ ~ "1B" ~ STARTSEQ ~ "1D");
}

multi move_down_and_left(Int $down,Int $left,Bool $rstr=False){
    my $print = ($rstr == False) ?? &printf !! &sprintf;
    return $print( STARTSEQ ~ "%dB" ~ STARTSEQ ~ "%dD",$down,$left);
}

sub print_the_string( Str $s ) {
     print $s;
}
sub return_the_string(Str $s ) {
    return $s;
} 

CATCH {
    default {
        say "An exception occured : " ~ $_.payload;
   }
};

