#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
do { my $a }
EOT
---
statements:
  -
    body:
      body:
        context: ast_context_caller
        index: 1
        name: a
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      type: Block
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
do {
    no warnings 'void';
    1;
    2;
    3;
    4;
}
EOT
---
statements:
  -
    body:
      body:
        statements:
          -
            body:
              type: IVConstant
              value: 4
            file: TEST
            line: 6
            type: Statement
        type: StatementSequence
      type: Block
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
do { do { my $a } }
EOT
---
statements:
  -
    body:
      body:
        body:
          context: ast_context_caller
          index: 1
          name: a
          sigil: ast_sigil_scalar
          type: VariableDeclaration
        type: Block
      type: Block
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
do { my $a }
EOT
---
statements:
  -
    body:
      body:
        context: ast_context_caller
        index: 1
        name: a
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      type: Block
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
do { do {} }
EOT
---
statements:
  -
    body:
      type: Empty
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
do { () }
EOT
---
statements:
  -
    body:
      body:
        context: ast_context_caller
        op: ast_baseop_empty
        type: Baseop
      type: Block
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

done_testing();
