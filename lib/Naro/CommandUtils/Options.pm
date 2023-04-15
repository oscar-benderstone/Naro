package Naro::CommandUtils::Options;


#Sets every option (without parameters) to true in case the 'all' flag is set
sub all_options {
  my ($opt, @opts_with_params) = @_;

  if ($opt->{all}) {
    foreach my $opt_info (@opts_with_params) {
      my $opt_name = ($opt_info->[0] =~ /([^\|=]*)/g)[0];
      if ($opt_info->[2]) {
        $opt->{$opt_name} = 1 unless ($opt_info->[2] > 0);
      } else {
        $opt->{$opt_name} = 1;
      }
    } 
  }

  return $opt;
}

1;
