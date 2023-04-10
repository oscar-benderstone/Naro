package Naro::CommandUtils::Expand;

use Naro::Syntax::Expander;

sub options {
  (
    [ 'equals', 'change =/:= used in rule declarations to ::='], 
    [ 'quotes', 'adds a new rule for quotes if "_squote" or "_dquote" are found'],
    [ 'parens', 'adds a new rule if _parens_* appears'],
    [ 'opts', 'declares any instance of _opt_* as an optional rule'],
    [ 'multiples', 'expands any rules of the form n*_'],
    [ 'comments', 'create comments if either "line_comment!" or "multiline_comment!" are found'],
    [ 'macro', 'expands any macros from an input file'],
  )
}

sub validate {
  my ($self, $opt, $args) = @_;
  $self->usage_error("needs exactly one argument") unless (scalar(@$args) == 1);
  $self->usage_error("needs at least one option") unless ($opt);
}

sub execute {
  my ($self, $opt, $syntax, $pseudo_rules) = @_;

  my $file_name;

  $opt = map 1, $opt unless $opt->{all} == 0;
  $opt->{inline} ? $file_name = "syntax.marpa" : $file_name = $syntax;

  try {
    my $expander = new SyntaxExpander($syntax, $opt->{verbose});

    $expander->Equals() if $opt->{equals};
    if ($opt->{quotes}) {
      $expander->SQuotes();
      $expander->DQuotes();
    }

    $expander->ParensRule() if $opt->{parens};
    $expander->OptionalToken() if $opt->{opts};
    $expander->Multiples() if $opt->{multiples};

    if ($opt->{comment}) {
      $expander->LineComment() if $opt->{comment};
      $expander->MultilineComment();
    }

    $expander->MacroRule() if $opt->{macro};   
    #TODO: save new syntax in a new file

    open my $SYNTAX, '>', $file_name;

    print $SYNTAX $file_name;

    close $SYNTAX;
     
    print $expander->syntax, "\n" if $opt->{verbose};
  } catch {
    warn "Error: $_";
  }

}
1;

