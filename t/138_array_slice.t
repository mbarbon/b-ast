#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a[2, 3];
EOT
---
statements:
  -
    body:
      context: ast_context_caller
      is_assignment: 0
      left:
        items:
          -
            type: IVConstant
            value: 2
          -
            type: IVConstant
            value: 3
        type: List
      op: ast_binop_array_slice
      right:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_array
        type: Global
      type: Binop
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a[($global, (2, ($x))), (@global)];
EOT
---
statements:
  -
    body:
      context: ast_context_caller
      is_assignment: 0
      left:
        items:
          -
            context: ast_context_scalar
            name: global
            sigil: ast_sigil_scalar
            type: Global
          -
            type: IVConstant
            value: 2
          -
            context: ast_context_scalar
            name: x
            sigil: ast_sigil_scalar
            type: Global
          -
            context: ast_context_list
            name: global
            sigil: ast_sigil_array
            type: Global
        type: List
      op: ast_binop_array_slice
      right:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_array
        type: Global
      type: Binop
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

done_testing();
