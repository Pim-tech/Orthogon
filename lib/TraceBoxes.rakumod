unit module TraceBoxes;

use Misc;
use Events :EVENTS, :DEFAULT;



class TraceBox is export {
    has Str $.motif is rw = '*';
    has Int $!xpos;
    has Int $!ypos;
    has int-list @!done; 
    has int-list @!angles;
    has $!event;
    has Str $!currrent_direction;
    has Str @directions;
    has Str $!virage;
    has SetHash $!done; 
    has SetHash $!angles;
    has Str $.output='noname.raku';
    has Hash %corners = {
        simple => {
            rightdown  => "\c[TOP RIGHT CORNER]",
            downleft   => "\c[BOTTOM RIGHT CORNER]",
            upright    => "\c[TOP LEFT CORNER]",
            leftup     => "\c[BOTTOM LEFT CORNER]",
            leftdown   => "\c[TOP LEFT CORNER]",
            downright  => "\c[BOTTOM LEFT CORNER]",
            rightup    => "\c[BOTTOM RIGHT CORNER]",
            upleft     => "\c[TOP RIGHT CORNER]",
            vertical   => "\c[BOX DRAWINGS LIGHT VERTICAL]",
            horizontal => "\c[BOX DRAWINGS LIGHT HORIZONTAL]",
            crux       => "\c[BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL]",
            T_HEAD_AT_RIGHT   => "\c[BOX DRAWINGS LIGHT VERTICAL AND LEFT]",
            T_HEAD_AT_LEFT    => "\c[BOX DRAWINGS LIGHT VERTICAL AND RIGHT]",
            T           => "\c[BOX DRAWINGS LIGHT DOWN AND HORIZONTAL]",
            REVERSE_T    => "\c[BOX DRAWINGS LIGHT UP AND HORIZONTAL]"
        },
        double => {
        }
    };


    method init {
        clear_screen();
        #nocursor();
    }
    method restore() {
        cursor();
    }
    method start_at(:$x,:$y) {
       $!currrent_direction = 'start';
       #push @!angles, ($x,$y);
       $!done .= new;
       $!angles .= new;
       self.init();
        gotoxy($x,$y);
        $!xpos = $x;
        $!ypos = $y;
        $!event = Event.new(
            events => {
               (KEY_RIGHT) => self.get_method_link('write_right') ,
               (KEY_LEFT) => self.get_method_link('write_left'),
               (KEY_UP) => self.get_method_link('write_up'),
               (KEY_DOWN) => self.get_method_link('write_down'),
               u        => self.get_method_link('undo'),
               l        => self.get_method_link('go_right'),
               h        => self.get_method_link('go_left'),
               j        => self.get_method_link('go_down'),
               k        => self.get_method_link('go_up'),
               d        => self.get_method_link('undo_current_line'),
               s        => self.get_method_link('save') 
           },
           exit_key => 'q',
           resume => self.get_method_link('resume'),
           any-key  => self.get_method_link('on_all_keys'),

       );

       $!event.wait_event()
    }
    sub decont( $x ) {
        $x;
    }

    method !set_virage(Str $direction) {
        #$!currrent_direction = 'start' unless defined $!currrent_direction;
        if $!currrent_direction ne $direction {
             $!virage = $!currrent_direction ~  $direction;
             $!currrent_direction = $direction;
             push @!directions,$!currrent_direction;
             if @!done.elems > 0 {
                 push @!angles, @!done.tail;
                 my ($x,$y) = @!done.tail;
                 $!angles.set($x.Str ~ '_' ~ $y.Str);
             } 
             given $!virage {
                 when 'rightdown' {}
                 when 'downleft' {}
                 when 'upright' {}
                 when 'leftup' {}
                 when 'leftdown' {}
                 when 'downright' {}
                 when 'rightup' {}
                 when 'upleft' {}
                 when /^ start/ { 
                     # A réfléchir car ce cas correspond au else
                 }
             }
      } else {
          given $direction {
              when 'rigth' | 'left' {}
              when 'up' | 'down'    {}
          }

      }

    }

    method go_right(){
        $!xpos++;
    }
    method go_left(){
        $!xpos-- if $!xpos > 1;
    }
    method go_up(){
        $!ypos-- if $!ypos > 1;
    }
    method go_down(){
        $!ypos++;
    }
    method write_right(){
        print $!motif;
        self!stack_in();
        $!xpos++;
        self!set_virage('right');
    }
    method write_left(){
        if $!xpos > 1 {
            print $!motif;
            self!stack_in();
            $!xpos--;
            self!set_virage('left');
       }
    }
    method write_up(){
        if $!ypos > 1 {
            print $!motif;
            self!stack_in();
            $!ypos--;
            self!set_virage('up');
        }
    }
    method write_down(){
        print $!motif;
        self!stack_in();
        $!ypos++;
        self!set_virage('down');
    }
    method undo_current_line() {
        loop  {
            last if  @!done.elems == 0;
            last if (@!done.tail cmp @!angles.tail) == Same ;
            self.undo();
        }  
        if @!done.elems > 0 {
            ($!xpos,$!ypos) = @!done.tail;
        } else {
             ($!xpos,$!ypos) =   @!angles[0];
        }
        self.undo();
    }
    method undo {
        if @!done.elems > 0 {
             my ($x,$y) = self!stack_out();
             gotoxy($x,$y);
             my $key = $x.Str ~ '_' ~ $y.Str;
             if $!angles.EXISTS-KEY($key) {
                 pop(@!angles);
                 pop(@!directions);
                 $!currrent_direction = @!directions.tail || 'start';
                 $!angles.unset($key);
             }
            ($!xpos,$!ypos) = $x,$y;
            erase(1);
        }
    }
    method save(){
        my $fh  = open :w,$!output;
        my Str $content = 'my $p = Polygone.new(';
        $content ~= "\n";
        my @lines;
         for  0 .. @!angles.end -> $n {
          if  ($n % 2) == 0 {
            if ($n + 1) < @!angles.end {
                my ($one,$two) =  @!angles[$n .. $n+1];
                my ($a,$b) = @$one; my ($c,$d) = @$two;
                push @lines, '(' ~ $a.Str ~ ',' ~ $b.Str ~ '),(' ~ $c.Str ~ ',' ~ $d.Str ~ ')';
            } else {
                my ($a,$b) = @!angles[$n];
                push @lines, '(' ~ $a.Str ~ ',' ~ $b.Str ~ ')';
            }
          }
        }
        $content ~=  join ",\n", @lines;
        $content ~= ");\n";
        $fh.say: $content;
        $fh.close;
    }
    method !stack_in() {
        push @!done, (decont($!xpos),decont($!ypos));
        $!done.set($!xpos.Str ~ '_' ~ $!ypos.Str);
    }

    method !stack_out() {
        my ($x,$y) = pop(@!done);
        $!done.unset($x.Str ~ '_' ~ $y.Str); 
        return ($x,$y);
    }

    method resume() {
        self.restore();
    }
    method on_all_keys {
        gotoxy(1,1);
        printf("x: %-3s,y: %-3s, %-8s",$!xpos,$!ypos,$!currrent_direction);
#        printf("angle: %-300s",@!angles.Str);
#        gotoxy(1,81);
#        printf("%-316s",@!done.Str);
        gotoxy($!xpos,$!ypos);
    }
    method get_method_link(Str $name) {
       my $method = self.^lookup($name);
       my $bound_method = $method.assuming(self);
       return $bound_method;
   }


}
