#ifndef B_AST_AST_VALUES_H_
#define B_AST_AST_VALUES_H_

#include <vector>
#include <string>

#include <EXTERN.h>
#include <perl.h>

typedef enum {
    ast_vtype_rv,
    ast_vtype_iv,
    ast_vtype_uv,
    ast_vtype_nv,
    ast_vtype_pv,
    ast_vtype_subroutine,
} ast_value_type;

namespace PerlAST {
    namespace AST {
        class Term;

        class Value {
        public:
            Value(ast_value_type t);
            virtual ~Value();

            virtual const char *perl_class() const
                { return "B::AST::Value"; }

            ast_value_type get_type() const { return value_type; }

        protected:
            ast_value_type value_type;
        };

        class RVScalar : public Value {
        public:
            RVScalar(const Value *value);

            virtual const char *perl_class() const
                { return "B::AST::RVScalar"; }

            const Value *reference;
        };

        class IVScalar : public Value {
        public:
            IVScalar(IV value);

            virtual const char *perl_class() const
                { return "B::AST::IVScalar"; }

            IV integer_value;
        };

        class Subroutine : public Value {
        public:
            Subroutine(const Term *ast, const std::vector<Value *> &closed_over);

            virtual const char *perl_class() const
                { return "B::AST::Subroutine"; }

            const std::vector<Value *> closed_over;
            const Term *ast;
        };
    }
}

#endif
