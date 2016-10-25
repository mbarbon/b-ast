#include "ast_values.h"

#include "EXTERN.h"
#include "perl.h"

using namespace PerlAST;
using namespace PerlAST::AST;

Value::Value(ast_value_type t)
    : value_type(t)
{}

Value::~Value()
{}

RVScalar::RVScalar(const Value *value)
    : Value(ast_vtype_rv),
      reference(value)
{}

IVScalar::IVScalar(IV value)
    : Value(ast_vtype_iv),
      integer_value(value)
{}

Subroutine::Subroutine(const Term *a, const std::vector<Value *> &c)
    : Value(ast_vtype_subroutine),
      ast(a), closed_over(c)
{}

