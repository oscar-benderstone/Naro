package Naro::Command::list;

use strict;
use warnings;
use Naro -command;


our $VERSION = 'v0.3.0';

sub abstract {
  "creates hash of lhs rule declarations and rhs rules"
}

sub description {
  "Creates a hash of rules as keys and arrays the corresponding G1 rules on the right hand side as values."
}

sub options {
  Naro::CommandUtils::List::options();
}

sub validate {
  my ($opt, $args) = @_; 
  Naro::CommandUtils::List::validate($opt, $args);
}

sub execute_inner {
  my ($self, $opt, $args) = @_;
  Naro::CommandUtils::List::execute($self, $opt, $args);
}
