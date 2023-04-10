package Naro::Command::expand;

use strict;
use warnings;
use Naro -command;
use Naro::SyntaxExpander;

our $VERSION = 'v0.1.0';

sub options {
  ExpandBase::options();
}

sub validate {
  my ($self, $args) = @_; 
}

sub execute {
  my ($self, $opt, $args) = @_;
  ExpandBase::execute($self, $opt, $args);
}
