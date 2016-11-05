#!/usr/bin/env perl

use t::lib::Test;

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
print 2, $a;
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'Baseop (ast_baseop_pushmark)'
    - IVConstant
    - 'Global ($a)'
    - 'SpecialListop (ast_listop_print)'
  successors: []
  type: BasicBlock
EOT

done_testing();
