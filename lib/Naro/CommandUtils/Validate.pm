package Naro::CommandUtils::Validate;

use strict;
use warnings;
use Carp;

#Prints out usage error for a given option name, least and greatest number of parameters,
sub validate {
  my ($self, $opt, $opt_name, $param_lower_num, $param_upper_num) = @_;

  $param_lower_num = 0 unless ($param_lower_num);
  
  my $message = "needs at least $param_lower_num arguments";

  if ($param_upper_num) {
    if ($param_lower_num == $param_upper_num) {
      $message = "needs exactly $param_lower_num many parameters";
    } elsif ($param_lower_num < $param_upper_num && $param_upper_num) {
      $message = "needs $param_lower_num-$param_upper_num arguments";
    }
  }

  if ($opt->{$opt_name}) {
    if ($param_lower_num < scalar($opt->{$opt_name}) && 
          scalar($opt->{$opt_name}) < $param_upper_num) {
       $self->usage_error("-$opt_name $message");
    }
  }

}

1;
