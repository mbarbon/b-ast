#include "track_loop_ctl.h"
#include "ppport.h"
#include "ast_debug.h"

using namespace PerlAST;
using namespace std;

// - an hashmap-of-lists-of-lists (mapping LABEL -> list of nested loops -> list of next/last/redo referring to that loop
// - when starting a loopy construct but before recursing into kids, push an empty list into the stack for the loop label
// - when encountering a next/last/redo, push the AST node into map[LABEL].back()
// - when done with the loop parsing, pop the list from the stack and fix all references

std::string LoopCtlTracker::get_label_from_nextstate(pTHX_ OP *nextstate_op) {
    assert(nextstate_op->op_type == OP_NEXTSTATE);

    COP *ns = (COP *)nextstate_op;

    // *sigh* about the strlen dance
    STRLEN cop_label_len = 0;

    string retval("");
#ifdef CopLABEL_len
    const char *cop_label = CopLABEL_len((COP *)nextstate_op, &cop_label_len);
    if (cop_label != NULL)
        retval = string(cop_label, cop_label_len);
#else
    const char *cop_label = CopLABEL((COP *)nextstate_op);
    if (cop_label != NULL)
        retval = string(cop_label, strlen(cop_label));
#endif
    AST_DEBUG_2("get_label_from_nextstate: %p %s\n", nextstate_op, retval.c_str());
    return retval;
}

LoopCtlTracker::LoopCtlTracker() {
}

const LoopCtlIndex &LoopCtlTracker::get_loop_control_index() const {
    return loop_control_index;
}

void LoopCtlTracker::push_loop_scope(const std::string &label) {
    AST_DEBUG_1("LoopCtlTracker: Scope for label='%s'\n", label.c_str());
    loop_control_index[label].push_back(LoopCtlStatementList());
    AST_DEBUG_1("LoopCtlTracker: N scopes: %i\n", (int)loop_control_index[label].size());
}

void LoopCtlTracker::add_loop_control_node(pTHX_ AST::LoopControlStatement *ctrl_term) {
    AST_DEBUG_1("LoopCtlTracker; Adding ctl statment for label='%s'\n", ctrl_term->get_label().c_str());
    const std::string label = ctrl_term->get_label();
    LoopCtlScopeStack &ss = loop_control_index[label];
    if (!ss.empty()) {
        loop_control_index[label].back().push_back(ctrl_term);
    }
    //else {
    //  warn("Found dangling loop control statement");
    //}
}


void LoopCtlTracker::pop_loop_scope(pTHX_ const std::string &label, AST::Term *loop) {
    AST_DEBUG_2("LoopCtlTracker: End scope for label='%s' (N scopes: %i)\n", label.c_str(), (int)loop_control_index[label].size());
#ifndef NDEBUG
    ast_term_type t = loop->get_type();
    assert(   t == ast_ttype_bareblock || t == ast_ttype_while
           || t == ast_ttype_for       || t == ast_ttype_foreach);
#endif

    assert(loop_control_index.count(label) > 0);
    LoopCtlScopeStack &scope_stack = loop_control_index[label];
    assert(!scope_stack.empty());

    LoopCtlStatementList &list = scope_stack.back();

    if (!list.empty()) {
        LoopCtlStatementList::iterator it;
        for (it = list.begin(); it != list.end(); ++it) {
            (*it)->set_jump_target(loop);
        }
    }

    scope_stack.pop_back();
    if (scope_stack.empty())
        loop_control_index.erase(label);
}