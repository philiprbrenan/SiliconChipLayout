#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/ -I/home/phil/perl/cpan/SvgSimple/lib/
#-------------------------------------------------------------------------------
# Layout the gates of a silicon chip
# Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2024
#-------------------------------------------------------------------------------
use v5.34;
package Silicon::Chip::Layout;
our $VERSION = 20240308;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use Svg::Simple;

makeDieConfess;

my $debug = 0;                                                                  # Debug if set
sub debugMask {1}                                                               # Adds a grid to the drawing of a bus line

#D1 Construct                                                                   # Create a Silicon chip wiring diagram on one or more levels as necessary to make the connections requested.

sub new(%)                                                                      # New gates layout diagram.
 {my (%options) = @_;                                                           # Options
  genHash(__PACKAGE__,                                                          # Gates diagram
    %options,                                                                   # Options
    gates => [],                                                                # Gates on diagram
   );
 }

sub gate($%)                                                                    # New gate on a gates diagram.
 {my ($D, %options) = @_;                                                       # Diagram, options

  my ($x, $y, $w, $h, $t, $l) = @options{qw(x y w h t l)};
  defined($x) or confess "x";
  defined($y) or confess "y";
  defined($w) or confess "width";
  defined($h) or confess "height";
  defined($t) or confess "type";
  defined($l) or confess "label";

  my $g = genHash(__PACKAGE__,                                                  # Gate
    x => $x,                                                                    # X upper left corner of gate
    y => $y,                                                                    # Y upper left corner of gate
    h => $h,                                                                    # Height of gate
    w => $w,                                                                    # Width of gate
    t => $t,                                                                    # Type of gate
    l => $l,                                                                    # Type of gate
   );

  push $D->gates->@*, $g;                                                       # Append gate to diagram

  $g
 }

#D1 Visualize                                                                   # Visualize the layout of the gates

sub svg($%)                                                                     # Draw the gates
 {my ($D, %options) = @_;                                                       # Diagram, options

  my @defaults = (defaults=>                                                    # Default values
   {stroke_width => 1,
    font_size    => 1/4,
    opacity      => 3/4,
   });

  my $color   =                                                                 # Colors of gates
   {q(input)  => "green",
    q(output) => "orange",
    q(not)    => "red",
    q(and)    => "darkRed",
    q(nand)   => "Red",
    q(or)     => "darkBlue",
    q(nor)    => "Blue",
    q(xor)    => "darkGreen",
    q(nxor)   => "Green",
    q(one)    => "Navy",
    q(zero)   => "Black",
   };

  my $svg = Svg::Simple::new(@defaults, %options, grid=>debugMask ? 1 : 0);     # Draw each wire via Svg. Grid set to 1 produces a grid that can be helpful debugging layout problems

  for my $g($D->gates->@*)                                                      # Each gate
   {my ($x, $y, $w, $h, $t, $l) = @$g{qw(x y w h t l)};
    my $X  = $x+$w-1/10; my $xx = $x+$w/2;
    my $y1 = $y+$h/3; my $y2 = $y+$h/2; my $y3 = $y+2*$h/3;  my $Y = $y+$h;
    my $c  = $$color{$t};
    defined($c) or confess "No color for $t";

    my sub Not()
     {if ($t =~ m(\An))
       {$svg->circle(cx=>$X, cy=>$y2, r=>1/10, fill_opacity=>0, stroke_width=>1/20, stroke=>"gold");
       }
     }

    if    ($t eq "input")
     {$svg->circle(cx=>$x+1/2, cy=>$y+1/2, r =>1/3,      fill=>$c);
     }
    elsif ($t eq "output")
     {$svg->rect(x=>$x,     y=>$y, width=>1, height =>1, fill=>$c);
     }
    elsif ($t eq "not" or $t eq "continue")
     {$svg->path(d=>"M $x $y L $X $y2 L $x $Y L $x $y ", stroke_width=>1/20, stroke=>$c, fill_opacity=>0);
      Not();
     }
    elsif ($t eq "or" or $t eq "nor")
     {$svg->path(d=>"M $x $y L $X $y1 L $X $y3 L $x $Y L $xx $y2 L $x $y", stroke_width=>1/20, stroke=>$c, fill_opacity=>0);
      Not();
     }
    elsif ($t eq "and" or $t eq "nand")
     {$svg->path(d=>"M $x $y L $X $y1 L $X $y3 L $x $Y L $x $y", stroke_width=>1/20, stroke=>$c, fill_opacity=>0);
      Not();
     }
    elsif ($t eq "xor" or $t eq "nxor")
     {$svg->path(d=>"M $x $y L $X $y2 L $x $Y L $xx $y2 L $x $y ", stroke_width=>1/20, stroke=>$c, fill_opacity=>0);
      Not();
     }
    elsif ($t eq "one" or $t eq "zero")
     {$svg->text(x=>$x, y=>$y, fill=>$c, fill_opacity=>1, text_anchor=>"start", dominant_baseline=>"hanging", cdata=>($t eq "one" ? "1" : "0"));
      $svg->rect(x=>$x, y=>$y, width=>1, height=>1, fill_opacity=>0, stroke=>$c, stroke_opacity=>1, stroke_width=>1/40);
     }
    $svg->text  (x=>$x+$w/2, y=>$y+$h/2,
      text_anchor=>"middle", alignment_baseline=>"middle", cdata=>$l);
   }

  my $t = $svg->print(%options);                                                # Text of svg

  if (my $f = $options{file})                                                   # Optionally write to an svg file
   {owf(fpe(q(svg), $f, q(svg)), $t)
   }

  $t
 }

#D0
#-------------------------------------------------------------------------------
# Export
#-------------------------------------------------------------------------------

use Exporter qw(import);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# containingFolder

@ISA          = qw(Exporter);
@EXPORT       = qw();
@EXPORT_OK    = qw();
%EXPORT_TAGS = (all=>[@EXPORT, @EXPORT_OK]);

#Images https://raw.githubusercontent.com/philiprbrenan/SiliconChipLayout/main/lib/Silicon/Chip/svg/

=pod

=encoding utf-8

=for html <p><a href="https://github.com/philiprbrenan/SiliconChipLayout"><img src="https://github.com/philiprbrenan/SiliconChipLayout/workflows/Test/badge.svg"></a>

=head1 Name

Silicon::Chip::Layout - Layout the gates of a silicon chip L<silicon|https://en.wikipedia.org/wiki/Silicon> L<chip|https://en.wikipedia.org/wiki/Integrated_circuit> to combine L<logic gates|https://en.wikipedia.org/wiki/Logic_gate> to transform software into hardware.

=head1 Synopsis

=for html <p><img src="https://raw.githubusercontent.com/philiprbrenan/SiliconChipWiring/main/lib/Silicon/Chip/svg/square.svg">

=head1 Description

=cut

goto finish if caller;
clearFolder(q(svg), 99);                                                        # Clear the output svg folder
my $start = time;
eval "use Test::More";
eval "Test::More->builder->output('/dev/null')" if -e q(/home/phil/);
eval {goto latest};

my sub  ok($)        {!$_[0] and confess; &ok( $_[0])}
my sub nok($)        {&ok(!$_[0])}
my sub is_deeply($$) {&is_deeply(@_)}

# Tests

if (1)
 {my $d = new;                                                                  #Tnew #Tgate #Tsvg
     $d->gate(x=>1, y=>1, w=>1, h=>1, t=>"input",  l=>"i1");
     $d->gate(x=>1, y=>2, w=>1, h=>1, t=>"output", l=>"o1");
     $d->gate(x=>2, y=>1, w=>1, h=>2, t=>"or",     l=>"or");
     $d->gate(x=>2, y=>3, w=>1, h=>2, t=>"nor",    l=>"nor");
     $d->gate(x=>3, y=>1, w=>1, h=>2, t=>"and",    l=>"and");
     $d->gate(x=>3, y=>3, w=>1, h=>2, t=>"nand",   l=>"nand");
     $d->gate(x=>4, y=>1, w=>1, h=>2, t=>"xor",    l=>"xor");
     $d->gate(x=>4, y=>3, w=>1, h=>2, t=>"nxor",   l=>"nxor");
     $d->gate(x=>1, y=>3, w=>1, h=>1, t=>"one",    l=>"one");
     $d->gate(x=>1, y=>4, w=>1, h=>1, t=>"zero",   l=>"zero");
     $d->svg(file=>"input1", width=>6, height=>6);
 }

#latest:;

ok  1;
&done_testing;
finish: 1
