package Naro::SyntaxExpander;

use strict;
use warnings;
use Carp;

our $VERSION = 'v0.1.0';

sub new {
  my $class = shift;
  my $self = {
    syntax => shift
  };

  bless $self, $class;

  return $self;
}

sub syntax {
  my $self = shift;
  $self->{syntax} = shift if (@_);
  $self->{syntax}
}

=over

=item AddRule($rule)

Add any rule that Marpa accepts.

Input: C<$rule>

Output: Appends C<$rule> to C<$self->syntax>

Errors: the function aborts if C<$rule> is already in the syntax.

=back

=cut

sub AddRule {
  my $self = shift;
  my $rule = $_[1];
  if ($self->syntax =~ /$_[1]/) {
    croak "Error: this rule is already in the syntax: $_[1]\n";
  } else {
    $self->syntax .= $_[1];
  } 
}


=over

=item Equals()

Changes any =, := signs that do not appear in quotes or brackets
to ::=.

Warning: make sure not to include any pseudo-rules within the input syntax!
Equals does not give a warning, and Marpa will give you an error! Put any
pseudo rules either in the command line or in the actions file instead.

=back

=cut

sub Equals {
  my $self = shift;
  $self->syntax =~ s/[^\'"]*\s(=|:=)/::=/g;
}


=over

=item SQuotes()

Adds a L0 rule called _squote for single quotes.

=back

=cut
sub SQuotes {
  my $self = shift;
  $self->AddRule("_squote ~ [']");
}

=over

=item DQuotes()

Adds a L0 rule called _dquote for double quotes.
   
=back

=cut
  sub DQuotes {
    my $self = shift;
    $self->AddRule("_dquote ~ \"");
  }


=over

=item OptionalToken($rule)


Inputs: name of G1 rule. This token may include a number
called $multiple. 

Output: adds rules to syntax that appearing exactly 0 or $multiple many times.

Errors: if $multiple is less than 1, the function will automatically set n = 1.

=back

=cut

sub OptionalRules {
  my $self = shift;
  my @opt_matches = $self->syntax =~ /\s_([\w\p{N}]*)\s(?!~|:)/g;
  for my $match (@opt_matches) {
    my $multiple = $match =~ (/[\p{N}]*/g)[0] // 1; 
    $match =~ s!$multiple\_!!;
    $self->AddRule("_$match ::= . " . ("$match " x ($_[1]-1)) . $match);
    $self->AddRule("_$match ::= ");
  }
}

=over

=item LineComment($self)

Creates a single line comment with the macro C<line_comment!($start)>
in C<$self->syntax>, where C<$start> is the desired start of each line comment.
Marpa automatically discards these comments while parsing.
Every syntax can have multiple kinds of single line comments, as long as they start
with a different set of symbols.

Warning: two line_comments that collide will give a warning via AddRule.


=back

=cut



=over

=item C<MultlineComment($self)>

Creates rules for a multiline comment with the macro 
C<multiline_comment!($start_comment, $end_comment, $start_inner, $end_inner)>
in C<$self->syntax>. It has the following parameters:

=over

=item C<$start_comment>

The start of the comment.


=item C<$end_comment>

The end of the comment

=item

=item inner_lhs
  

=back


Marpa automatically discards these comments while parsing.
Every syntax can have multiple kinds of single line comments, as long as they start
with a different set of symbols. For C style comments, use the macro C<multiline_comment!(/*, */, *)>.

Warning: two line_comments that collide will give a warning via AddRule.


=back

=cut

sub LineComment {
  my $self = shift;
  my @single_comment_matches = 
    $self->syntax =~ /:discard\s*~\s*line_comment!\(.*\)/g;
    for my $i (0 .. $#single_comment_matches) {
      my $comment_start = ($single_comment_matches[$i] =~ /\((.*)\)/g)[0];
      $_[0] =~ s/:discard\s*~\s*line_comment!\(.*\)/:discard ~ <line_comment_$i>/;
      $self->AddRule("\n<line_comment_$i> ~ \'$comment_start\' <non_new_line_$i>\n");
      $self->AddRule("<non_new_line_$i> ~ [\\n]*\n");
    }
}

sub MultilineComment {
  my $self = shift;
  my @multiline_comment_matches = $self->syntax =~ /:discard\s*~\s*multiline_comment!\(.*\)/g;
  for my $i (0 .. $#multiline_comment_matches) {
      print "My match: : $multiline_comment_matches[$i]\n";
      my @macro_params = quotewords(",",0,($_[0] =~ /\((.*)\)/g)[0]);
      s/\s+// foreach @macro_params;
      my $comment_lhs = $macro_params[0];
      my $comment_rhs = $macro_params[1];
      my $inner_rhs = $macro_params[2];    
      my $inner_lhs = $macro_params[3] || $inner_rhs;
      print "Comment start at $i: $comment_lhs\n";
        $self->syntax =~ s/:discard\s*~\s*multiline_comment!\(.*\)/:discard ~ <multiline_comment_$i>\n/;
      Rule($self->syntax, "<multiline_comment_$i> ~ \'$comment_lhs\' <multiline_comment_char_$i> \'$comment_rhs\'
<multiline_comment_char_$i> ~ <non_inner_lhs> <inner_prefixed> <final_inner_rhs>
<non_inner_lhs> ~ [^$inner_lhs]*
<inner_prefixed> ~ <inner_prefixed_char>*
<inner_prefixed_char> ~ <inner_lhs> [^$comment_lhs] [^$inner_rhs]
<inner_lhs> ~ [$inner_lhs]+
<final_inner_rhs> ~ [$inner_rhs]*\n");
    }
}


sub ParensRule {
  my $self = shift;
  my @matches = $self->syntax =~ /(\w*)\(([^)]*)\)/g;
  foreach (my $i = 0; $i < scalar(@matches)-1; $i++) {
    my @lhs = $self->syntax =~ /(\w*)\s*::=.*$matches[$i+1]/g;
    my $new_rule = $matches[$i] // "<_$lhs[0]_parens_$i>";
  }
}

sub MacroRule {
  my $self = shift;
  my $macro_rule = $_[1];
  my $macro_sub = $_[2];

  $self->syntax =~ s/$macro_rule\!?/$macro_sub/g;
}


1;
