#!/usr/bin/env perl

use t::lib::Test;

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $c = $a && $b
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Global ($a)'
    - 'Binop (ast_logop_bool_and)'
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

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
$a ||= $b
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
    - 'Binop (ast_binop_sassign)'
  successors:
    - L3
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

done_testing();
