#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort @b
EOT
---
statements:
  -
    body:
      context: ast_context_caller
      is_assignment: 0
      left:
        items:
          -
            context: ast_context_list
            name: a
            sigil: ast_sigil_array
            type: Global
        type: List
      op: ast_binop_aassign
      right:
        items:
          -
            arguments:
              -
                context: ast_context_list
                name: b
                sigil: ast_sigil_array
                type: Global
            cmp_function: ~
            is_guaranteed_stable_sort: ''
            is_in_place_sort: ''
            is_reverse_sort: ''
            is_std_integer_sort: ''
            is_std_numeric_sort: ''
            sort_algorithm: ast_sort_merge
            type: Sort
        type: List
      type: Binop
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = reverse sort @b
EOT
---
statements:
  -
    body:
      context: ast_context_caller
      is_assignment: 0
      left:
        items:
          -
            context: ast_context_list
            name: a
            sigil: ast_sigil_array
            type: Global
        type: List
      op: ast_binop_aassign
      right:
        items:
          -
            arguments:
              -
                context: ast_context_list
                name: b
                sigil: ast_sigil_array
                type: Global
            cmp_function: ~
            is_guaranteed_stable_sort: ''
            is_in_place_sort: ''
            is_reverse_sort: '1'
            is_std_integer_sort: ''
            is_std_numeric_sort: ''
            sort_algorithm: ast_sort_merge
            type: Sort
        type: List
      type: Binop
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
sort { $a cmp $b } @b
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: b
          sigil: ast_sigil_array
          type: Global
      cmp_function: ~
      is_guaranteed_stable_sort: ''
      is_in_place_sort: ''
      is_reverse_sort: ''
      is_std_integer_sort: ''
      is_std_numeric_sort: ''
      sort_algorithm: ast_sort_merge
      type: Sort
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
sort { $b cmp $a } @b
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: b
          sigil: ast_sigil_array
          type: Global
      cmp_function: ~
      is_guaranteed_stable_sort: ''
      is_in_place_sort: ''
      is_reverse_sort: '1'
      is_std_integer_sort: ''
      is_std_numeric_sort: ''
      sort_algorithm: ast_sort_merge
      type: Sort
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
sort { $a <=> $b } @b
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: b
          sigil: ast_sigil_array
          type: Global
      cmp_function: ~
      is_guaranteed_stable_sort: ''
      is_in_place_sort: ''
      is_reverse_sort: ''
      is_std_integer_sort: ''
      is_std_numeric_sort: '1'
      sort_algorithm: ast_sort_merge
      type: Sort
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
sort { $a } @b
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: b
          sigil: ast_sigil_array
          type: Global
      cmp_function:
        body:
          context: ast_context_scalar
          name: a
          sigil: ast_sigil_scalar
          type: Global
        type: Block
      is_guaranteed_stable_sort: ''
      is_in_place_sort: ''
      is_reverse_sort: ''
      is_std_integer_sort: ''
      is_std_numeric_sort: ''
      sort_algorithm: ast_sort_merge
      type: Sort
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
sort foo @b
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: b
          sigil: ast_sigil_array
          type: Global
      cmp_function:
        type: StringConstant
        value: foo
      is_guaranteed_stable_sort: ''
      is_in_place_sort: ''
      is_reverse_sort: ''
      is_std_integer_sort: ''
      is_std_numeric_sort: ''
      sort_algorithm: ast_sort_merge
      type: Sort
    file: TEST
    line: 2
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort @a;
1; # to make the sort in void context
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: a
          sigil: ast_sigil_array
          type: Global
      cmp_function: ~
      is_guaranteed_stable_sort: ''
      is_in_place_sort: '1'
      is_reverse_sort: ''
      is_std_integer_sort: ''
      is_std_numeric_sort: ''
      sort_algorithm: ast_sort_merge
      type: Sort
    file: TEST
    line: 2
    type: Statement
  -
    body:
      type: IVConstant
      value: 1
    file: TEST
    line: 3
    type: Statement
type: StatementSequence
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
use sort '_quicksort';
@a = sort @a;
1; # to make the sort in void context
EOT
---
statements:
  -
    body:
      arguments:
        -
          context: ast_context_list
          name: a
          sigil: ast_sigil_array
          type: Global
      cmp_function: ~
      is_guaranteed_stable_sort: ''
      is_in_place_sort: '1'
      is_reverse_sort: ''
      is_std_integer_sort: ''
      is_std_numeric_sort: ''
      sort_algorithm: ast_sort_quick
      type: Sort
    file: TEST
    line: 3
    type: Statement
  -
    body:
      type: IVConstant
      value: 1
    file: TEST
    line: 4
    type: Statement
type: StatementSequence
EOT

done_testing();
