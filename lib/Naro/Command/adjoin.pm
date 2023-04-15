package Naro::Command::adjoin;

use strict;
use warnings;
use Naro -command;

our $VERSION = 'v0.4.0';

sub abstract {
  "add actions and other items to syntax"
}

sub description {
  "add actions to each corresponding rule in the given syntax"
}

sub options {
  Naro::CommandUtils::AdjoinBase::options()
}

sub validate {
  my ($opt, $args) = @_; 
  Naro::CommandUtils::Adjoin::validate($opt, $args);
}

sub execute {
  my ($self, $opt, $args) = @_;
  Naro::CommandUtils::Adjoin::execute($self, $opt, $args);
}
