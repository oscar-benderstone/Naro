package Naro::Command;

use strict;
use warnings;
use Carp;
use App::Cmd::Setup -command;
use Data::Dump;

our $VERSION = 'v0.4.0';

sub opt_spec {
  my ($class, $app) = @_;
  return (
    [ 'help|h' => 'display a command\'s usage screen' ],
    [ 'verbose|v' => 'display more information during execution'],
    [ 'inline|i' => 
      'input the syntax directly in the command. Default: set to false; requires providing a path to the syntax file (given as an absolute path or relative to the current directory)'],
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

  if ($opt->{inline}) {
    $text = $source;
    croak "Error: Empty string used as an argument. Naro only uses non-empty strings." unless ($text);
  } else {
    open my $TEXT, '<', $source or croak "Error with $source: $!";
    while(<$TEXT>) {
      $text .= $_;
    }
    close $TEXT;
    croak "Error: File $source is empty. Naro only works with non-empty files." unless ($text);
  }

  return $text;
}

sub execute {
  my ($self, $opt, $args) = @_; 

  @$args = map get_text($self, $opt, $_), @$args;

  $self->execute_inner($opt, $args);
}

1;
