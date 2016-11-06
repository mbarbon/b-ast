#!/usr/bin/env perl

use t::lib::Test;

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
{
    my $b;
}
EOT
---
-
  label: L1
  predecessors: []
  sequence:
    - 'VariableDeclaration ($b)'
  successors:
    - L2
  type: BasicBlock
-
  label: L2
  predecessors:
    - L1
  sequence: []
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a;
{
    my $b;
}
my $c;
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
  sequence:
    - 'VariableDeclaration ($b)'
  successors:
    - L3
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'VariableDeclaration ($c)'
  successors: []
  type: BasicBlock
EOT

bb_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a;
{
    my $b;
} continue {
    my $d;
}
my $c;
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
  sequence:
    - 'VariableDeclaration ($b)'
  successors:
    - L3
  type: BasicBlock
-
  label: L3
  predecessors:
    - L2
  sequence:
    - 'VariableDeclaration ($d)'
  successors:
    - L4
  type: BasicBlock
-
  label: L4
  predecessors:
    - L3
  sequence:
    - 'VariableDeclaration ($c)'
  successors: []
  type: BasicBlock
EOT

done_testing();
