#!/usr/bin/env perl

use t::lib::Test;

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
{
    last;
    next;
    redo;
} continue {
    print
}
EOT
---
-
  label: L1
  predecessors:
    - L3
  sequence:
    - 'LoopControlStatement (ast_lctl_last): '
  successors:
    - L5
  type: BasicBlock
-
  label: L2
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_next): '
  successors:
    - L4
  type: BasicBlock
-
  label: L3
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_redo): '
  successors:
    - L1
  type: BasicBlock
-
  label: L4
  predecessors:
    - L2
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
  successors:
    - L5
  type: BasicBlock
-
  label: L5
  predecessors:
    - L4
    - L1
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
while ($a) {
    last;
    next;
    redo;
} continue {
    print
}
EOT
---
-
  label: L1
  predecessors: []
  sequence: []
  successors:
    - L2
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L6
  sequence:
    - 'Global ($a)'
    - While
  successors:
    - L3
    - L7
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
    - L5
  sequence:
    - 'LoopControlStatement (ast_lctl_last): '
  successors:
    - L7
  type: BasicBlock
-
  label: L4
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_next): '
  successors:
    - L6
  type: BasicBlock
-
  label: L5
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_redo): '
  successors:
    - L3
  type: BasicBlock
-
  label: L6
  predecessors:
    - L4
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L7
  predecessors:
    - L2
    - L3
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
foreach my $i (1) {
    last;
    next;
    redo;
} continue {
    print;
}
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - IVConstant
  successors:
    - L2
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L6
  sequence:
    - Foreach
  successors:
    - L3
    - L7
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
    - L5
  sequence:
    - 'LoopControlStatement (ast_lctl_last): '
  successors:
    - L7
  type: BasicBlock
-
  label: L4
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_next): '
  successors:
    - L6
  type: BasicBlock
-
  label: L5
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_redo): '
  successors:
    - L3
  type: BasicBlock
-
  label: L6
  predecessors:
    - L4
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - 'Global ($_)'
    - 'SpecialListop (ast_listop_print)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L7
  predecessors:
    - L2
    - L3
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
for (my $i = 0; $i < 10; ++$i) {
    last;
    redo;
    next;
}
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
    - L6
  sequence:
    - 'Lexical ($i)'
    - IVConstant
    - 'Binop (ast_binop_num_lt)'
    - For
  successors:
    - L3
    - L7
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
    - L4
  sequence:
    - 'LoopControlStatement (ast_lctl_last): '
  successors:
    - L7
  type: BasicBlock
-
  label: L4
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_redo): '
  successors:
    - L3
  type: BasicBlock
-
  label: L5
  predecessors: []
  sequence:
    - 'LoopControlStatement (ast_lctl_next): '
  successors:
    - L6
  type: BasicBlock
-
  label: L6
  predecessors:
    - L5
  sequence:
    - 'Lexical ($i)'
    - 'Unop (ast_unop_preinc)'
    - BackEdge
  successors:
    - L2
  type: BasicBlock
-
  label: L7
  predecessors:
    - L2
    - L3
  sequence: []
  successors: []
  type: BasicBlock
EOT

done_testing();
