package Naro::Command;

use strict;
use warnings;
use App::Cmd::Setup -command;

sub opt_spec {
  my ($class, $app) = @_;
  return (
    [ 'help' => 'display a command\'s usage screen' ],
    [ 'verbose' => 'display more information during execution'],
    [ 'inline' => 'input the syntax directly in the command. Default: set to false; requires
      providing a path to the syntax file (given as an absolute path or relative to the current directory)'],
    [ 'all' => 'applies all of the available options'],
    $class->options($app),
  )
}
 
sub validate_args {
  my ($self, $opt, $args) = @_;
  if ($opt->{help}) {
    my ($command) = $self->command_names;
    $self->app->execute_command(
      $self->app->prepare_command("help", $command)
    );
    exit;
  }
  $self->validate($opt, $args);
}

#Gets text (either a syntax, actions list, or pseudo rule list) by checking the inline flag
sub get_text {
  my ($self, $opt, $args) = @_; 

  my $syntax;

  try {
    if ($opt->{inline}) {
      $syntax = $args->[0];
    } else {
      open my $TEXT, '<', $args->[0];
      while(<$TEXT>) {
        $syntax .= $_;
      }
      close $TEXT;
    }
  } catch {
    warn "$_";
  }
  
  return $syntax;
}


sub execute {
  my ($self, $opt, $args) = @_; 

  my $syntax = get_syntax($args->[0]);

  $self->execute_inner($self, $opt, $syntax, $args->[1]);
}

1;
