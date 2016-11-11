#!/usr/bin/env perl

use t::lib::Test;

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = reverse sort @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort { $a cmp $b } @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort { $b cmp $a } @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort { $a <=> $b } @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort { $a->{a} cmp $b->{a} } @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort foo @b
EOT
EOT

op_ast_eq_or_diff(<<'EOT', <<'EOT');
no strict;
@a = sort @a
EOT
EOT

done_testing();
