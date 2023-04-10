package Naro::Command::process;

use strict;
use warnings;
use Naro::CommandUtils::Expand;
use Naro::CommandUtils::Adjoin;
use Naro::CommandUtils::List;

our $VERSION = 'v0.1.0';

sub description {
  "Combines the functionality and options of
  expand, list, and adjoin."
}

sub options {
  (
    CommandUtils::Expand::options(), 
    CommandUtils::Adjoin::options(), 
    CommandUtils::List::options()
  )
}

sub validate {
  my ($self, $args) = @_; 
  Expander::validate($self, $args);
  Adjoin::validate($self, $args);
  List::validate($self, $args);
}

sub execute_inner {
  my ($self, $opt, $syntax, $arg) = @_;
  ExpandBase::execute($self, $opt, $syntax);
  AdjoinBase::execute($self, $opt, $arg);
  List::execute($self, $opt, $syntax);
}
