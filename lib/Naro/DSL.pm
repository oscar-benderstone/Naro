package Naro::DSL;

use strict;
use warnings;
use Carp;

our $VERSION = 'v0.1.0';

use constant marpa_syntax => << 'SYNTAX';
:default ::= action => ::array
lexeme default = latm => 1

expression ::= rule* 
rule ::= _colon lhs '::=' rhs newLine action => ListRules
  | _colon lhs '~' rhs newLine action => Ignore
_colon ::= ':'
_colon ::=

lhs ::= token
  | '<' token '>'
rhs ::= rhs_token*
rhs_token ::= token _modifier action => CurrentRule
  | '<' token '>'_modifier action => BracketToken
  | '[' char_class ']' _modifier
  | ['] quoted_char ['] 
  | '|' action => Ignore

_modifier ::= modifier
_modifier ::=
modifier ::= '*' | '+'

token ~ [\w\(\)]*
quoted_char ~ [^']*
char_class ~ [^\x5B\x5D]*
newLine ~ [\n]+

:discard ~ whitespace
whitespace ~ [\s]*

:discard ~ <line comment>
<line comment> ~ '#' <comment>
<comment> ~ <comment_char>*
<comment_char> ~ [^\n]
SYNTAX

sub new {
  my ($class, $args) = @_;
  my $self = {
    syntax => $args->{syntax},
    #Hash of descriptors and their locations in the syntax
    descriptors => $args->{descriptors}, 
    #Array of rules and their locations in the syntax
    rule_array => GetRuleList($args->{syntax}),
  };

  bless $self, $class;
  return $self
}

#Internal grammar and recee used to get rule_array
my $marpa_grammar = Marpa::R2::Scanless::G->new({source => \marpa_syntax});
my $marpa_recce = Marpa::R2::Scanless::R->new({
    grammar => $marpa_grammar,
    semantics_package => 'DSL'
});

sub syntax {
  my $self = shift;
  $self->{syntax} = shift if @_;
  $self->{syntax}
}

sub marpa_grammar {
  my $self = shift;
  $self->{marpa_grammar}
}

sub marpa_recee {
  my $self = shift;
  $self->{marpa_recee}  
}

# Internal sub used to get a rule name
sub RuleName {
  my (@ast) = @_;
  return $ast[1];
}

# Internal sub used to get the name of a rule in brackets
sub BracketRuleName {
  my (@ast) = @_;
  return $ast[2];
}

# Internal Ignore sub used only for the DSL
sub Ignore { }

# Lists all of the G1 rules appearing on the right hand side of a G1 rule.
sub ListRules {
  my (@ast) = @_;

  my $rhs_list = $ast[4];
  @{$rhs_list} = grep defined, @{$rhs_list};
  my $rhs_length = scalar(@{$rhs_list}); 

  my $lhs = $ast[2][0];

  #Gets an array of unique tokens appearing in $lhs
  #Token collisons are handled in the loop below
  my @tokens = uniq $lhs;

  my %rhs;

  #Takes list of tokens and checks for reptitions
  #If a token is repeated, the value is an array of all of the indicies
  #where the token occurs
  for (my $i = 0; $i < scalar(@tokens); $i++) {
    my @token_list = grep @{$rhs_list}[$_] =~ /$tokens[$i]/, 0..$#{$rhs_list};

    if (scalar(@token_list) > 1) {
      $rhs{$tokens[$i]} = [ @token_list ]; 
    } else {
      $rhs{$tokens[$i]} = $i;
    }
  }

  return {$lhs => {%rhs}};
}

sub GetRuleList {
  my $self = shift;
  try {
    $self->marpa_recee->read(\$self->syntax);
    return ${$self->marpa_recce->value};
  } catch {
    warn "Error detected: $_";
  }
}


#TODO: provide instructions on how to construct a module that includes
#Actions.pm
=over

=item AddActionHash($action)

Input: hash with rules as keys and the names of subroutines as values

Output: changes syntax to have an action at the end of the rule declaration.

Slient error: if the rule name is not found, an error is reported

=back

=cut

sub AddActionHash {
  my (%action_hash) = @_;

  for my $rule (keys %action_hash) {
    AddAction($rule, %action_hash{$rule});
  }
}

=over

=item AddAction($action)

Input: G1 rule name and action

Output: changes syntax to have an action at the end of the rule declaration.

Slient error: if the rule name is not found, an error is reported

=back

=cut
sub AddAction {
  my $self = shift;

  my @match = $self->syntax =~ /[^\'"]*(<)?$_[1](>)?\s*::=([^\n]*)/g;
 
  if ($match[0]) {
    $self->{syntax} =~ s/$match[0]/$match[0] action => $_[2]/;
  } else {
    warn "Rule \"$_[1]\" was not found in the syntax. No actions were added.";
  }
}



1;
