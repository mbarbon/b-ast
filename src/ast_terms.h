#ifndef B_AST_TERMS_H_
#define B_AST_TERMS_H_

#include <vector>
#include <string>

#include <EXTERN.h>
#include <perl.h>

// Definition of types and functions for the Perl JIT AST.
typedef struct op OP; // that's the Perl OP

typedef enum {
    ast_ttype_constant,
    ast_ttype_lexical,
    ast_ttype_global,
    ast_ttype_variabledeclaration,
    ast_ttype_list,
    ast_ttype_optree,
    ast_ttype_nulloptree,
    ast_ttype_op,
    ast_ttype_statementsequence,
    ast_ttype_statement,
    ast_ttype_bareblock,
    ast_ttype_while,
    ast_ttype_for,
    ast_ttype_foreach,
    ast_ttype_map,
    ast_ttype_grep,
    ast_ttype_function_call,
    ast_ttype_empty,
    ast_ttype_loop_control
} ast_term_type;

typedef enum {
    ast_opc_baseop,
    ast_opc_unop,
    ast_opc_binop,
    ast_opc_listop,
    ast_opc_block
} ast_op_class;

// These fly in close formation with the OPf_WANT* flags in core
// in that ast_context_void/scalar/list map to the corresponding flags in
// their numeric values 1/2/3 or else using OP_GIMME wouldn't work.
typedef enum {
    ast_context_caller,
    ast_context_void,
    ast_context_scalar,
    ast_context_list
} ast_op_context;

typedef enum {
    ast_sigil_scalar,
    ast_sigil_array,
    ast_sigil_hash,
    ast_sigil_glob,
    ast_sigil_code
} ast_variable_sigil;

// This file has the actual AST op enum declaration.
#include "generated_ops_enum.inc"

// Indicates that the given op will only evaluate its arguments
// conditionally (eg. short-circuiting boolean and/or, ternary).
#define B_ASTf_KIDS_CONDITIONAL (1<<0)
// Indicates that kids may or may not exist
#define B_ASTf_KIDS_OPTIONAL (1<<1)
// Indicates that the op has an assignment form (e.g. +=, &&=, ...)
#define B_ASTf_HAS_ASSIGNMENT_FORM (1<<2)
// Indicates that the op may have overloading
#define B_ASTf_OVERLOAD (1<<3)

namespace PerlAST {
    namespace AST {
        class Term {
        public:
            Term(OP *p_op, ast_term_type t);
            virtual ~Term();

            OP *start_op();
            virtual OP *first_op();
            virtual OP *last_op();

            ast_op_context context() const;

            ast_term_type get_type() const;
            void set_type(const ast_term_type t);

            OP *get_perl_op() const;
            void set_perl_op(OP *p_op);

            virtual std::vector<Term *> get_kids() const { return empty; }

            virtual const char *perl_class() const
                { return "B::AST::Term"; }

        protected:
            ast_term_type type;
            OP *perl_op;

            static const std::vector<Term *> empty;
        };

        class Empty : public Term {
        public:
            Empty();

            virtual const char *perl_class() const
                { return "B::AST::Empty"; }
        };

        // A relatively low-on-semantics group of things, such as for
        // having separate lists of things for aassign or list slice (list
        // and indices in the latter)
        class List : public Term {
        public:
            List();
            List(const std::vector<Term *> &kid_terms);

            std::vector<Term *> get_kids() const { return kids; }
            std::vector<PerlAST::AST::Term *> kids;

            virtual const char *perl_class() const
                { return "B::AST::List"; }
            virtual ~List();
        };

        class Constant : public Term {
        public:
            Constant(OP *p_op);

            virtual const char *perl_class() const
                { return "B::AST::Constant"; }
        };

        class IVConstant : public Constant {
        public:
            IVConstant(OP *p_op, IV c);

            IV integer_value;

            virtual const char *perl_class() const
                { return "B::AST::IVConstant"; }
        };

        class UVConstant : public Constant {
        public:
            UVConstant(OP *p_op, UV c);

            UV unsigned_value;

            virtual const char *perl_class() const
                { return "B::AST::UVConstant"; }
        };

        class NVConstant : public Constant {
        public:
            NVConstant(OP *p_op, NV c);

            NV floating_value;

            virtual const char *perl_class() const
                { return "B::AST::NVConstant"; }
        };

        class StringConstant : public Constant {
        public:
            StringConstant(OP *p_op, const std::string &s, bool isUTF8);
            StringConstant(pTHX_ OP *p_op, SV *string_literal_sv);

            std::string string_value;
            bool is_utf8;

            virtual const char *perl_class() const
                { return "B::AST::StringConstant"; }
        };

        class UndefConstant : public Constant {
        public:
            UndefConstant();

            virtual const char *perl_class() const
                { return "B::AST::UndefConstant"; }
        };

        class ArrayConstant : public Constant {
        public:
            ArrayConstant(OP *p_op, AV *array);

            AV *get_const_array() const;

            virtual const char *perl_class() const
                { return "B::AST::ArrayConstant"; }

        private:
            AV *const_array;
        };

        // abstract
        class Identifier : public Term {
        public:
            Identifier(OP *p_op, ast_term_type t, ast_variable_sigil s, const std::string &name);

            ast_variable_sigil sigil;
            std::string name;
        };

        class VariableDeclaration : public Identifier {
        public:
            VariableDeclaration(OP *p_op, int ivariable, ast_variable_sigil s, const std::string &name);

            int ivar;

            int get_pad_index() const { return perl_op->op_targ; }

            virtual const char *perl_class() const
                { return "B::AST::VariableDeclaration"; }
        };

        // FIXME Right now, a Variable without declaration could reasonably be
        // any of the following: a package var, a lexically scoped thing (my/our)
        // from an outer sub (closures), ...
        class Lexical : public Identifier {
        public:
            Lexical(OP *p_op, VariableDeclaration *decl);

            VariableDeclaration *declaration;

            ast_variable_sigil get_sigil() const;
            std::string get_name() const;
            int get_pad_index() const;

            virtual const char *perl_class() const
                { return "B::AST::Lexical"; }
        };

        class Global : public Identifier {
        public:
            Global(OP *p_op, ast_variable_sigil sigil, const std::string &name);

#ifdef USE_ITHREADS
            int get_pad_index() const;
#else
            GV *get_gv() const;
#endif

            virtual const char *perl_class() const
                { return "B::AST::Global"; }
        };

        class Op : public Term {
        public:
            Op(OP *p_op, ast_op_type t);
            virtual ~Op();

            virtual const char *name() const;
            unsigned int flags() const;
            virtual ast_op_class op_class() const = 0;

            std::vector<Term *> get_kids() const { return kids; }

            bool evaluates_kids_conditionally() const
                { return flags() & B_ASTf_KIDS_CONDITIONAL; }

            bool kids_are_optional() const
                { return flags() & B_ASTf_KIDS_OPTIONAL; }

            bool may_have_explicit_overload() const
                { return flags() & B_ASTf_OVERLOAD; }

            std::vector<PerlAST::AST::Term *> kids;

            ast_op_type get_op_type() const;
            void set_op_type(ast_op_type t);

            bool is_integer_variant() const;
            void set_integer_variant(bool is_integer_variant);

            virtual const char *perl_class() const
                { return "B::AST::Op"; }

        protected:
            ast_op_type op_type;
            bool _is_integer_variant;
        };

        class Baseop : public Op {
        public:
            Baseop(OP *p_op, ast_op_type t);

            ast_op_class op_class() const
                { return ast_opc_baseop; }

            virtual const char *perl_class() const
                { return "B::AST::Baseop"; }
        };

        class Unop : public Op {
        public:
            Unop(OP *p_op, ast_op_type t, Term *kid);

            ast_op_class op_class() const
                { return ast_opc_unop; }

            virtual const char *perl_class() const
                { return "B::AST::Unop"; }
        };

        class Binop : public Op {
        public:
            Binop(OP *p_op, ast_op_type t, Term *kid1, Term *kid2);

            bool is_assignment_form() const;
            void set_assignment_form(bool is_assignment);
            bool is_synthesized_assignment() const;

            ast_op_class op_class() const
                { return ast_opc_binop; }
            virtual const char *perl_class() const
                { return "B::AST::Binop"; }

        private:
            bool is_assign_form;
        };

        class Listop : public Op {
        public:
            Listop(OP *p_op, ast_op_type t, const std::vector<Term *> &children);

            ast_op_class op_class() const
                { return ast_opc_listop; }
            virtual const char *perl_class() const
                { return "B::AST::Listop"; }
        };

        class Block : public Op {
        public:
            Block(OP *p_op, Term *statements);

            ast_op_class op_class() const
                { return ast_opc_block; }
            virtual const char *perl_class() const
                { return "B::AST::Block"; }
        };

        class BareBlock : public Term {
        public:
            BareBlock(OP *p_op, Term *body, Term *continuation);

            Term *get_body() const;
            Term *get_continuation() const;

            std::vector<PerlAST::AST::Term *> get_kids() const;

            virtual const char *perl_class() const
                { return "B::AST::BareBlock"; }

        protected:
            Term *body;
            Term *continuation;
        };

        class While : public Term {
        public:
            While(OP *p_op, Term *condition, bool negated, bool evaluate_after, Term *body, Term *continuation);

            Term *condition;
            bool negated, evaluate_after;
            Term *body;
            Term *continuation;

            std::vector<PerlAST::AST::Term *> get_kids() const;

            virtual const char *perl_class() const
                { return "B::AST::While"; }
        };

        class For : public Term {
        public:
            For(OP *p_op, Term *init, Term *condition, Term *step, Term *body);

            Term *init;
            Term *condition;
            Term *step;
            Term *body;

            virtual OP *last_op();

            std::vector<PerlAST::AST::Term *> get_kids() const;

            virtual const char *perl_class() const
                { return "B::AST::For"; }
        };

        class Foreach : public Term {
        public:
            Foreach(OP *p_op, Term *iterator, Term *expression, Term *body, Term *continuation);

            Term *iterator;
            Term *expression;
            Term *body;
            Term *continuation;

            std::vector<PerlAST::AST::Term *> get_kids() const;

            virtual const char *perl_class() const
                { return "B::AST::Foreach"; }
        };

        class ListTransformation : public Term {
        public:
            ListTransformation(OP *p_op, ast_term_type _type, Term *body, List *parameters);
            Term *body;
            List *parameters;

            std::vector<PerlAST::AST::Term *> get_kids() const;

            virtual const char *perl_class() const
                { return "B::AST::ListTransformation"; }
        };

        class Map : public ListTransformation {
        public:
            Map(OP *p_op, Term *body, List *parameters);

            virtual const char *perl_class() const
                { return "B::AST::Map"; }
        };

        class Grep : public ListTransformation {
        public:
            Grep(OP *p_op, Term *body, List *parameters);

            virtual const char *perl_class() const
                { return "B::AST::Grep"; }
        };

        class SubCall : public Term {
        public:
            SubCall(OP *entersub_op,
                    PerlAST::AST::Term *cv_src,
                    const std::vector<PerlAST::AST::Term *> &args);

            std::vector<PerlAST::AST::Term *> get_kids() const;

            virtual const char *perl_class() const
                { return "B::AST::SubCall"; }

            std::vector<PerlAST::AST::Term *> get_arguments() const;
            PerlAST::AST::Term *get_cv_source() const;

        private:
            PerlAST::AST::Term *_cv_source;
            std::vector<PerlAST::AST::Term *> _arguments;
        };

        class MethodCall : public SubCall {
        public:
            MethodCall(OP *entersub_op,
                       PerlAST::AST::Term *cv_src,
                       PerlAST::AST::Term *invocant,
                       const std::vector<PerlAST::AST::Term *> &args);

            virtual const char *perl_class() const
                { return "B::AST::MethodCall"; }

            PerlAST::AST::Term *get_invocant() const;

        private:
            PerlAST::AST::Term *_invocant;
        };

        class LoopControlStatement : public Term {
        public:
            enum ast_loop_ctl_type {
                ast_lctl_next,
                ast_lctl_redo,
                ast_lctl_last
            };

            LoopControlStatement(pTHX_ OP *p_op, AST::Term *kid);

            ast_loop_ctl_type get_loop_ctl_type() const { return ctl_type; }
            std::vector<Term *> get_kids() const { return kids; }

            bool has_label() const { return _has_label; }
            bool label_is_dynamic() const { return _label_is_dynamic; }
            bool label_is_utf8() const { return _label_is_utf8; }
            const std::string &get_label() const { return label; }

            PerlAST::AST::Term *get_jump_target() const
                { return jump_target; }
            void set_jump_target(PerlAST::AST::Term *target)
                { jump_target = target; }

            virtual const char *perl_class() const
                { return "B::AST::LoopControlStatement"; }

        private:
            void init_label(pTHX);

            ast_loop_ctl_type ctl_type;
            std::vector<PerlAST::AST::Term *> kids;
            PerlAST::AST::Term *jump_target;
            bool _has_label;
            bool _label_is_dynamic;
            bool _label_is_utf8;
            std::string label;
        };

        class Optree : public Term {
        public:
            Optree(OP *p_op);

            virtual const char *perl_class() const
                { return "B::AST::Optree"; }
        };

        class NullOptree : public Term {
        public:
            NullOptree(OP *p_op);

            virtual const char *perl_class() const
                { return "B::AST::NullOptree"; }
        };

        class Statement : public Term {
        public:
            Statement(OP *p_nextstate, Term *term);

            std::vector<PerlAST::AST::Term *> kids;
            // it would be better for this to refer to a shared string
            std::string file;
            UV line;

            std::vector<Term *> get_kids() const { return kids; }

            virtual const char *perl_class() const
                { return "B::AST::Statement"; }
        };

        // This class is anomalous in multiple ways: it does not really map to
        // a complete syntactic construct, its perl_op member is NULL and
        // it's created outside normal op traversal
        // It's an unfortunate necessity until we can recognize (and have AST
        // classes for) all block statements
        class StatementSequence : public Term {
        public:
            StatementSequence();

            std::vector<PerlAST::AST::Term *> kids;

            std::vector<Term *> get_kids() const { return kids; }

            virtual const char *perl_class() const
                { return "B::AST::StatementSequence"; }
        };
    } // end namespace PerlAST::AST
} // end namespace PerlAST

#endif
