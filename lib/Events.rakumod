
unit module Events;
use NativeCall;
use Term::ReadKey;
use Term::termios;

my package EXPORT::EVENTS {

    constant KEY_ESCAPE  = '<control-001B>';
    constant KEY_BACKSPACE = '<control-007F>';
    constant KEY_ENTER   = '<control-000A>';
    constant KEY_TAB     = '<control-0009>';
    constant KEY_PG_DOWN = '[6~';
    constant KEY_PG_UP   = '[5~';
    constant KEY_DOWN    = '[b';
    constant KEY_UP      = '[a';
    constant KEY_RIGHT   = '[c';
    constant KEY_LEFT    = '[d';
    constant KEY_HOME    = '[h';
    constant KEY_END     = '[f';
    constant KEY_INSERT  = '[2~';
    constant KEY_DEL     = '[3~';

    constant KEY_F1      = 'op';
    constant KEY_F2      = 'oq';
    constant KEY_F3      = 'or';
    constant KEY_F4      = 'os';
    constant KEY_F5      = '[15~';
    constant KEY_F6      = '[17~';
    constant KEY_F7      = '[18~';
    constant KEY_F8      = '[19~';
    constant KEY_F9      = '[20~';
    constant KEY_F10     = '[21~';
    constant KEY_F11     = '[23~';
    constant KEY_F12     = '[24~';

}

constant LIBPATH = "$*CWD/rtwl/mngrterm";

class Event is export {
    has Str $.method;
    has $.exit_key;
    has $.resume;
    has %.events;
    has  $!estr;
    has  $.verbose;
    has $.write_right;
    has $.any-key;
    my $ap = 'EXPORT::EVENTS::';
    #my %all_in_events := ::($ap);
    
    my %evts = EXPORT::EVENTS::;
    my $key_enter = %evts{'KEY_ENTER'};
    my $key_escape = %evts{'KEY_ESCAPE'};
    my $key_backspace = %evts{'KEY_BACKSPACE'};
    my $key_tab = %evts{'KEY_TAB'};
    say "KEY_ENTER: ", EXPORT::EVENTS::{'KEY_ENTER'};
    


    method wait_event() {
        react {
            my Str $sequence = '';
            whenever key-pressed(:!echo) {
                given .fc {
                       my $c := $_;
                       given .uniname {
                           when  $key_escape |  $key_backspace  |  $key_enter | $key_tab {
                              if  %!events.EXISTS-KEY($_) {
                                  my $thesub = %!events{$_};
                                      if $thesub.^name ~~ /^ Sub/ {
                                          $thesub(); 
                                      }
                              }
                              $sequence = '';
                            }
                           default { 
                               printf("c is '%s'\n",$_) if $!verbose === True;
                               $sequence ~= $c 
                           };
                       }
                        given $sequence {
                            when $!exit_key { 
                                say 'Exiting!';
                                if $!resume {
                                    if $!resume.^name ~~ /^ Sub/ {
                                        $!resume();
                                    }
                                }
                               done;
                           }
                            when %!events.EXISTS-KEY($sequence) { 
                                 my $thesub = %!events{$sequence};
                                 if $thesub.^name ~~ /^ Sub/ {
                                     $thesub();
                                     $sequence = '';
                                 }
                                 if $!any-key.^name ~~ /^ Sub/ {
                                     $!any-key();
                                 }
                            }
                            default { 
                                say "sequence is '" ,$sequence , "'" if $!verbose === True; 
                            }
                        }
                        
                    }
                }
            }
    }

 }

