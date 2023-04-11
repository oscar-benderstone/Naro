package Naro::Command::adjoin;

use strict;
use warnings;
use Naro::CommandUtils::Adjoin;

our $VERSION = 'v0.2.0';

sub description {
  "Adjoin actions to each corresponding rule in the given syntax."
}

sub options {
  AdjoinBase::options();
}

sub validate {
  my ($opt, $args) = @_; 
  Adjoin::validate($opt, $args);
}

sub execute {
  my ($self, $opt, $args) = @_;
  Adjoin::execute($self, $opt, $args);
}
