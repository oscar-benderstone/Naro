package Naro::Command::process;

use strict;
use warnings;
use Naro -command;

our $VERSION = 'v0.4.0';

sub abstract {
  "combination of expand, list, and adjoin"
}

sub description {
  "combines the functionality and options of expand, adjoin, list"
}

sub options {
  (
    Naro::CommandUtils::Expand::options(), 
    Naro::CommandUtils::Adjoin::options(), 
    Naro::CommandUtils::List::options()
  )
}

sub validate {
  my ($self, $opt, $args) = @_; 
  Naro::CommandUtils::Expander::validate($self, $opt, $args);
  Naro::CommandUtils::Adjoin::validate($self, $opt, $args);
  Naro::CommandUtils::List::validate($self, $opt, $args);
}

sub execute_inner {
  my ($self, $opt, $arg) = @_;
  Naro::CommandUtils::ExpandBase::execute($self, $opt, $arg);
  Naro::CommandUtils::AdjoinBase::execute($self, $opt, $arg);
  Naro::CommandUtils::List::execute($self, $opt, $arg);
}
