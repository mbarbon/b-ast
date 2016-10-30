#ifndef B_AST_BASICBLOCK_H_
#define B_AST_BASICBLOCK_H_

#include <vector>

namespace PerlAST {
    namespace AST {
        class Term;

        class BasicBlock {
        public:
            BasicBlock(unsigned int label);
            virtual ~BasicBlock();

            void push_term(Term *term);

            unsigned int label;
            std::vector<Term *> sequence;
            std::vector<BasicBlock *> predecessors;
            std::vector<BasicBlock *> successors;
        };

        void link_blocks(BasicBlock *pred, BasicBlock *succ);
    }
}

#endif
