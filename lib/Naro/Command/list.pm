package Naro::Command::list;

use strict;
use warnings;
use Naro::CommandUtils::List;


our $VERSION = 'v0.2.0';

sub description {
  "Creates a hash of rules as keys and arrays the corresponding G1 rules on the right hand side as values."
}

sub options {
  List::options();
}

sub validate {
  my ($opt, $args) = @_; 
  List::validate($opt, $args);
}

sub execute_inner {
  my ($self, $opt, $syntax) = @_;
  List::execute($self, $opt, get_syntax$args->[0]));
}
