package Naro::Actions;

use strict;
use warnings;
use Carp;
use List::MoreUtils qw(uniq);
use Text::ParseWords;

our $VERSION = 'v0.2.0';

# TODO: write documentation on error messages and subs

sub new {
  my ($class, $args) = shift;
  my $self = {
    #Hash of array descriptors and their indices
    descriptors => quotewords(",", 0, $args->{syntax}),
    #Array of rules
    rules => $args->{rules}
  };
  bless $self, $class;
  return $self;
}

sub descriptors {
  my $self = shift;
  $self->{descriptors} = shift if (@_);
  $self->{descriptors}
}

=over

=item C<RelativeG1Position(@rhs_list, $starting_rule, $index)>

Calculates the absolute index of a G1 rule relative to a specific index.

Inputs: 

=over

=item C<@rhs_list>

List of G1 rules appearing on the right hand side of another G1 rule.

=item C<$starting_rule>

The rule to calculate the relative position.

=item C<$relative_index>

The desired index from the C<$starting_rule>.

=back

=back

Output: the absolute (or actual) index of C<$starting_rule> in C<@rhs_list>.

Example: let's say you have the rule 

C<expression ::= identifier string int>. 

Then 
C<@rhs_list = ["identifier", "string", "int"]>. From C<$starting_string = "string">, 
you can get to C<int> by setting C<$relative_index = 1>. The final output is then 2,
which is exactly where C<int> appears in C<@rhs_list>.
=cut

sub AbsoluteG1Index {
  my (@rhs_list, $starting_rule, $relative_index) = @_; 

  my $absolute_index = $starting_rule - $relative_index;
  if (0 < $absolute_index < scalar(@rhs_list)+2) {
    return $absolute_index; 
  } else {
    croak "The desired target index $relative_index from $starting_rule is out of bounds.";
  }
} 

=over

=item Ignore()

Ignores the current data at a given G1 rule.

=back

=cut
sub Ignore {}

=over

=item Return(@ast, $index)

Inputs:

=over

=item @ast

Gets the value of AST at a given array. Useful for getting a certain array
or piece of data while parsing.

=item $index

The desired index.

=back

Output: the value of the AST at the given index.

=back

=cut
sub Return {
  my (@ast, $index) = @_;

  return $ast[$index];
}

=over

=item Combine(@hash_array)

Combine the contents of hashes in an array into one hash. Useful for
storing parsed data in an AST.

Input: C<@hash_array>

Output: one hash with the key-pairs of each C<$hash> in C<@hash_array>.

=back
=cut

sub Combine {
  my (@hash_array) = @_;
  return {map {%$_} @hash_array};
}
1;
