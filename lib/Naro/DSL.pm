package Naro::DSL;

use strict;
use warnings;
use Carp;

our $VERSION = 'v0.1.0';

use constant syntax => << 'SYNTAX';
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

my $grammar = Marpa::R2::Scanless::G->new({source => \syntax});
my $recce = Marpa::R2::Scanless::R->new({
    grammar => $grammar,
    semantics_package => 'DSL'
});

# TODO: work in progress. These subs are mainly used to
# get important data about your syntax.

sub RuleName {
  my (@ast) = @_;
  return $ast[1];
}

sub BracketRuleName {
  my (@ast) = @_;
  return $ast[2];
}

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


# Internal Ignore sub used only for the DSL
sub Ignore { }

1;
