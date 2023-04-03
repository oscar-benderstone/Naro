package Naro::Command;

use strict;
use warnings;
use App::Cmd::Setup -command;

sub opt_spec {
  my ( $class, $app ) = @_;
  return (
    [ 'help' => "List of options" ],
    $class->options($app),
  )
}
 
sub validate_args {
  my ( $self, $opt, $args ) = @_;
  if ( $opt->{help} ) {
    my ($command) = $self->command_names;
    $self->app->execute_command(
      $self->app->prepare_command("help", $command)
    );
    exit;
  }
  $self->validate( $opt, $args );
}
