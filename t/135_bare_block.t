#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
my $i;
{
    my $j;
}
EOT
---
statements:
  -
    body:
      context: ast_context_void
      index: 1
      name: i
      sigil: ast_sigil_scalar
      type: VariableDeclaration
    file: TEST
    line: 1
    type: Statement
  -
    body:
      body:
        statements:
          -
            body:
              context: ast_context_caller
              index: 2
              name: j
              sigil: ast_sigil_scalar
              type: VariableDeclaration
            file: TEST
            line: 3
            type: Statement
        type: StatementSequence
      continuation:
        type: Empty
      type: BareBlock
    file: TEST
    line: 3
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
{
    my $j;
} continue {
    my $k;
}
EOT
---
statements:
  -
    body:
      body:
        context: ast_context_caller
        index: 1
        name: j
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      continuation:
        context: ast_context_caller
        index: 2
        name: k
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      type: BareBlock
    file: TEST
    line: 3
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
{
    ;
} continue {
    my $k;
}
EOT
---
statements:
  -
    body:
      body:
        type: Empty
      continuation:
        context: ast_context_caller
        index: 1
        name: k
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      type: BareBlock
    file: TEST
    line: 3
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
{
    ;
}
EOT
---
statements:
  -
    body:
      type: Empty
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

done_testing();
