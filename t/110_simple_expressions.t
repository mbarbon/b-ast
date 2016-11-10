#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
++$a;
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_unop_preinc
      term:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      type: Unop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
$a + 1;
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      is_assignment: 0
      left:
        context: ast_context_scalar
        name: a
        sigil: ast_sigil_scalar
        type: Global
      op: ast_binop_add
      right:
        type: IVConstant
        value: 1
      type: Binop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
print $a, $b
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_print
      terms:
        -
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
        -
          context: ast_context_scalar
          name: b
          sigil: ast_sigil_scalar
          type: Global
      type: Listop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
my $a;
my (@b, %c);
EOT
---
statements:
  -
    body:
      context: ast_context_void
      index: 1
      name: a
      sigil: ast_sigil_scalar
      type: VariableDeclaration
    file: TEST
    line: 1
    type: Statement
  -
    body:
      context: ast_context_caller
      op: ast_listop_list2scalar
      terms:
        -
          context: ast_context_caller
          index: 2
          name: b
          sigil: ast_sigil_array
          type: VariableDeclaration
        -
          context: ast_context_caller
          index: 3
          name: c
          sigil: ast_sigil_hash
          type: VariableDeclaration
      type: Listop
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
no warnings;
$a;
@b;
%c;
*d;
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      name: a
      sigil: ast_sigil_scalar
      type: Global
    file: TEST
    line: 3
    type: Statement
  -
    body:
      context: ast_context_void
      name: b
      sigil: ast_sigil_array
      type: Global
    file: TEST
    line: 4
    type: Statement
  -
    body:
      context: ast_context_void
      name: c
      sigil: ast_sigil_hash
      type: Global
    file: TEST
    line: 5
    type: Statement
  -
    body:
      context: ast_context_scalar
      name: d
      sigil: ast_sigil_glob
      type: Global
    file: TEST
    line: 6
    type: Statement
type: StatementSequence
EOT

done_testing();
