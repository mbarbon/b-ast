#ifndef B_AST_OPTREE_H_
#define B_AST_OPTREE_H_

#include "EXTERN.h"
#include "perl.h"

#include <vector>

/* Starting from root OP of the CV, traverse the tree and build the AST */

namespace PerlAST {
    namespace AST {
        struct BasicBlock;
        struct Term;
    };

    struct OptreeInfo {
        std::vector<PerlAST::AST::Term *> terms;
        std::vector<PerlAST::AST::BasicBlock *> basic_blocks;

        OptreeInfo(const std::vector<PerlAST::AST::Term *> &_terms,
                   const std::vector<PerlAST::AST::BasicBlock *> &_basic_blocks)
            : terms(_terms), basic_blocks(_basic_blocks)
        {}
    };
}

PerlAST::OptreeInfo analyze_optree(pTHX_ CV *cv);

/* for testing */
std::vector<PerlAST::AST::Term *> analyze_optree_ast(pTHX_ SV *coderef);
std::vector<PerlAST::AST::BasicBlock *> analyze_optree_basic_blocks(pTHX_ SV *coderef);

#endif
