#!/usr/bin/env perl

use t::lib::Test;

v_ast_eq_or_diff(<<'EOT', <<'EOT');
77
EOT
---
type: IVScalar
value: 77
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
my $c = $a + $b
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
        name: c
        sigil: ast_sigil_scalar
        type: VariableDeclaration
      op: ast_binop_sassign
      right:
        context: ast_context_scalar
        is_assignment: 0
        left:
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
        op: ast_binop_add
        right:
          context: ast_context_scalar
          name: b
          sigil: ast_sigil_scalar
          type: Global
        type: Binop
      type: Binop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

v_ast_eq_or_diff(<<'EOT', <<'EOT');
sub {
    my $i = 23;
    sub {
        $i
    }
}->();
EOT
---
type: RVScalar
value:
  ast:
    statements:
      -
        body:
          context: ast_context_caller
          index: 1
          name: i
          sigil: ast_sigil_scalar
          type: Lexical
        file: TEST
        line: 4
        type: Statement
    type: StatementSequence
  closed_over:
    - ~
    -
      type: IVScalar
      value: 23
  type: Subroutine
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $c = $a + $b
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Global ($a)'
    - 'Global ($b)'
    - 'Binop (ast_binop_add)'
    - 'VariableDeclaration ($c)'
    - 'Binop (ast_binop_sassign)'
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $c = $a || $b
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Global ($a)'
    - 'Binop (ast_logop_bool_or)'
  successors:
    - L2
    - L3
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
  sequence:
    - 'Global ($b)'
  successors:
    - L3
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
    - L1
  sequence:
    - 'VariableDeclaration ($c)'
    - 'Binop (ast_binop_sassign)'
  successors: []
  type: BasicBlock
EOT

done_testing();
