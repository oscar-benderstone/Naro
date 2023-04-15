package Naro::Syntax::Expander;

use strict;
use warnings;
use Carp;

our $VERSION = 'v0.4.0';

sub new {
  my $class = shift;
  my $self = {
    syntax => shift,
    verbose => shift,
  };

  bless $self, $class;

  return $self;
}

#Standard constructors
sub syntax {
  my $self = shift;
  $self->{syntax} = shift if (@_);
  $self->{syntax}
}

sub verbose {
  my $self = shift;
  $self->{verbose}
}


=item CheckRule($rule)

Input: C<$self> and a rule.

Output: throws an exception if the rule is found in C<$self->syntax>
and 1 otherwise.

=back

=cut
sub CheckRule {
  my $self = shift;
  my $rule = $_[0];
  croak "Rule $rule not found in the syntax" unless ($rule);
  $self->syntax !~ /$_[0]/ ? return 0 :
    croak "Rule $_[0] is already in the syntax\n";
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
  my $rule = $_[0];
  $self->CheckRule($rule);
  $self->{syntax} .= $rule;
}

=over

=item ChangeRule($new rule)

Change any instance of C<$new_rule> with C<$old_rule>.

Warnings: this function will throw an exception if 

=back

=cut

sub ChangeRule {
  my $self = shift;
  my $old_rule = $_[0];
  my $new_rule = $_[1];

  $self->{syntax} =~ /$old_rule/ ?
    $self->{syntax} =~ s/$old_rule/$new_rule/g
    : croak "Rule $old_rule not found in syntax";
}

=over

=item Equals()

Changes any =, := signs that do not appear in quotes or brackets
to ::=.

Warning: make sure not to include any pseudo-rules within the input syntax!
Equals does not give a warning, and Marpa will give you an error! Instead, add any
pseudo rules through 'adjoin',
either directly inline or in the actions file.

Todo: this function only works if each rule in the syntax is on a differnet line.

=back

=cut

sub Equals {
  my $self = shift;

  print "Substituting equals..." if $self->verbose;

  #Gets every instance of characters before =/:= and =/:= itself
  #Before any G1 rule declaration, there can be any number of spaces/newlines,
  #the rule name itself (either any mix of \_ or \w) and additional
  #spaces/newlines.
  #The [^\'"] in the regex ensures anything in quotes is NOT changed
  my @matches = $self->{syntax} =~ /[^\'"]([\s\n]*[\_\w]*[\s\n]*)(=|:=)/g;

  for (my $i = 0; $i < 2+scalar(@matches)/2; $i += 2) {
    
    my $match_value = "$matches[$i]$matches[$i+1]";

    $self->{syntax} =~ s/$match_value/$matches[$i]::=/;
  }

}

=over

=item SQuotes()

Adds a L0 rule called _squote for single quotes.

=back

=cut
sub SQuotes {
  my $self = shift;
  print "Adding SQuotes...\n" if $self->verbose;
  $self->AddRule("_squote ~ [']\n");
}

=over

=item DQuotes()

Adds a L0 rule called _dquote for double quotes.
   
=back

=cut
sub DQuotes {
  my $self = shift;
  print "Adding DQuotes...\n" if $self->verbose;
  $self->AddRule("_dquote ~ \"\n");
}

=over

=item Quotes()

Combines SQuotes and DQuotes

=back

=cut
sub Quotes {
  my $self = shift;
  $self->SQuotes();
  $self->DQuotes();
}

=over

=item OptionalRules($rule)


Inputs: name of G1 rule. This token may include a number
called $multiple. 

Output: adds rules to syntax that appearing exactly 0 or $multiple many times.

Errors: if $multiple is less than 1, the function will automatically set n = 1.

=back

=cut

#TODO: finish implementing this function!
sub OptionalRules {
  my $self = shift;

  my @opt_matches = $self->syntax =~ /[^\'"]\s([^\s\n]*)\?\s(?!~|:)/g;

  for my $match (@opt_matches) {
    $self->syntax =~ s/$match/_opt_$match/g; 
    $self->AddRule("_opt_$match");
  }
}

=over

=item LineComment($self)

Creates a single line comment with the macro C<line_comment!($start)>
in C<$self->syntax>, where C<$start> is the desired start of each line comment.
Marpa automatically discards these comments while parsing.
Every syntax can have multiple kinds of single line comments, as long as they start
with a different set of symbols. For C++-style comments, use the macro C<line_comment!(//)>.

Warning: two line_comments that collide will give a warning via AddRule.


=back

=cut

sub LineComment {
  my $self = shift;

  my @line_comment_matches = 
    $self->{syntax} =~ /[^\'"]*\:discard\s*~\s*line_comment!\(.*\)/g;

  croak "The macro \"line_comment!\" was not found in syntax" unless (@line_comment_matches);

  print "Adding line comment..." if $self->verbose;

  for my $i (0 .. $#line_comment_matches) {

    my $comment_start = ($line_comment_matches[$i] =~ /\((.*)\)/g)[0];

    $_[0] =~ s/:discard\s*~\s*line_comment!\(.*\)/:discard ~ <line_comment_$i>/;

    $self->AddRule("\n<line_comment_$i> ~ \'$comment_start\' <non_new_line_$i>\n");
     
    $self->AddRule("<non_new_line_$i> ~ [\\n]*\n");
  }
}

=over

=item C<MultiineComment($self)>

Creates rules for a multiline comment with the macro 
C<multiline_comment!($start_comment, $end_comment)>
in C<$self->syntax>. It has the following parameters:

=over

=item C<$start_comment>

The start of the comment.


=item C<$end_comment>

The end of the comment


=back


Marpa automatically discards these comments while parsing.
Every syntax can have multiple kinds of single line comments, as long as they start
with a different set of symbols. For C-style comments, use the macro C<multiline_comment!(/*, */, *)>.

Warning: two line_comments that collide will give a warning via AddRule.


=back

=cut
sub MultilineComment {
  my $self = shift;

    my @multiline_comment_matches = $self->syntax =~ /[^\'"]*:\discard\s*~\s*multiline_comment!\(.*\)/g;
  
  croak "The macro \"multiline_comment!\" was not found in syntax" unless (@multiline_comment_matches);

  print "Adding multiline comments..." if $self->{verbose};

  for my $i (0 .. $#multiline_comment_matches) {
      #Get parameters from macro
      my @macro_params = quotewords(",",0,($_[0] =~ /\((.*)\)/g)[0]);
     
      #Remove spaces in macro parameters
      s/\s+// foreach @macro_params;
      
      #Get the start, end, and inner parameters  
      my $start_comment = $macro_params[0];
      
      my $end_comment = $macro_params[1];
      
      my $end_inner = chop($macro_params[1]);    

      #Change the discard pseudorule to use the new multilne_comment rule
      $self->syntax =~ s/:discard\s*~\s*multiline_comment!\(.*\)/:discard ~ <multiline_comment_$i>\n/;

      #Add the multiline comment at the end of syntax
      Rule($self->syntax, "<multiline_comment_$i> ~ \'$start_comment\' <multiline_comment_char_$i> \'$end_comment\'
<multiline_comment_char_$i> ~ <non_end_inner> <inner_prefixed> <final_end_inner>
<non_end_inner> ~ [^$end_inner]*
<inner_prefixed> ~ <inner_prefixed_char>*
<inner_prefixed_char> ~ <end_inner> [^$start_comment] [^$end_inner]
<end_inner> ~ [$end_inner]+
<final_end_inner> ~ [$end_inner]*\n");
    }
}

#TODO: add doc comments
sub DocComment {
  my $self = shift;

}

=over

=item C<Repetitions()>
Expands C<n*rule> to C<rule ... rule> n-times, C<rule> is a G1 rule

=back
=cut
sub Repetitions {
  my @matches = $_[0] =~ /([\p{N}])*\*(\w*)/g;
  @matches = grep defined, @matches;

  foreach (my $i = 0; $i < scalar(@matches)-2; $i += 2) {
    my $expansion = (($matches[$i+1]." ") x ($matches[$i]-1)) . $matches[$i+1];
    my @subs = $_[0] =~ /$matches[$i]\*$matches[$i+1]/g;
    $_[0] =~ s/$matches[$i]\*$matches[$i+1]/$expansion/;
  }
}

sub GroupingRule {
  my $self = shift;
  my @matches = $self->{syntax} =~ /[^\'"]*(\w*)\(([^)]*)\)/g;
  foreach (my $i = 0; $i < scalar(@matches)-1; $i++) {
    my @lhs = $self->{syntax} =~ /(\w*)\s*::=.*$matches[$i+1]/g;
    my $new_rule = $matches[$i] // "<_$lhs[0]_parens_$i>";
    $self->{syntax} .= $new_rule;
  }
}

sub MacroRule {
  my $self = shift;
  my $macro_rule = $_[0];
  my $macro_sub = $_[1];

  $self->{syntax} =~ s/$macro_rule\!?/$macro_sub/g;
}
=over

=item AllMacroRules

Input: C<$self> and string containing statements of the form "macro! = _;". A macro
definition may appearing on multiple lines but must end with a semicolon.
A macro may begin anywhere in the string.

Output: expand every macro in C<$self->syntax> with its corresponding definition

Error: if a definition for a macro is not found, 

=back
=cut
sub AllMacroRules {
  my $self = shift;
  my $macro_string = $_[0];
  my @macro_pairs = $macro_string =~ /\s*([^\s\n]*)\s*=\s*([^;]*);/g;
  print "My macro pairs: ", Data::Dump::dump(@macro_pairs), "\n";
  for (my $i = 0; $i < scalar(@macro_pairs); $i++) {
    if (not($macro_pairs[$i] || $macro_pairs[$i+1])) {
      croak 'macro at index ', $i, ' is not defined';
    } else {
      $self->syntax =~ MacroRule($macro_pairs[$i], $macro_pairs[$i+1]);
    }
  }

}

1;
