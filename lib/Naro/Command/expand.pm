package Naro::Command::expand;

use strict;
use warnings;
use Naro -command;

our $VERSION = 'v0.3.0';

sub abstract {
  "evaluate any EBNF shorthands or custom macros"
}

sub description {
  "evaluate any EBNF shorthands or custom macros"
}

sub options {
  Naro::CommandUtils::Expand::options()
}

sub validate {
  my ($self, $args) = @_; 
}

sub execute_inner {
  my ($self, $opt, $args) = @_;
  Naro::CommandUtils::Expand::execute($self, $opt, $args);
}
