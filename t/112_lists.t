#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
();
EOT
---
statements:
  -
    body:
      context: ast_context_caller
      op: ast_baseop_empty
      type: Baseop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
();
1;
EOT
---
statements:
  -
    body:
      context: ast_context_void
      op: ast_baseop_empty
      type: Baseop
    file: TEST
    line: 1
    type: Statement
  -
    body:
      type: IVConstant
      value: 1
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
(1, (), (2, 3))
EOT
---
statements:
  -
    body:
      context: ast_context_caller
      op: ast_listop_list2scalar
      terms:
        -
          type: IVConstant
          value: 1
        -
          context: ast_context_caller
          op: ast_listop_list2scalar
          terms:
            -
              type: IVConstant
              value: 2
            -
              type: IVConstant
              value: 3
          type: Listop
      type: Listop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a = ();
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      is_assignment: 0
      left:
        context: ast_context_scalar
        index: 1
        name: a
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      op: ast_binop_sassign
      right:
        type: UndefConstant
      type: Binop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a = ((), ());
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      is_assignment: 0
      left:
        context: ast_context_scalar
        index: 1
        name: a
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      op: ast_binop_sassign
      right:
        type: UndefConstant
      type: Binop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

done_testing();
