package Naro::CommandUtils::Expand;

use Try::Tiny;
use Naro::Syntax::Expander;

our $VERSION = 'v0.3.0';

sub options {
  (
    [ 'equals', 'change =/:= used in rule declarations to ::='], 
    [ 'sub=s', 'substitute a rule name for a different rule name'],
    [ 'quotes', 'adds a new rule for quotes if "_squote" or "_dquote" are found'],
    [ 'parens', 'replaces any rule in parantheses with a new rule'],
    [ 'opts', 'declares any instance of *? as an optional rule called _opt_*'],
    [ 'multiples', 'expands any rules of the form n*_'],
    [ 'comments', 'create comments if either "line_comment!" or "multiline_comment!" are found'],
    [ 'macro', 'expands any macros from an input file'],
    [ 'output=s', 'writes the given output file']
  )
}

sub validate {
  my ($self, $opt, $args) = @_;
  $self->usage_error("needs exactly one argument") unless (scalar(@$args) == 1);
  $self->usage_error("needs at least one option") unless ($opt);
  #$self->usage_error("-sub needs exactly two parameters: an old rule and a new rule name") 
  #unless (not($opt->{'sub'}) | scalar(@{$opt->{'sub'} == 2}));
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $syntax = "expr = 3*ident";

  my $file_name;

  $opt = map 1, $opt unless $opt->{all} == 0;
  $opt->{output} ? $file_name = $opt->{output} : $file_name = "syntax.marpa";
  #$file_name = "syntax.marpa" if $opt->{inline};

  try {
    my $expander = new Naro::Syntax::Expander($syntax, $opt->{verbose});

    $expander->Equals() if $opt->{equals};
    if ($opt->{quotes}) {
      $expander->SQuotes();
      $expander->DQuotes();
    }

    $expander->ParensRule() if $opt->{parens};
    $expander->OptionalToken() if $opt->{opts};
    $expander->Multiple() if $opt->{multiples};

    if ($opt->{comment}) {
      $expander->LineComment() if $opt->{comment};
      $expander->MultilineComment();
    }

    $expander->MacroRule() if $opt->{macro};   

    open my $SYNTAX, '>', $file_name or croak $!;

    print $SYNTAX $expander->syntax;

    close $SYNTAX;
     
    print $expander->syntax, "\n" if $opt->{verbose};
  } catch {
    warn "Error: $_";
  }

}
1;
