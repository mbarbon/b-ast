package t::lib::Test;

use strict;
use warnings;
use parent 'Test::Builder::Module';

use Test::More;
use Test::Differences;

use B::AST;
use JSON;
use YAML::Tiny;

sub import {
    unshift @INC, 't/lib';

    require B::AST::JSON;

    strict->import;
    warnings->import;

    goto &Test::Builder::Module::import;
}


our @EXPORT = (
    @Test::More::EXPORT,
    @Test::Differences::EXPORT,
    qw(
       op_ast_eq_or_diff
       bb_ast_eq_or_diff
       v_ast_eq_or_diff
    ),
);

sub op_ast_eq_or_diff {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($code, $text) = @_;
    my $sub = eval <<"EOT";
sub {
#line 1 "TEST"
    $code
}
EOT
    my @asts = B::AST::analyze_optree_ast($sub);
    die "No AST" if @asts == 0;
    die "More than one AST" if @asts > 1;
    my $yaml = YAML::Tiny->new(JSON::from_json($asts[0]->dump_json))->write_string;

    {
        no strict 'refs';

        $text =~ s{(ast_\w+)}{&{"B::AST::$1"}}ge;
    }

    eq_or_diff($yaml, $text);
}

sub bb_ast_eq_or_diff {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($code, $text) = @_;
    my $sub = eval <<"EOT";
sub {
#line 1 "TEST"
    $code
}
EOT
    my @blocks = B::AST::analyze_optree_basic_blocks($sub);
    my $yaml = YAML::Tiny->new([map JSON::from_json($_->dump_json), @blocks])->write_string;

    {
        no strict 'refs';

        $text =~ s{(ast_\w+)}{&{"B::AST::$1"}}ge;
    }

    eq_or_diff($yaml, $text);
}

sub v_ast_eq_or_diff {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my ($code, $text) = @_;
    my $val = eval <<"EOT";
#line 1 "TEST"
    $code
EOT
    my $ast = B::AST::analyze_value($val);
    my $yaml = YAML::Tiny->new(JSON::from_json($ast->dump_json))->write_string;

    {
        no strict 'refs';

        $text =~ s{(ast_\w+)}{&{"B::AST::$1"}}ge;
    }

    eq_or_diff($yaml, $text);
}

1;
