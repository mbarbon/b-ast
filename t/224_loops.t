#!/usr/bin/env perl

use t::lib::Test;

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
for (my $i = 0; $i; ++$i) { print }
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - IVConstant
    - 'VariableDeclaration ($i)'
    - 'Binop (ast_binop_sassign)'
  successors:
    - L2
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L3
  sequence:
    - 'Lexical ($i)'
    - For
  successors:
    - L3
    - L4
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
    - 'Lexical ($i)'
    - 'Unop (ast_unop_preinc)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L4
  predecessors:
    - L2
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a; while ($a) { print }
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'VariableDeclaration ($a)'
  successors:
    - L2
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L3
  sequence:
    - 'Lexical ($a)'
    - While
  successors:
    - L3
    - L4
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L4
  predecessors:
    - L2
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
for (1, 2, 3) { print }
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - IVConstant
    - IVConstant
    - IVConstant
  successors:
    - L2
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L3
  sequence:
    - Foreach
  successors:
    - L3
    - L4
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L4
  predecessors:
    - L2
  sequence: []
  successors: []
  type: BasicBlock
EOT

done_testing();
