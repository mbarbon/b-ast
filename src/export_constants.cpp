#include "export_constants.h"
#include "ast_terms.h"

#define INT_CONST(name) \
  ast_define_int(aTHX_ name, #name)

#define INT_CONST_NAMED(value, name) \
  ast_define_int(aTHX_ value, #name)

#define STRING_CONST(name) \
  ast_define_string(aTHX_ name, strlen(name), #name)

static void ast_define_int(pTHX_ IV value, const char *name) {
    char buffer[64];

    strcpy(buffer, "B::AST::");
    strcat(buffer, name);

    SV *sv = get_sv(buffer, GV_ADD);
    HV *hv = gv_stashpvs("B::AST", GV_ADD);

    sv_setiv(sv, value);
    newCONSTSUB(hv, name, sv);

    AV *export_ok = get_av("B::AST::EXPORT_OK", GV_ADD);
    av_push(export_ok, newSVpv(name, 0));
}

static void ast_define_string(pTHX_ const char *value, const STRLEN value_len, const char *name) {
    char buffer[64];

    strcpy(buffer, "B::AST::");
    strcat(buffer, name);

    SV *sv = get_sv(buffer, GV_ADD);
    HV *hv = gv_stashpvs("B::AST", GV_ADD);

    sv_setpvn(sv, value, value_len);
    newCONSTSUB(hv, name, sv);

    AV *export_ok = get_av("B::AST::EXPORT_OK", GV_ADD);
    av_push(export_ok, newSVpv(name, 0));
}

void ast_define_constants(pTHX) {
    INT_CONST(ast_ttype_constant);
    INT_CONST(ast_ttype_lexical);
    INT_CONST(ast_ttype_global);
    INT_CONST(ast_ttype_variabledeclaration);
    INT_CONST(ast_ttype_list);
    INT_CONST(ast_ttype_optree);
    INT_CONST(ast_ttype_nulloptree);
    INT_CONST(ast_ttype_op);
    INT_CONST(ast_ttype_statementsequence);
    INT_CONST(ast_ttype_statement);
    INT_CONST(ast_ttype_bareblock);
    INT_CONST(ast_ttype_while);
    INT_CONST(ast_ttype_for);
    INT_CONST(ast_ttype_foreach);
    INT_CONST(ast_ttype_map);
    INT_CONST(ast_ttype_grep);
    INT_CONST(ast_ttype_function_call);
    INT_CONST(ast_ttype_empty);
    INT_CONST(ast_ttype_loop_control);

    INT_CONST(ast_sigil_scalar);
    INT_CONST(ast_sigil_array);
    INT_CONST(ast_sigil_hash);
    INT_CONST(ast_sigil_glob);
    INT_CONST(ast_sigil_code);

    INT_CONST(ast_opc_baseop);
    INT_CONST(ast_opc_unop);
    INT_CONST(ast_opc_binop);
    INT_CONST(ast_opc_listop);
    INT_CONST(ast_opc_block);

    INT_CONST(ast_context_caller);
    INT_CONST(ast_context_void);
    INT_CONST(ast_context_scalar);
    INT_CONST(ast_context_list);

#include "generated_ops_const.inc"

    INT_CONST(ast_unop_FIRST);
    INT_CONST(ast_unop_LAST);

    INT_CONST(ast_binop_FIRST);
    INT_CONST(ast_binop_LAST);

    INT_CONST(ast_listop_FIRST);
    INT_CONST(ast_listop_LAST);

    {
        using namespace PerlAST::AST;

        INT_CONST_NAMED(LoopControlStatement::ast_lctl_next, ast_lctl_next);
        INT_CONST_NAMED(LoopControlStatement::ast_lctl_redo, ast_lctl_redo);
        INT_CONST_NAMED(LoopControlStatement::ast_lctl_last, ast_lctl_last);

        INT_CONST_NAMED(Sort::ast_sort_merge, ast_sort_merge);
        INT_CONST_NAMED(Sort::ast_sort_quick, ast_sort_quick);
    }
}
