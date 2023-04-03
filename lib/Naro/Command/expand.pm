package Naro::Command::expand;

use strict;
use warnings;
use Naro -command;
use Naro::SyntaxExpander;

our $VERSION = 'v0.1.0';

sub execute {
  my ($self, $opt, $args) = @_;

  my $expander = new SyntaxExpander($args[1][1]);

  #TODO: add options for each function below 
  #TODO: allow user to get syntax from file
  $expander->Equals();
  $expander->SQuotes();
  $expander->DQuotes();
  $expander->ParensRule();
  #TODO: add appropraite arguments to the below functions
  #$expander->OptionalToken();
  #$expander->LineComment();
  #$expander->MultilineComment();
  #$expander->MacroRule();

  print $args[1][1];
}
