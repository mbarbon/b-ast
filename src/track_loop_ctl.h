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
    }

    class LoopCtlTracker {
    public:
        LoopCtlTracker();

        static std::string get_label_from_nextstate(pTHX_ COP *nextstate_op);

        void push_loop_scope(pTHX_ COP *nextstate_op);
        void add_loop_control_node(pTHX_ AST::LoopControlStatement *ctrl_term);
        void pop_loop_scope(pTHX_ AST::Term *loop);

    private:
        typedef std::vector<AST::LoopControlStatement *> LoopControlList;

        struct LoopScope {
            std::string label;
            LoopControlList pending_statements;

            LoopScope(const std::string &_label)
                : label(_label)
            {}
        };

        typedef std::vector<LoopScope> LoopStack;

        LoopStack scopes;
    };
}

#endif
