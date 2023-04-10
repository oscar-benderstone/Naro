package Naro::CommandUtils::List;

use strict;
use warnings;
use Naro::Syntax::RuleLister;

sub options {
  (
    ["inline", "Insert rule and action pairs directly. Default: set to false;
      requires using a file storing these pairs as the second parameter."],
  )
}

sub validate {
  my ($self, $opt, $args) = @_;
  $self->usage_error("needs exactly one argument") unless (scalar(@$args) == 1);
}

sub execute {
  my ($self, $opt, $args) = @_;

  try {
    my $lister = new RuleLister($args[0]);


    RuleLister::GetRuleList() if $opt->{verbose};
  } catch {
    warn $_;
  }



}


