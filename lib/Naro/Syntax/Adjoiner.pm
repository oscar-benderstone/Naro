package Naro::Syntax::Adjoiner;

our $VERSION = 'v0.4.0';


sub new {
  my $class = shift;
  my $self = {
    syntax => shift,
  }
}

#TODO: provide instructions on how to construct a module that includes
#Actions.pm
=over

=item AddActionHash($action)

Input: hash with rules as keys and the names of subroutines as values

Output: changes syntax to have an action at the end of the rule declaration.

Slient error: if the rule name is not found, an error is reported

=back

=cut

sub AddActionHash {
  my (%action_hash) = @_;

  AddAction($_, %action_hash{$_}) foreach (keys %action_hash);
}

=over

=item AddAction($action)

Input: G1 rule name and action

Output: changes syntax to have an action at the end of the rule declaration.

Slient error: if the rule name is not found, an error is reported

=back

=cut
sub AddAction {
  my $self = shift;

  my @match = $self->syntax =~ /[^\'"]*(<)?$_[1](>)?\s*::=([^\n]*)/g;
 
  $match[0] ? $self->{syntax} =~ s/$match[0]/$match[0] action => $_[2]/ : 
    warn "Rule \"$_[1]\" was not found in the syntax. No actions were added.";
}
1;


=over

Input: C<$self> and input/file name with pseudo rules

Output: C<$self> concatenated with the pseduo rules 

=back

=cut
sub AddPseudoRules {
  my $self = shift;

  $self->{syntax} .= $_[1];
}
