#ifndef B_AST_OPTREE_H_
#define B_AST_OPTREE_H_

#include "EXTERN.h"
#include "perl.h"

#include "ast_terms.h"

#include <vector>

/* Starting from root OP of the CV, traverse the tree and build the AST */

std::vector<PerlAST::AST::Term *> analyze_optree(pTHX_ SV *coderef);
std::vector<PerlAST::AST::Term *> analyze_optree(pTHX_ CV *coderef);

#endif
