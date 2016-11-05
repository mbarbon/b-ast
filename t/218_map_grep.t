#!/usr/bin/env perl

use t::lib::Test;

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
grep { $_ & 1 } qw(1 2 3);
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - StringConstant
    - StringConstant
    - StringConstant
    - Grep
  successors:
    - L2
    - L3
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L2
  sequence:
    - 'Global ($_)'
    - IVConstant
    - 'Binop (ast_binop_bitwise_and)'
    - BackEdge
  successors:
    - L3
    - L2
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
    - L1
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
grep { $_ && 1 } qw(1 2 3);
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - StringConstant
    - StringConstant
    - StringConstant
    - Grep
  successors:
    - L2
    - L5
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
    - L4
  sequence:
    - 'Global ($_)'
    - 'Binop (ast_logop_bool_and)'
  successors:
    - L3
    - L4
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - IVConstant
  successors:
    - L4
  type: BasicBlock
-
  label: L4
  predecessors:
    - L3
    - L2
  sequence:
    - BackEdge
  successors:
    - L5
    - L2
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

done_testing();
