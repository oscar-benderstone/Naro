package Naro::CommandUtils::Adjoin;

use Naro::Syntax::Adjoiner;

our $VERSION = 'v0.4.0';

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

#TODO: get this execute function to work. Still needs
#to parse the hash from arg
sub execute {
  my ($self, $opt, $args) = @_;

  my $adjoiner = new Adjoiner($args->[0]); 

  my $action_hash = "todo!";
  my $pseudo_rules = "todo!";

  $adjoiner->AddActionHash($action_hash); 
  $adjoiner->AddPseudoRules($pseudo_rules);
}


