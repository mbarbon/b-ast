#include "ast_terms.h"

#include "EXTERN.h"
#include "perl.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

using namespace PerlAST;
using namespace PerlAST::AST;

// That file has the static data about AST ops such as their
// human-readable names and their flags.
#include "generated_ops_data.inc"

const std::vector<Term *> Term::empty;

Term::Term(OP *p_op, ast_term_type t)
    : type(t), perl_op(p_op)
{}

Empty::Empty()
    : Term(NULL, ast_ttype_empty)
{}

List::List()
    : Term(NULL, ast_ttype_list)
{}

List::List(const std::vector<Term *> &kid_terms)
    : Term(NULL, ast_ttype_list) {
    // Flatten nested AST::List's. Need only one level of
    // flattening since they all flattened on construction (hopefully).
    const unsigned int n = kid_terms.size();
    for (unsigned int i = 0; i < n; ++i) {
        if (kid_terms[i]->get_type() == ast_ttype_list) {
            List *l = (List *)kid_terms[i];
            // transfer ownership if sub-elements
            std::vector<Term *> &nested_kids = l->kids;
            for (unsigned int j = 0; j < nested_kids.size(); ++j) {
                kids.push_back(nested_kids[j]);
            }
            nested_kids.clear();
            delete l;
        }
        else
            kids.push_back(kid_terms[i]);
    }
}

Constant::Constant(OP *p_op)
    : Term(p_op, ast_ttype_constant)
{}

IVConstant::IVConstant(OP *p_op, IV c)
    : Constant(p_op),
      integer_value(c)
{}

UVConstant::UVConstant(OP *p_op, UV c)
    : Constant(p_op),
      unsigned_value(c)
{}

NVConstant::NVConstant(OP *p_op, NV c)
    : Constant(p_op),
      floating_value(c)
{}

StringConstant::StringConstant(OP *p_op, const std::string& s, bool isUTF8)
    : Constant(p_op),
      string_value(s), is_utf8(isUTF8)
{}

StringConstant::StringConstant(pTHX_ OP *p_op, SV *string_literal_sv)
    : Constant(p_op) {
    STRLEN l;
    char *s;
    s = SvPV(string_literal_sv, l);
    string_value = std::string(s, (size_t)l);
    is_utf8 = (bool)SvUTF8(string_literal_sv);
}

UndefConstant::UndefConstant()
    : Constant(NULL)
{}

ArrayConstant::ArrayConstant(OP *p_op, AV *array)
    : Constant(p_op),
      const_array(array)
{}


Identifier::Identifier(OP *p_op, ast_term_type t, ast_variable_sigil s, const std::string &n)
    : Term(p_op, t), sigil(s), name(n)
{}


VariableDeclaration::VariableDeclaration(OP *p_op, int ivariable, ast_variable_sigil sigil, const std::string &name)
    : Identifier(p_op, ast_ttype_variabledeclaration, sigil, name),
      ivar(ivariable)
{}


Lexical::Lexical(OP *p_op, VariableDeclaration *decl)
    : Identifier(p_op, ast_ttype_lexical, decl->sigil, ""), declaration(decl)
{}


Global::Global(OP *p_op, ast_variable_sigil s, const std::string &name)
    : Identifier(p_op, ast_ttype_global, s, name)
{}


Optree::Optree(OP *p_op)
    : Term(p_op, ast_ttype_optree)
{}


NullOptree::NullOptree(OP *p_op)
    : Term(p_op, ast_ttype_nulloptree)
{}


Op::Op(OP *p_op, ast_op_type t)
  : Term(p_op, ast_ttype_op), op_type(t), _is_integer_variant(false)
{}


Unop::Unop(OP *p_op, ast_op_type t, Term *kid)
    : Op(p_op, t) {
    if (kid == NULL) {
        // assert that kids are optional, since NULL passed
        assert(this->flags() & B_ASTf_KIDS_OPTIONAL);
    }
    kids.resize(1);
    kids[0] = kid;
}


Baseop::Baseop(OP *p_op, ast_op_type t)
    : Op(p_op, t)
{}


Binop::Binop(OP *p_op, ast_op_type t, Term *kid1, Term *kid2)
    : Op(p_op, t), is_assign_form(false) {
    // assert that kids are optional if at least one NULL passed
    assert( (kid1 != NULL && kid2 != NULL)
            || (this->flags() & B_ASTf_KIDS_OPTIONAL) );
    kids.resize(2);
    kids[0] = kid1;
    kids[1] = kid2;
}


Listop::Listop(OP *p_op, ast_op_type t, const std::vector<Term *> &children)
    : Op(p_op, t) {
    // TODO assert() that children aren't NULL _OR_
    //      the B_ASTf_KIDS_OPTIONAL flag is set
    kids = children;
}


Block::Block(OP *p_op, Term *statements)
    : Op(p_op, ast_op_scope) {
    kids.resize(1);
    kids[0] = statements;
}


BareBlock::BareBlock(OP *p_op, Term *_body, Term *_continuation)
    : Term(p_op, ast_ttype_bareblock), body(_body), continuation(_continuation)
{}

Term *BareBlock::get_body() const {
  return body;
}

Term *BareBlock::get_continuation() const {
  return continuation;
}


While::While(OP *p_op, Term *_condition, bool _negated, bool _evaluate_after,
             Term *_body, Term *_continuation)
    : Term(p_op, ast_ttype_while), condition(_condition),
      negated(_negated), evaluate_after(_evaluate_after),
      body(_body), continuation(_continuation)
{}


For::For(OP *p_op, Term *_init, Term *_condition, Term *_step, Term *_body)
    : Term(p_op, ast_ttype_for), init(_init), condition(_condition),
      step(_step), body(_body)
{}


Foreach::Foreach(OP *p_op, Term *_iterator, Term *_expression, Term *_body, Term *_continuation)
    : Term(p_op, ast_ttype_foreach), iterator(_iterator), expression(_expression),
      body(_body), continuation(_continuation)
{}

ListTransformation::ListTransformation(OP *p_op, ast_term_type type, Term *_body, List *_parameters)
    : Term(p_op, type), body(_body), parameters(_parameters)
{}

Map::Map(OP *p_op, Term *_body, List *_parameters)
    : ListTransformation(p_op, ast_ttype_map, _body, _parameters)
{}

Grep::Grep(OP *p_op, Term *_body, List *_parameters)
    : ListTransformation(p_op, ast_ttype_grep, _body, _parameters)
{}


SubCall::SubCall(OP *entersub_op,
                 PerlAST::AST::Term *cv_src,
                 const std::vector<PerlAST::AST::Term *> &args)
    : Term(entersub_op, ast_ttype_function_call), _cv_source(cv_src), _arguments(args)
{}

std::vector<PerlAST::AST::Term *> SubCall::get_arguments() const {
    return _arguments;
}

PerlAST::AST::Term *SubCall::get_cv_source() const {
    return _cv_source;
}


MethodCall::MethodCall(OP *entersub_op,
                       PerlAST::AST::Term *cv_src,
                       PerlAST::AST::Term *invocant,
                       const std::vector<PerlAST::AST::Term *> &args)
    : SubCall(entersub_op, cv_src, args), _invocant(invocant)
{}

PerlAST::AST::Term *MethodCall::get_invocant() const {
    return _invocant;
}

LoopControlStatement::LoopControlStatement(pTHX_ OP *p_op, AST::Term *kid)
    : Term(p_op, ast_ttype_loop_control), jump_target(NULL) {
    if (kid != NULL)
        kids.push_back(kid);

    switch (p_op->op_type) {
    case OP_NEXT:
        ctl_type = ast_lctl_next;
        break;
    case OP_REDO:
        ctl_type = ast_lctl_redo;
        break;
    case OP_LAST:
        ctl_type = ast_lctl_last;
        break;
    default:
        abort();
    };

    init_label(aTHX);
}

void LoopControlStatement::init_label(pTHX) {
    // Alas, it appears that loop control statements can be any of
    // the following:
    // - OP: if bare
    // - PVOP: if using a constant label that has no embedded NUL's
    //         NB: It seems that there is no way to have a label with
    //             embedded NUL's?
    // - SVOP: if using a constant label with embedded NUL's.
    //         NB: Likely, this code path just exists for paranoia!
    // - UNOP: (and OPf_STACKED set) if label is a variable, see example
    //         below. In this case, we cannot compute the jump target
    //         statically. :(
    //
    // Example for dynamic label (*sigh*):
    // $ perl -MO=Concise -E 'last $foo'
    // 5  <@> leave[1 ref] vKP/REFC ->(end)
    // 1     <0> enter ->2
    // 2     <;> nextstate(main 47 -e:1) v:%,{,469764096 ->3
    // 4     <1> last vKS/1 ->5
    // -        <1> ex-rv2sv sK/1 ->4
    // 3           <$> gvsv(*foo) s ->4
    // -e syntax OK

    if (perl_op->op_flags & OPf_STACKED) {
        // The dreaded "it's a dynamic label" case!
        // Nothing much we can do.
        _label_is_dynamic = true;
        label = std::string("");
        _label_is_utf8 = false; // ho-humm...
        _has_label = true;
        return;
    }

    _label_is_dynamic = false;
    // OPf_SPECIAL set means it's a bare loop control statement.
    if (perl_op->op_flags & OPf_SPECIAL) {
        label = std::string("");
        _label_is_dynamic = false;
        _has_label = false;
        _label_is_utf8 = false;
        return;
    }

    // Must be a PVOP
    _has_label = true;
    const char * const label_str = cPVOPx(perl_op)->op_pv;
#ifdef OPpPV_IS_UTF8
    /* 5.16 and up */
    _label_is_utf8 = cPVOPx(perl_op)->op_private & OPpPV_IS_UTF8;
#else
    _label_is_utf8 = false;
#endif
    if (label_str != NULL)
        label = std::string(label_str, strlen(label_str));
    else
        label = std::string("");

    return;
}

Statement::Statement(OP *p_nextstate, Term *term)
    : Term(p_nextstate, ast_ttype_statement) {
    kids.resize(1);
    kids[0] = term;
    file = CopFILE(cCOPx(p_nextstate));
    line = CopLINE(cCOPx(p_nextstate));
}

Sort::Sort(OP *p_op, Term *cmp_fun, const std::vector<Term *> & args)
  : Term(p_op, ast_ttype_sort),
    needs_reverse(false),
    is_numeric(false),
    is_inplace(false),
    is_guaranteed_stable(false),
    is_integer_sort(false),
    cmp_function(cmp_fun),
    arguments(args),
    sort_algo(ast_sort_merge)
{}

StatementSequence::StatementSequence()
    : Term(NULL, ast_ttype_statementsequence)
{}

Term::~Term()
{}

Op::~Op() {
    std::vector<PerlAST::AST::Term *> &k = kids;
    const unsigned int n = k.size();
    for (unsigned int i = 0; i < n; ++i)
        delete k[i];
}

List::~List() {
    std::vector<PerlAST::AST::Term *> &k = kids;
    const unsigned int n = k.size();
    for (unsigned int i = 0; i < n; ++i)
        delete k[i];
}

ast_term_type Term::get_type() const {
    return type;
}

void Term::set_type(const ast_term_type t) {
    type = t;
}

OP * Term::get_perl_op() const {
    return perl_op;
}

void Term::set_perl_op(OP *p_op) {
    perl_op = p_op;
}

OP *Term::start_op() {
    OP *o = perl_op;
    while (1) {
        if (o->op_flags & OPf_KIDS &&
            // do not recurse into the list op with JITted code
            (o->op_type != OP_LIST || o->op_private != 1))
            o = cUNOPo->op_first;
        else
            return o;
    }
}

OP *Term::first_op() {
    return perl_op;
}

OP *Term::last_op() {
    return perl_op;
}

ast_op_context Term::context() const {
    return ast_op_context(OP_GIMME(perl_op, ast_context_caller));
}

const char *Op::name() const {
  return b_ast_op_names[op_type];
}

unsigned int Op::flags() const {
    return b_ast_op_flags[op_type];
}

ast_op_type Op::get_op_type() const {
    return op_type;
}

void Op::set_op_type(ast_op_type t) {
    op_type = t;
}

bool Op::is_integer_variant() const {
    return _is_integer_variant;
}

void Op::set_integer_variant(bool is_integer_variant) {
    _is_integer_variant = is_integer_variant;
}

bool Binop::is_assignment_form() const {
    return (
        is_assign_form
        || ( (flags() & B_ASTf_HAS_ASSIGNMENT_FORM) &&
             (perl_op->op_flags & OPf_STACKED) )
        );
}

void Binop::set_assignment_form(bool is_assignment) {
    is_assign_form = is_assignment;
}

bool Binop::is_synthesized_assignment() const {
    return op_type == ast_binop_sassign && kids[1]->get_perl_op() == perl_op;
}


ast_variable_sigil Lexical::get_sigil() const {
    return declaration->sigil;
}

std::string Lexical::get_name() const {
    return declaration->name;
}

int Lexical::get_pad_index() const {
    return declaration->get_pad_index();
}

#ifdef USE_ITHREADS
int Global::get_pad_index() const {
    if (perl_op->op_type == OP_RV2AV || perl_op->op_type == OP_RV2HV)
        return cPADOPx(cUNOPx(perl_op)->op_first)->op_padix;
    else
        return cPADOPx(perl_op)->op_padix;
}
#else
GV *Global::get_gv() const {
    if (perl_op->op_type == OP_RV2AV || perl_op->op_type == OP_RV2HV)
        return cGVOPx_gv(cUNOPx(perl_op)->op_first);
    else
        return cGVOPx_gv(perl_op);
}
#endif

std::vector<PerlAST::AST::Term *> BareBlock::get_kids() const {
    std::vector<PerlAST::AST::Term *> kids;

    kids.push_back(body);
    if (continuation->get_type() != ast_ttype_empty)
        kids.push_back(continuation);

    return kids;
}

std::vector<PerlAST::AST::Term *> While::get_kids() const {
    std::vector<PerlAST::AST::Term *> kids;

    kids.push_back(condition);
    kids.push_back(body);
    if (continuation->get_type() != ast_ttype_empty)
        kids.push_back(continuation);

    return kids;
}

OP *For::last_op() {
    if (init->get_type() == ast_ttype_empty)
        return perl_op;

    // handle the case when the unstack op has been detached from the tree
    OP *leave = init->get_perl_op()->op_sibling;
    if (leave->op_type == OP_UNSTACK)
        leave = leave->op_sibling;

    assert(leave->op_type == OP_LEAVELOOP);
    return leave;
}

std::vector<PerlAST::AST::Term *> For::get_kids() const {
    std::vector<PerlAST::AST::Term *> kids;

    kids.push_back(init);
    kids.push_back(condition);
    kids.push_back(step);
    kids.push_back(body);

    return kids;
}

std::vector<PerlAST::AST::Term *> Foreach::get_kids() const {
    std::vector<PerlAST::AST::Term *> kids;

    kids.push_back(iterator);
    kids.push_back(expression);
    kids.push_back(body);
    kids.push_back(continuation);

    return kids;
}

std::vector<PerlAST::AST::Term *> ListTransformation::get_kids() const {
    std::vector<PerlAST::AST::Term *> kids;

    kids.push_back(body);
    kids.push_back(parameters);

    return kids;
}

std::vector<PerlAST::AST::Term *> SubCall::get_kids() const {
    std::vector<PerlAST::AST::Term *> kids;

    kids.insert(kids.end(), _arguments.begin(), _arguments.end());
    kids.push_back(_cv_source);

    return kids;
}
