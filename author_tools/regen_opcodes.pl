#!perl
use 5.14.0;
use warnings;

# Define op definition's columns in text format
use constant {
  AST_CONST   => 0,
  AST_CLASS   => 1,
  AST_NAME    => 2,
  PERL_CONST  => 3,
  AST_FLAGS   => 4,
  OPTIONS     => 5,
  RET_TYPE    => 6,
};
my @cols = (AST_CONST, AST_CLASS, AST_NAME, PERL_CONST, AST_FLAGS, OPTIONS, RET_TYPE);

# Valid ops for generating filtering macro
my %valid_root_ops;
my %valid_ops;

# Read op defs from text format
open my $fh, "<", "author_tools/opcodes" or die $!;
my @op_defs;
while (<$fh>) {
  chomp;

  # special smart comment line...
  if (/^\s*#!\s*(\w+)\s*=(.*)$/) {
    my ($name, $value) = ($1, $2);
    if ($name eq 'jittable_ops') {
      $valid_ops{$_} = 1 for split /\s+/, $value;
    }
    elsif ($name eq 'jittable_root_ops') {
      $valid_ops{$_} = $valid_root_ops{$_} = 1 for split /\s+/, $value;
    }
    else {
      die "Invalid smart comment: '$_'";
    }
  }

  s/#.*$//;
  next if !/\S/;

  my @cols = split /\s*,\s*/, $_;
  $cols[AST_FLAGS] = join '|', map {$_ ? "B_ASTf_$_" : $_} split /\|/, $cols[AST_FLAGS];
  push @op_defs, \@cols;
}
close $fh;
#use Data::Dumper; warn Dumper \@op_defs;

# Determine maximum column lengths for readable output
my @max_col_length;
for (@cols) {
  $max_col_length[$_] = max_col_length(\@op_defs, $_);
}

# Write data file for inclusion in b_ast_terms.c
my $data_fh = prep_ops_data_file();

print $data_fh "static const char *b_ast_op_names[] = {\n";
foreach my $op (@op_defs) {
  printf $data_fh "  %-*s // %-*s (%s)\n",
    $max_col_length[AST_NAME]+3, qq{"$op->[AST_NAME]",},
    $max_col_length[AST_CONST], $op->[AST_CONST], $op->[AST_CLASS];
}
print $data_fh "};\n\n";

print $data_fh "static unsigned int b_ast_op_flags[] = {\n";
foreach my $op (@op_defs) {
  printf $data_fh "  %-*s // %-*s (%s)\n",
    $max_col_length[AST_FLAGS]+1, qq{$op->[AST_FLAGS],},
    $max_col_length[AST_CONST], $op->[AST_CONST], $op->[AST_CLASS];
}
print $data_fh "};\n\n#endif\n";
close $data_fh;

# Generate actual op constant enum list for inclusion in b_ast_terms.h
my $enum_fh = prep_ops_enum_file();
print $enum_fh "typedef enum {\n";

my $cur_class;
foreach my $op (@op_defs) {
  if (not defined $cur_class
      or $cur_class ne $op->[AST_CLASS])
  {
    $cur_class = $op->[AST_CLASS];
    print $enum_fh "\n  // Op class: $cur_class\n";
  }

  printf $enum_fh "  %s,\n", $op->[AST_CONST];
}

my $first_and_last = find_first_last_of_class(\@op_defs);
#use Data::Dumper; warn Dumper $first_and_last;
print $enum_fh "\n  // Op class ranges\n";
foreach my $class_data (@$first_and_last) {
  my ($cl, $first, $last) = @$class_data;
  $cl =~ /^ast_opc_(.*)$/ or die;
  my $prefix = "ast_${1}_";
  print $enum_fh "\n";
  print $enum_fh "  ${prefix}FIRST = $first,\n";
  print $enum_fh "  ${prefix}LAST  = $last,\n";
}
print $enum_fh "\n  // Global op range:\n  ast_op_FIRST = " . $op_defs[0][AST_CONST] . ",\n";
print $enum_fh "  ast_op_LAST = " . $op_defs[-1][AST_CONST] . "\n";

print $enum_fh "} ast_op_type;\n\n#endif\n";
close $enum_fh;


# Now generate macro to select the root / non-root OP types to ASTify
my $op_switch_fh = prep_ast_gen_op_switch_file();
print $op_switch_fh "// Macros to determine which Perl OPs to ASTify\n";
foreach my $op (@op_defs) {
  next if has_option($op, "declareonly");
  if (not has_option($op, "nonroot")) {
    $valid_root_ops{ $op->[PERL_CONST] } = 1;
  }
  $valid_ops{ $op->[PERL_CONST] } = 1;
}
print $op_switch_fh "\n#define IS_AST_COMPATIBLE_ROOT_OP_TYPE(otype) ( \\\n     ";
print $op_switch_fh join " \\\n  || ", map "(int)otype == $_", sort keys %valid_root_ops;
print $op_switch_fh ")\n\n";
print $op_switch_fh "\n#define IS_AST_COMPATIBLE_OP_TYPE(otype) ( \\\n     ";
print $op_switch_fh join " \\\n  || ", map "(int)otype == $_", sort keys %valid_ops;
print $op_switch_fh ")\n\n";

print $op_switch_fh "\n\n#endif\n";
close $op_switch_fh;

my $optree_emit_fh = prep_optree_emit_file();
print $optree_emit_fh "// case X: for the things that are simple to emit based on their Op class\n\n";
foreach my $op (@op_defs) {
  if (has_option($op, "emit")) {
    my $optional = has_flag($op, "KIDS_OPTIONAL") ? "_OPTIONAL" : "";

    my $optype = $op->[AST_CLASS] eq 'ast_opc_unop'   ? 'UNOP'
               : $op->[AST_CLASS] eq 'ast_opc_logop'  ? 'LOGOP'
               : $op->[AST_CLASS] eq 'ast_opc_binop'  ? 'BINOP'
               : ($op->[AST_CLASS] eq 'ast_opc_listop' &&
                  has_flag($op, 'OPTIONAL_TERM'))     ? 'SPECIAL_LISTOP'
               : $op->[AST_CLASS] eq 'ast_opc_listop' ? 'LISTOP'
               : $op->[AST_CLASS] eq 'ast_opc_baseop' ? 'BASEOP'
               : die "Unrecognized AST class: '$op->[AST_CONST]'!";

    print $optree_emit_fh "EMIT_${optype}_CODE$optional("
                          . $op->[PERL_CONST]
                          . ", " . $op->[AST_CONST].")\n";
  }
}
print $optree_emit_fh "\n\n#endif\n";
close $optree_emit_fh;

my $xs_const_fh = prep_xs_const_fh();
foreach my $op (@op_defs) {
  printf $xs_const_fh "  INT_CONST(%s);\n", $op->[AST_CONST];
}
print $xs_const_fh "\n\n#endif\n";
close $xs_const_fh;

# Now try to touch all C files to force the stupid build system
# to rebuild by default. I know... :(
system("touch src/*.cpp xsp/*.xsp");


sub generic_header {
  my $fh = shift;
  my $name = shift;
  print $fh <<HERE;
#ifndef $name
#define $name
// WARNING: Do not modify this file, it is generated!
// Modify the generating script $0 and its data file
// "author_tools/opcodes" instead!

HERE
}

sub prep_ops_data_file {
  my $file = "src/generated_ops_data.inc";
  open my $data_fh, ">", $file or die $!;
  generic_header($data_fh, "B_AST_OPS_DATA_GEN_INC_");
  return $data_fh;
}

sub prep_ops_enum_file {
  my $file = "src/generated_ops_enum.inc";
  open my $data_fh, ">", $file or die $!;
  generic_header($data_fh, "B_AST_OPS_ENUM_GEN_INC_");
  return $data_fh;
}

sub prep_ast_gen_op_switch_file {
  my $file = "src/generated_op_switch.inc";
  open my $data_fh, ">", $file or die $!;
  generic_header($data_fh, "B_AST_OP_SWITCH_GEN_INC_");
  return $data_fh;
}

sub prep_optree_emit_file {
  my $file = "src/generated_optree_emit.inc";
  open my $data_fh, ">", $file or die $!;
  generic_header($data_fh, "B_AST_OPTREE_EMIT_GEN_INC_");
  return $data_fh;
}

sub prep_xs_const_fh {
  my $file = "src/generated_ops_const.inc";
  open my $data_fh, ">", $file or die $!;
  generic_header($data_fh, "B_AST_OPS_CONST_GEN_INC_");
  return $data_fh;
}

sub max_col_length {
  my $ary = shift;
  my $index = shift;
  my $max = 0;
  for (@$ary) {
    $max = length($_->[$index]) if length($_->[$index]) > $max; 
  }
  return $max;
}

sub find_first_last_of_class {
  my $op_defs = shift;
  my @first_and_last;
  my $first_of_class;
  my $cur_class;
  my $prev;
  foreach my $op (@$op_defs) {
    if (not defined $cur_class) {
      $cur_class = $op->[AST_CLASS];
      $first_of_class = $op->[AST_CONST];
    }
    elsif ($op->[AST_CLASS] ne $cur_class) {
      push @first_and_last, [$cur_class, $first_of_class, $prev->[AST_CONST]];
      $cur_class = $op->[AST_CLASS];
      $first_of_class = $op->[AST_CONST];
    }
    $prev = $op;
  }
  push @first_and_last, [$cur_class, $first_of_class, $prev->[AST_CONST]];
  return \@first_and_last;
}

sub has_option {
  my $op = shift;
  my $option = shift;
  # HOBO CACHE!
  if (!defined($op->[20+OPTIONS])) {
    $op->[20+OPTIONS] = { map {$_ => 1} split /\|/, $op->[OPTIONS] };
  }
  return exists $op->[20+OPTIONS]->{$option};
};

sub has_flag {
  my $op = shift;
  my $flag = shift;
  # HOBO CACHE!
  if (!defined($op->[20+AST_FLAGS])) {
    $op->[20+AST_FLAGS] = { map {$_ => 1} split /\|/, $op->[AST_FLAGS] };
  }
  return exists $op->[20+AST_FLAGS]->{"B_ASTf_$flag"};
};
