package Naro::Command::expand;

use strict;
use warnings;
use Naro -command;
use Naro::CommandUtils::Expand;

our $VERSION = 'v0.4.0';

sub abstract {
  "evaluate any EBNF shorthands or custom macros"
}

sub description {
  "evaluate any EBNF shorthands or custom macros"
}

sub options {
  return Naro::CommandUtils::Expand::options();
}

sub validate {
  my ($self, $opt, $args) = @_; 
  Naro::CommandUtils::Expand::validate($self, $opt, $args);
}

sub execute_inner {
  my ($self, $opt, $args) = @_;

  Naro::CommandUtils::Expand::execute($opt, $args);
}
