#ifndef B_AST_VALUES_H_
#define B_AST_VALUES_H_

#include "EXTERN.h"
#include "perl.h"

#include "ast_values.h"

/* Code relating to traversing and manipulating the value tree */

PerlAST::AST::Value *analyze_value(pTHX_ SV *sv);

#endif
