#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
foo($a, $b);
EOT
---
statements:
  -
    body:
      arguments:
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
      sub:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_glob
        type: Global
      type: SubCall
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
foo();
EOT
---
statements:
  -
    body:
      arguments: []
      sub:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_glob
        type: Global
      type: SubCall
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
$foo->($a, $b);
EOT
---
statements:
  -
    body:
      arguments:
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
      sub:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_scalar
        type: Global
      type: SubCall
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
$foo->();
EOT
---
statements:
  -
    body:
      arguments: []
      sub:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_scalar
        type: Global
      type: SubCall
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
&$foo($a, $b);
EOT
---
statements:
  -
    body:
      arguments:
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
      sub:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_scalar
        type: Global
      type: SubCall
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
$foo->bar($a, $b);
EOT
---
statements:
  -
    body:
      arguments:
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
      invocant:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_scalar
        type: Global
      method:
        type: StringConstant
        value: bar
      type: MethodCall
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
$foo->X::bar;
EOT
---
statements:
  -
    body:
      arguments: []
      invocant:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_scalar
        type: Global
      method:
        type: StringConstant
        value: X::bar
      type: MethodCall
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
$foo->$bar;
EOT
---
statements:
  -
    body:
      arguments: []
      invocant:
        context: ast_context_scalar
        name: foo
        sigil: ast_sigil_scalar
        type: Global
      method:
        context: ast_context_scalar
        name: bar
        sigil: ast_sigil_scalar
        type: Global
      type: MethodCall
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

done_testing();
