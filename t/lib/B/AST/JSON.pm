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

package B::AST::Empty;

sub json_fields { }

package B::AST::Optree;

# here to avoid test die()ing without output, but it should never be generated
sub json_fields { }

package B::AST::IVConstant;

sub json_fields { value => $_[0]->get_integer_value }

package B::AST::UVConstant;

sub json_fields { value => $_[0]->get_unsigned_value }

package B::AST::NVConstant;

sub json_fields { value => $_[0]->get_floating_value }

package B::AST::UndefConstant;

sub json_fields { }

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

package B::AST::Baseop;

sub json_fields {
    return (
        context       => $_[0]->context,
        op            => $_[0]->get_op_type,
    );
}

package B::AST::Unop;

sub json_fields {
    return (
        context       => $_[0]->context,
        term          => $_[0]->get_kid->json_value,
        op            => $_[0]->get_op_type,
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

package B::AST::Listop;

sub json_fields {
    return (
        context       => $_[0]->context,
        terms         => [map $_->json_value, $_[0]->get_kids],
        op            => $_[0]->get_op_type,
    );
}

package B::AST::List;

sub json_fields {
    items => [map $_->json_value, $_[0]->get_kids]
}

package B::AST::LoopControlStatement;

sub json_fields {
    my ($self) = @_;
    my $target = $self->get_jump_target;

    return (
        ctl_type => $self->get_loop_ctl_type,
        !$target ? () : (
            target_type => $target->json_type,
        ),
        !$self->has_label ? () : (
            $self->label_is_dynamic ? (
                label_expression => ($self->get_kids)[0],
            ) : (
                label => $self->get_label,
            ),
        ),
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

package B::AST::Block;

sub json_fields {
    return (
        body         => ($_[0]->get_kids)[0]->json_value,
    );
}

package B::AST::BareBlock;

sub json_fields {
    return (
        body         => $_[0]->get_body->json_value,
        continuation => $_[0]->get_continuation->json_value,
    );
}

package B::AST::While;

sub json_fields {
    return (
        condition    => $_[0]->get_condition->json_value,
        body         => $_[0]->get_body->json_value,
        continuation => $_[0]->get_continuation->json_value,
    );
}

package B::AST::Foreach;

sub json_fields {
    return (
        iterator     => $_[0]->get_iterator->json_value,
        expression   => $_[0]->get_expression->json_value,
        body         => $_[0]->get_body->json_value,
        continuation => $_[0]->get_continuation->json_value,
    );
}

package B::AST::For;

sub json_fields {
    return (
        init         => $_[0]->get_init->json_value,
        condition    => $_[0]->get_condition->json_value,
        step         => $_[0]->get_step->json_value,
        body         => $_[0]->get_body->json_value,
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
