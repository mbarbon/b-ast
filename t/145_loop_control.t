#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
while (1) { next; last; redo }
EOT
---
body:
  statements:
    -
      body:
        ctl_type: ast_lctl_next
        target_type: While
        type: LoopControlStatement
      file: TEST
      line: 1
      type: Statement
    -
      body:
        ctl_type: ast_lctl_last
        target_type: While
        type: LoopControlStatement
      file: TEST
      line: 1
      type: Statement
    -
      body:
        ctl_type: ast_lctl_redo
        target_type: While
        type: LoopControlStatement
      file: TEST
      line: 1
      type: Statement
  type: StatementSequence
condition:
  type: Empty
continuation:
  type: Empty
type: While
EOT

# checks statements are linked to the correct loop
op_ast_eq_or_diff(<<'EOT', <<'EOT');
while (1) {
    foreach (1) {
        for (my $i;;) {
            last
        }
        redo
    }
    next
}
EOT
---
body:
  statements:
    -
      body:
        body:
          statements:
            -
              body:
                body:
                  statements:
                    -
                      body:
                        ctl_type: ast_lctl_last
                        target_type: For
                        type: LoopControlStatement
                      file: TEST
                      line: 5
                      type: Statement
                  type: StatementSequence
                condition:
                  type: Empty
                init:
                  context: ast_context_void
                  index: 1
                  name: i
                  sigil: ast_sigil_scalar
                  type: VariableDeclaration
                step:
                  type: Empty
                type: For
              file: TEST
              line: 3
              type: Statement
            -
              body:
                ctl_type: ast_lctl_redo
                target_type: Foreach
                type: LoopControlStatement
              file: TEST
              line: 7
              type: Statement
          type: StatementSequence
        continuation:
          type: Empty
        expression:
          items:
            -
              type: IVConstant
              value: 1
          type: List
        iterator:
          context: ast_context_scalar
          name: _
          sigil: ast_sigil_glob
          type: Global
        type: Foreach
      file: TEST
      line: 2
      type: Statement
    -
      body:
        ctl_type: ast_lctl_next
        target_type: While
        type: LoopControlStatement
      file: TEST
      line: 9
      type: Statement
  type: StatementSequence
condition:
  type: Empty
continuation:
  type: Empty
type: While
EOT

# checks labeled statements are linked correclty
op_ast_eq_or_diff(<<'EOT', <<'EOT');
WHILE: while (1) {
    foreach (1) {
        redo WHILE
    }
    next NONLOCAL
}
EOT
---
body:
  statements:
    -
      body:
        body:
          statements:
            -
              body:
                ctl_type: ast_lctl_redo
                label: WHILE
                target_type: While
                type: LoopControlStatement
              file: TEST
              line: 4
              type: Statement
          type: StatementSequence
        continuation:
          type: Empty
        expression:
          items:
            -
              type: IVConstant
              value: 1
          type: List
        iterator:
          context: ast_context_scalar
          name: _
          sigil: ast_sigil_glob
          type: Global
        type: Foreach
      file: TEST
      line: 2
      type: Statement
    -
      body:
        ctl_type: ast_lctl_next
        label: NONLOCAL
        type: LoopControlStatement
      file: TEST
      line: 6
      type: Statement
  type: StatementSequence
condition:
  type: Empty
continuation:
  type: Empty
type: While
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
{ last }
EOT
---
body:
  statements:
    -
      body:
        ctl_type: ast_lctl_last
        target_type: BareBlock
        type: LoopControlStatement
      file: TEST
      line: 1
      type: Statement
  type: StatementSequence
continuation:
  type: Empty
type: BareBlock
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
FOO: { last FOO }
EOT
---
body:
  statements:
    -
      body:
        ctl_type: ast_lctl_last
        label: FOO
        target_type: BareBlock
        type: LoopControlStatement
      file: TEST
      line: 1
      type: Statement
  type: StatementSequence
continuation:
  type: Empty
type: BareBlock
EOT

done_testing();
