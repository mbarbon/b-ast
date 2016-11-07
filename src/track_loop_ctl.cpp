#include "track_loop_ctl.h"
#include "ppport.h"
#include "ast_debug.h"
#include "ast_terms.h"
#include "ast_basicblock.h"

using namespace PerlAST;
using namespace std;

// - an hashmap-of-lists-of-lists (mapping LABEL -> list of nested loops -> list of next/last/redo referring to that loop
// - when starting a loopy construct but before recursing into kids, push an empty list into the stack for the loop label
// - when encountering a next/last/redo, push the AST node into map[LABEL].back()
// - when done with the loop parsing, pop the list from the stack and fix all references

std::string LoopCtlTracker::get_label_from_nextstate(pTHX_ COP *nextstate_op) {
    assert(nextstate_op->op_type == OP_NEXTSTATE);

    // *sigh* about the strlen dance
    STRLEN cop_label_len = 0;

    string retval("");
#ifdef CopLABEL_len
    const char *cop_label = CopLABEL_len(nextstate_op, &cop_label_len);
    if (cop_label != NULL)
        retval = string(cop_label, cop_label_len);
#else
    const char *cop_label = CopLABEL(nextstate_op);
    if (cop_label != NULL)
        retval = string(cop_label, strlen(cop_label));
#endif
    AST_DEBUG_2("get_label_from_nextstate: %p %s\n", nextstate_op, retval.c_str());
    return retval;
}

LoopCtlTracker::LoopCtlTracker() {
}

void LoopCtlTracker::push_loop_scope(pTHX_ COP *nextstate_op) {
    string label = get_label_from_nextstate(aTHX_ nextstate_op);
    AST_DEBUG_1("LoopCtlTracker: Scope for label='%s'\n", label.c_str());
    scopes.push_back(LoopScope(label));
    AST_DEBUG_1("LoopCtlTracker: N scopes: %i\n", (int)scopes.size());
}

void LoopCtlTracker::add_loop_control_node(pTHX_ AST::LoopControlStatement *ctrl_term, AST::BasicBlock *ctrl_block) {
    AST_DEBUG_1("LoopCtlTracker; Adding ctl statment for label='%s'\n", ctrl_term->get_label().c_str());
    // no loop, this will remain untracked
    if (scopes.empty())
        return;
    const std::string label = ctrl_term->get_label();
    if (label.empty()) {
        scopes.back().pending_statements.push_back(ControlItem(ctrl_term, ctrl_block));
    } else {
        typedef LoopStack::reverse_iterator riter;
        for (riter it = scopes.rbegin(), en = scopes.rend(); it != en; ++it) {
            if (it->label == label) {
                it->pending_statements.push_back(ControlItem(ctrl_term, ctrl_block));
                break;
            }
        }
    }
}

void LoopCtlTracker::set_control_blocks(AST::BasicBlock *next, AST::BasicBlock *last, AST::BasicBlock *redo) {
    LoopScope &current = scopes.back();

    current.next_block = next;
    current.last_block = last;
    current.redo_block = redo;
}

void LoopCtlTracker::pop_loop_scope(pTHX_ AST::Term *loop) {
    assert(!scopes.empty());
    AST_DEBUG_2("LoopCtlTracker: End scope for label='%s' (N scopes: %i)\n", scopes.back().label.c_str(), scopes.size());
#ifndef NDEBUG
    ast_term_type t = loop->get_type();
    assert(   t == ast_ttype_bareblock || t == ast_ttype_while
           || t == ast_ttype_for       || t == ast_ttype_foreach);
#endif

    LoopControlList &pending = scopes.back().pending_statements;
    for (LoopControlList::iterator it = pending.begin(), en = pending.end(); it != en; ++it) {
        it->statement->set_jump_target(loop);
        switch (it->statement->get_loop_ctl_type()) {
        case AST::LoopControlStatement::ast_lctl_next:
            link_blocks(it->block, scopes.back().next_block);
            break;
        case AST::LoopControlStatement::ast_lctl_last:
            link_blocks(it->block, scopes.back().last_block);
            break;
        case AST::LoopControlStatement::ast_lctl_redo:
            link_blocks(it->block, scopes.back().redo_block);
            break;
        }
    }

    scopes.pop_back();
}
