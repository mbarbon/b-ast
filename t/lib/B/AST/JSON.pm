package B::AST::Term;

use strict;
use warnings;

use JSON;

sub dump_json {
    return JSON::to_json($_[0]->json_value);
}

sub json_value {
    return {
        type => $_[0]->json_type,
        $_[0]->json_fields,
    };
}

sub json_type { substr ref($_[0]), 8 }

package B::AST::IVConstant;

sub json_fields { value => $_[0]->get_integer_value }

package B::AST::UVConstant;

sub json_fields { value => $_[0]->get_unsigned_value }

package B::AST::NVConstant;

sub json_fields { value => $_[0]->get_floating_value }

package B::AST::VariableDeclaration;

sub json_fields {
    return (
        context => $_[0]->context,
        sigil   => $_[0]->get_sigil,
        index   => $_[0]->get_pad_index,
        name    => $_[0]->get_name,
    );
}

package B::AST::Global;

sub json_fields {
    return (
        context => $_[0]->context,
        sigil   => $_[0]->get_sigil,
        name    => $_[0]->get_name,
    );
}

package B::AST::Lexical;

sub json_fields {
    return (
        context => $_[0]->context,
        sigil   => $_[0]->get_sigil,
        index   => $_[0]->get_pad_index,
        name    => $_[0]->get_name,
    );
}

package B::AST::Binop;

sub json_fields {
    my ($left, $right) = map $_->json_value, $_[0]->get_kids;

    return (
        context       => $_[0]->context,
        left          => $left,
        right         => $right,
        op            => $_[0]->get_op_type,
        is_assignment => $_[0]->is_assignment_form ? 1 : 0,
    );
}

package B::AST::Statement;

sub json_fields {
    return (
        body => (map $_->json_value, $_[0]->get_kids)[0],
        file => $_[0]->get_file,
        line => $_[0]->get_line,
    );
}

package B::AST::StatementSequence;

sub json_fields {
    return (
        statements => [map $_->json_value, $_[0]->get_kids],
    )
}

package B::AST::Value;

use strict;
use warnings;

use JSON;

sub dump_json {
    return JSON::to_json($_[0]->json_value);
}

sub json_value {
    return {
        type => $_[0]->json_type,
        $_[0]->json_fields,
    };
}

sub json_type { substr ref($_[0]), 8 }

package B::AST::RVScalar;

sub json_fields { value => $_[0]->get_reference->json_value }

package B::AST::IVScalar;

sub json_fields { value => $_[0]->get_integer_value }

package B::AST::Subroutine;

sub json_fields {
    return (
        ast         => $_[0]->get_ast->json_value,
        closed_over => [map $_ ? $_->json_value : undef, $_[0]->get_closed_over],
    )
}

1;
