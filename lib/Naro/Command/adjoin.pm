package Naro::Command::adjoin;

use strict;
use warnings;

our $VERSION = 'v0.1.0';

sub description {
  "Adjoin actions to each corresponding rule in the given syntax."
}

sub options {
  AdjoinBase::options();
}

sub validate {
  my ($opt, $args) = @_; 
  AdjoinBase::validate($opt, $args);
}

sub execute {
  my ($self, $opt, $args) = @_;
  AdjoinBase::execute($self, $opt, $args);
}
