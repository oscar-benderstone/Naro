package Naro::Command;

use strict;
use warnings;
use App::Cmd::Setup -command;


our $VERSION = 'v0.3.0';

sub opt_spec {
  my ($class, $app) = @_;
  return (
    [ 'help|h' => 'display a command\'s usage screen' ],
    [ 'verbose|v' => 'display more information during execution'],
    [ 'debug|d' => 'prints out each step of functions during execution. Automatically enables verbose.'],
    [ 'inline|i' => 'input the syntax directly in the command. Default: set to false; requires
      providing a path to the syntax file (given as an absolute path or relative to the current directory)'],
    [ 'all|a' => 'applies all of the available options that don\'t have arguments'],
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

#Gets text (either a syntax, actions list, or text file of pseudo rules) by checking the inline flag
#If the inline flag is true, the text given in Naro is directly used; otherwise, Naro attempts
#to open a file
sub get_text {
  my ($self, $opt, $source) = @_;

  my $text;

  try {
    if ($opt->{inline}) {
      $text = $source;
    } else {
      open my $TEXT, '<', $source;
      while(<$TEXT>) {
        $text .= $_;
      }
      print "My Text: $text";
      close $TEXT;
    }
  } catch {
    warn $_;
  }
  
  return $text;
}

sub execute {
  my ($self, $opt, $args) = @_; 

  $args->[0] = get_text($self, $opt, $args->[0]);
  $args->[1] = get_text($self, $opt, $args->[1]) if $args->[1];

  $self->execute_inner($self, $opt, $args);
}

1;
