package Naro::Command::process;

use strict;
use warnings;
use Naro -command;

our $VERSION = 'v0.3.0';

sub abstract {
  "combination of adjoin, expand, and list"
}

sub description {
  "Combines the functionality and options of
  expand, list, and adjoin."
}

sub options {
  (
    Naro::CommandUtils::Expand::options(), 
    Naro::CommandUtils::Adjoin::options(), 
    Naro::CommandUtils::List::options()
  )
}

sub validate {
  my ($self, $args) = @_; 
  Naro::CommandUtils::Expander::validate($self, $args);
  Naro::CommandUtils::Adjoin::validate($self, $args);
  Naro::CommandUtils::List::validate($self, $args);
}

sub execute_inner {
  my ($self, $opt, $syntax, $arg) = @_;
  Naro::CommandUtils::ExpandBase::execute($self, $opt, $syntax);
  Naro::CommandUtils::AdjoinBase::execute($self, $opt, $arg);
  Naro::CommandUtils::List::execute($self, $opt, $syntax);
}
