#include "scan_values.h"
#include "scan_optree.h"

static PerlAST::AST::Value *analyze_value_internal(pTHX_ SV *sv);

static PerlAST::AST::Value *analyze_cv(pTHX_ CV *cv) {
    std::vector<PerlAST::AST::Term *> terms = analyze_optree(aTHX_ cv);
    if (terms.size() == 0)
        croak("Failed to get an AST");
    if (terms.size() > 1)
        croak("More than one AST");

    PAD *pad = PadlistARRAY(CvPADLIST(cv))[1];
    std::vector<PerlAST::AST::Value *> closed_over;

    // entry 0 contains @_, skip it but make pad indices consistent
    closed_over.push_back(NULL);
    for (int i = 1, max = PadMAX(pad); i <= max; ++i) {
        SV *entry = PadARRAY(pad)[i];
        if (SvPADTMP(entry)) {
            closed_over.push_back(NULL);
            continue;
        }

        closed_over.push_back(analyze_value_internal(aTHX_ entry));
    }

    return new PerlAST::AST::Subroutine(terms[0], closed_over);
}

static PerlAST::AST::Value *analyze_value_internal(pTHX_ SV *sv) {
    switch (SvTYPE(sv)) {
#if PERL_VERSION < 10 || PERL_SUBVERSION < 1
    case SVt_RV:
#endif
    case SVt_IV:
        if (SvROK(sv)) {
            SV *rv = SvRV(sv);
            return new PerlAST::AST::RVScalar(analyze_value_internal(aTHX_ rv));
        } else
            return new PerlAST::AST::IVScalar(SvIVX(sv));
    case SVt_PVCV:
        return analyze_cv(aTHX_ (CV *) sv);
    default:
        return NULL;
    }
}

PerlAST::AST::Value *analyze_value(pTHX_ SV *sv) {
    ENTER;

    PerlAST::AST::Value *tmp = analyze_value_internal(aTHX_ sv);

    LEAVE;

    return tmp;
}
