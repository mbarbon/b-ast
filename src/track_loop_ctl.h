#ifndef B_AST_LOOPCTLTRACKER_H_
#define B_AST_LOOPCTLTRACKER_H_

#include "EXTERN.h"
#include "perl.h"

#include <vector>
#include <string>

namespace PerlAST {
    namespace AST {
        class Term;
        class LoopControlStatement;
        class BasicBlock;
    }

    class LoopCtlTracker {
    public:
        LoopCtlTracker();

        static std::string get_label_from_nextstate(pTHX_ COP *nextstate_op);

        void push_loop_scope(pTHX_ COP *nextstate_op);
        void add_loop_control_node(pTHX_ AST::LoopControlStatement *ctrl_term, AST::BasicBlock *ctrl_block);
        void set_control_blocks(AST::BasicBlock *next, AST::BasicBlock *last, AST::BasicBlock *redo);
        void pop_loop_scope(pTHX_ AST::Term *loop);

    private:
        struct ControlItem {
            AST::LoopControlStatement *statement;
            AST::BasicBlock *block;

            ControlItem(AST::LoopControlStatement *s, AST::BasicBlock *b)
                : statement(s), block(b)
            {}
        };

        typedef std::vector<ControlItem> LoopControlList;

        struct LoopScope {
            std::string label;
            LoopControlList pending_statements;
            AST::BasicBlock *next_block, *last_block, *redo_block;

            LoopScope(const std::string &_label)
                : label(_label),
                  next_block(NULL), last_block(NULL), redo_block(NULL)
            {}
        };

        typedef std::vector<LoopScope> LoopStack;

        LoopStack scopes;
    };
}

#endif
