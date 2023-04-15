package Naro::CommandUtils::Expand;

use Try::Tiny;
use Naro::Syntax::Expander;
use Naro::CommandUtils::Validate;
use Naro::CommandUtils::Options;
use Data::Dump;
use File::Spec;

our $VERSION = 'v0.4.0';

my @opts_with_params = (
    [ 'equals|e', 'change =/:= used in rule declarations to ::='], 
    [ 'sub|S=s@', 'substitute a rule name (first argument) for a different rule name (second argument)', 2, 2],
    [ 'squotes|s', 'adds a new rule for single quotes if "_squote" is found'],
    [ 'dquotes|d', 'adds a new rule for double quotes " if "_dquote" is found'],
    [ 'quotes|q', 'enables both squotes and dquotes'],
    [ 'group|g', 'replaces any grouping (rules in parantheses) with a new rule'],
    [ 'opts|O', 'declares any instance of *? as an optional rule called _opt_*'],
    [ 'repetition|r', 'expands any rules of the form n*_'],
    [ 'lcommment|L', 'create single line comments if either "line_comment!" is found'],
    [ 'mcomment|M', 'creates multiline comments if "multiline_comment!" is found'],
    #['dcomment', 'TODO'],
    [ 'comment|C', 'enables both lcomment and mcomment'],
    [ 'macro|m=s', 'expands any macros from the command line or file'],
    [ 'output|o=s', 'writes the new syntax to the given output file', 1, 1]
);

sub options {

  my @options;

  for (my $i = 0; $i < scalar(@opts_with_params); $i++) {
    $options[$i] = [$opts_with_params[$i][0], $opts_with_params[$i][1]];
  }

  return (@options);
  
 }

sub validate {
  my ($self, $opt, $args) = @_;

  $self->usage_error("command needs at least one argument") unless ($args);
  $self->usage_error("command needs at least one option. If you have an option, check if it needs any arguments.") 
    unless (keys %$opt);

  Naro::CommandUtils::Validate::validate($self, $opt, $_[0] =~ (/([^\|]*)/g)[0], $_[2], $_[3]) 
    foreach @opts_with_params;

}

sub execute {
  my ($opt, $args) = @_;

  my $input_without_extension = File::Spec->splitpath($args->[0]);

  my $file_name = "$input_without_extension.marpa";

  $opt = Naro::CommandUtils::Options::all_options($opt, @opts_with_params);

  if ($opt->{output}) {
    $file_name = $opt->{output};
  } elsif ($opt->{inline}) {
    $file_name = "syntax.marpa";
  }

  $opt->{output} ? $file_name = $opt->{output} : $file_name = "syntax.marpa";

  try {

    my $expander = new Naro::Syntax::Expander($args->[0], $opt->{verbose});

    $expander->Equals() if $opt->{equals};
    $expander->ChangeRule($opt->{sub}->[0], $opt->{sub}->[1]) if $opt->{sub};

    
    if ($opt->{quotes}) {
      $opt->{squotes} = 1;
      $opt->{dquotes} = 1;
    }

    $expander->SQuotes() if $opt->{squotes};
    $expander->DQuotes() if $opt->{dquotes};


    $expander->GroupingRule() if $opt->{group};
    $expander->OptionalRule() if $opt->{opts};
    $expander->Repetition() if $opt->{repetition};

    if ($opt->{comment}) {
      $expander->LineComment();
      $expander->MultilineComment();
    }

    $expander->MacroRule() if $opt->{macro};   

    open my $SYNTAX, '>', $file_name or croak $!;

    close $SYNTAX;

     
    print "Ouput: \n", $expander->syntax, "\n" if $opt->{verbose};
  } catch {
    warn "Error: $_";
  }

}
1;
