#include "ast_basicblock.h"

using namespace PerlAST;
using namespace PerlAST::AST;

BasicBlock::BasicBlock(unsigned int _label)
    : label(_label) {
}

BasicBlock::~BasicBlock() {
}

void BasicBlock::push_term(Term *term) {
    sequence.push_back(term);
}

void PerlAST::AST::link_blocks(BasicBlock *pred, BasicBlock *succ) {
    pred->successors.push_back(succ);
    succ->predecessors.push_back(pred);
}
