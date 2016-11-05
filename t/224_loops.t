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

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a; do { print } while ($a);
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'VariableDeclaration ($a)'
  successors:
    - L3
  type: BasicBlock
-
  label: L2
  predecessors:
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
    - L1
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
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
my $a; while ($a) { print } continue { $a = 1 }
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
    - L4
  sequence:
    - 'Lexical ($a)'
    - While
  successors:
    - L3
    - L5
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
  successors:
    - L4
  type: BasicBlock
-
  label: L4
  predecessors:
    - L3
  sequence:
    - IVConstant
    - 'Lexical ($a)'
    - 'Binop (ast_binop_sassign)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L5
  predecessors:
    - L2
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
for (1, 2, 3) { print } continue { print 1 }
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
    - L4
  sequence:
    - Foreach
  successors:
    - L3
    - L5
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
  successors:
    - L4
  type: BasicBlock
-
  label: L4
  predecessors:
    - L3
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - IVConstant
    - 'SpecialListop (ast_listop_print)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L5
  predecessors:
    - L2
  sequence: []
  successors: []
  type: BasicBlock
EOT

done_testing();
