#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
print
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_print
      term: ~
      terms:
        -
          context: ast_context_scalar
          name: _
          sigil: ast_sigil_scalar
          type: Global
      type: SpecialListop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
print $a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_print
      term: ~
      terms:
        -
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
      type: SpecialListop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
print FOO
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_print
      term:
        context: ast_context_scalar
        name: FOO
        sigil: ast_sigil_glob
        type: Global
      terms:
        -
          context: ast_context_scalar
          name: _
          sigil: ast_sigil_scalar
          type: Global
      type: SpecialListop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
print FOO $a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_print
      term:
        context: ast_context_scalar
        name: FOO
        sigil: ast_sigil_glob
        type: Global
      terms:
        -
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
      type: SpecialListop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
system $a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_system
      term: ~
      terms:
        -
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
      type: SpecialListop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

# TODO clean up the code that adds the block here
op_ast_eq_or_diff(<<'EOT', <<'EOT');
system {"foo"} $a
EOT
---
statements:
  -
    body:
      context: ast_context_scalar
      op: ast_listop_system
      term:
        body:
          type: StringConstant
          value: foo
        type: Block
      terms:
        -
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
      type: SpecialListop
    file: TEST
    line: 1
    type: Statement
type: StatementSequence
EOT

done_testing();
