package Naro::Command;

use strict;
use warnings;
use App::Cmd::Setup -command;

our $VERSION = 'v0.2.0';

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

#Gets text (either a syntax, actions list, or text file of pseudo rules) by checking the inline flag
#If the inline flag is true, the text given in Naro is directly used; otherwies, Naro attempts
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
      close $TEXT;
    }
  } catch {
    warn "$_";
  }
  
  return $text;
}

sub execute {
  my ($self, $opt, $args) = @_; 

  @$args = map $self->get_text($opt, $_), @$args;

  $self->execute_inner($self, $opt, $args);
}

1;
