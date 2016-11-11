#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
map $_ + 1, (1, 2)
EOT
---
statements:
  -
    body:
      body:
        context: ast_context_scalar
        is_assignment: 0
        left:
          context: ast_context_scalar
          name: _
          sigil: ast_sigil_scalar
          type: Global
        op: ast_binop_add
        right:
          type: IVConstant
          value: 1
        type: Binop
      parameters:
        items:
          -
            type: IVConstant
            value: 1
          -
            type: IVConstant
            value: 2
        type: List
      type: Map
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
map {
    my @i;
} (1, 2)
EOT
---
statements:
  -
    body:
      body:
        body:
          context: ast_context_list
          index: 1
          name: i
          sigil: ast_sigil_array
          type: VariableDeclaration
        type: Block
      parameters:
        items:
          -
            type: IVConstant
            value: 1
          -
            type: IVConstant
            value: 2
        type: List
      type: Map
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

done_testing();
