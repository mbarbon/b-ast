#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
++$a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_unop_preinc
      term:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      type: Unop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
$a + 1
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      is_assignment: 0
      left:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      op: ast_binop_add
      right:
        type: IVConstant
        value: 1
      type: Binop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
$a * 2
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      is_assignment: 0
      left:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      op: ast_binop_multiply
      right:
        type: IVConstant
        value: 2
      type: Binop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
-$a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_unop_negate
      term:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      type: Unop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
use integer;
-$a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_unop_negate
      term:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      type: Unop
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

done_testing();
