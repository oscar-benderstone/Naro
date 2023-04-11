package Naro::CommandUtils::Adjoin;

use Naro::Syntax::Adjoiner;

our $VERSION = 'v0.2.0';

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

  


 
  
    
}


